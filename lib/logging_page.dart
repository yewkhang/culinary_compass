// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Models
import 'package:culinary_compass/models/logging_model.dart';
import 'package:culinary_compass/user_repository.dart';
// Dependencies
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // for reading and writing files
import 'package:culinary_compass/utils/constants/colors.dart';
// Controllers
import 'package:culinary_compass/utils/controllers/ratingbar_controller.dart';
import 'package:culinary_compass/utils/controllers/location_controller.dart';
import 'package:culinary_compass/utils/controllers/image_controller.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:culinary_compass/user_repository.dart';

class LoggingPage extends StatelessWidget {
  const LoggingPage({super.key});
  static const List<String> _initialTags = <String>[
    'c',
    'c++',
    'java',
    'json',
    'python',
    'javascript',
  ];

  @override
  Widget build(BuildContext context) {
    final _distanceToField = MediaQuery.of(context).size.width;
    // TextField Controllers
    TextEditingController nameTextController = TextEditingController();
    TextEditingController descriptionTextController = TextEditingController();
    // Image Controller
    final imageController = Get.put(ImageController());
    // Location Suggestion Controller
    final locationController = Get.put(LocationController());
    // TextFieldTags Controller
    final textFieldTagsController = StringTagController();
    // Rating Bar Controller
    final ratingBarController = Get.put(RatingBarController());
    final userRepository = Get.put(UserRepository());
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
      body: ListView(children: <Widget>[
        // ----- IMAGE SELECTION ----- //
        Stack(children: [
          // spot for image to show
          Obx(() => imageController.selectedImagePath.value == ''
              ? Container(
                  width: 450,
                  height: 390,
                  color: Colors.grey,
                  child: const Center(
                    child: Text('Select an image'),
                  ),
                )
              : Image.file(
                  File(imageController.selectedImagePath.value),
                  fit: BoxFit.cover,
                  width: 450,
                  height: 390,
                )),
          // gallery image picker
          Positioned(
            top: 300,
            right: 20,
            child: FloatingActionButton(
                onPressed: () {
                  imageController.getImage(ImageSource.gallery);
                },
                backgroundColor: CCColors.primaryColor,
                child: const Icon(Icons.photo)),
          ),
          // camera image picker
          Positioned(
            top: 230,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                imageController.getImage(ImageSource.camera);
              },
              child: const Icon(Icons.camera_alt),
            ),
          )
        ]),

        // ----- NAME TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            controller: nameTextController,
            decoration: const InputDecoration(
                hintText: 'Dish Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.local_dining,
                  color: CCColors.primaryColor,
                )),
          ),
        ),
        // ----- LOCATION TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            controller: locationController.locationSearch,
            onChanged: (String value) {
              if (value.isNotEmpty) {
                locationController.selectedAddress.value = value;
              }
            },
            decoration: const InputDecoration(
              hintText: 'Location',
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.location_on,
                color: CCColors.primaryColor,
              ),
            ),
            maxLines: null,
          ),
        ),
        // ----- LOCATION SUGGESTIONS ----- //
        Obx(
          () {
            locationController.isLoading.value;
            return locationController.showAutoCompleteList
                ? locationController.isLoading.value
                    ? const Center(
                        // Show loading indicator when fetching results
                        child: CircularProgressIndicator(
                          color: CCColors.primaryColor,
                          strokeWidth: 3,
                        ),
                      )
                    : ListView.builder(
                        // Show results after fetched
                        padding: const EdgeInsets.only(
                            right: CCSizes.defaultSpace,
                            left: CCSizes.defaultSpace),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: locationController.data != []
                            ? locationController.data.length
                            : 0,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(locationController.data[index]
                                    ['description']
                                .toString()),
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: CCColors.primaryColor,
                            ),
                            onTap: () {
                              final placeId =
                                  locationController.data[index]['description'];
                              locationController.inputAddress.value = placeId;
                              // Display chosen location in textfield
                              locationController.locationSearch.text =
                                  locationController.inputAddress.value;
                              // update value to be saved to Firebase
                              // Reset search
                              locationController.selectedAddress.value = '';
                              locationController.data.clear();
                            },
                            tileColor: Colors.grey.withOpacity(0.3),
                          );
                        })
                : const SizedBox(); // When there are not results from location search
          },
        ),
        // Tags (TO BE IMPLEMENTED)
        Autocomplete<String>(
          // Suggested Tags
          optionsViewBuilder: (context, onSelected, options) {
            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return TextButton(
                          onPressed: () {
                            onSelected(option);
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              option,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: CCColors.primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return _initialTags.where((String option) {
              return option.contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selectedTag) {
            textFieldTagsController.onTagSubmitted(selectedTag);
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFieldTags<String>(
              textEditingController: textEditingController,
              focusNode: focusNode,
              textfieldTagsController: textFieldTagsController,
              textSeparators: const [' ', ','],
              validator: (String tag) {
                if (tag == 'php') {
                  return 'php not available';
                } else if (textFieldTagsController.getTags!.contains(tag)) {
                  return 'You\'ve already entered that';
                }
                return null;
              },
              inputFieldBuilder: (context, inputFieldValues) {
                return Padding(
                  padding: const EdgeInsets.all(CCSizes.defaultSpace),
                  child: TextField(
                    controller: inputFieldValues.textEditingController,
                    focusNode: inputFieldValues.focusNode,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: CCColors.primaryColor,
                          width: 3.0,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: CCColors.primaryColor,
                          width: 3.0,
                        ),
                      ),
                      helperStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      hintText: inputFieldValues.tags.isNotEmpty
                          ? ''
                          : "Enter tag...",
                      errorText: inputFieldValues.error,
                      prefixIconConstraints:
                          BoxConstraints(maxWidth: _distanceToField * 0.74),
                      prefixIcon: inputFieldValues.tags.isNotEmpty
                          ? SingleChildScrollView(
                              controller: inputFieldValues.tagScrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  children:
                                      inputFieldValues.tags.map((String tag) {
                                return Container(
                                  // Tags Button Style
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                    color: CCColors.primaryColor,
                                  ),
                                  // space between tag buttons
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  // tags size
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 6.0),
                                  child: Row(
                                    // Row for Tags to display
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Text Style for Tags
                                      InkWell(
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        onTap: () {
                                          //print("$tag selected");
                                        },
                                      ),
                                      const SizedBox(
                                          width:
                                              5.0), // size between text and 'x' button
                                      // Cancel Button Style for Tags
                                      InkWell(
                                        child: const Icon(
                                          Icons.cancel,
                                          size: 16.0,
                                          color: Color.fromARGB(
                                              255, 233, 233, 233),
                                        ),
                                        onTap: () {
                                          inputFieldValues.onTagRemoved(tag);
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }).toList()),
                            )
                          : null,
                    ),
                    onChanged: inputFieldValues.onTagChanged,
                    onSubmitted: inputFieldValues.onTagSubmitted,
                  ),
                );
              },
            );
          },
        ),
        // ----- DESCRIPTION TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            controller: descriptionTextController,
            decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.notes,
                  color: CCColors.primaryColor,
                )),
          ),
        ),
        // ----- RATING BAR ----- //
        Container(
            padding: const EdgeInsets.all(CCSizes.defaultSpace),
            alignment: Alignment.center,
            child: Obx(() => ratingBarController
                .buildRating(ratingBarController.currentRating.value))),
        // ----- SAVE LOG BUTTON ----- // (TO BE IMPLEMENTED)
        ElevatedButton(
            onPressed: () async {
              // Save user log to Firestore
              await userRepository.saveUserLog(
                _auth.currentUser?.uid,
                imageController.selectedImagePath.value,
                nameTextController.text,
                locationController.locationSearch.text,
                ratingBarController.currentRating.value,
                descriptionTextController.text
              );
              // Reset fields upon saving
              imageController.selectedImagePath.value = '';
              nameTextController.text = '';
              locationController.locationSearch.text = '';
              textFieldTagsController.clearTags();
              descriptionTextController.text = '';
              ratingBarController.currentRating.value = 0;
            },
            child: const Text('Save'))
      ]),
    );
  }
}
