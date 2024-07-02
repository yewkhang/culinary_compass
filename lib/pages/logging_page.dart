// Dependencies
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // for reading and writing files
import 'package:culinary_compass/utils/constants/colors.dart';
// Models
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/models/tags_model.dart';
// Controllers
import 'package:culinary_compass/utils/controllers/ratingbar_controller.dart';
import 'package:culinary_compass/utils/controllers/location_controller.dart';
import 'package:culinary_compass/utils/controllers/image_controller.dart';
import 'package:culinary_compass/utils/controllers/textfield_controllers.dart';
import 'package:culinary_compass/utils/controllers/tags_controller.dart';

// ignore: must_be_immutable
class LoggingPage extends StatelessWidget {
  String name, location, description, originalPictureURL, docID;
  double rating;
  List<String> tags;
  late bool fromYourLogsPage;
  LoggingPage(
      {super.key,
      this.fromYourLogsPage = false,
      required this.docID,
      required this.name,
      required this.originalPictureURL,
      required this.location,
      required this.description,
      required this.tags,
      required this.rating});

  @override
  Widget build(BuildContext context) {
    // TextField Controllers
    final textFieldControllers = Get.put(TextfieldControllers());
    // Image Controller
    final imageController = Get.put(ImageController());
    // Location Suggestion Controller
    final locationController = Get.put(LocationController());
    // Tags Controller
    final tagsController = Get.put(TagsController());
    // Rating Bar Controller
    final ratingBarController = Get.put(RatingBarController());
    final userRepository = Get.put(UserRepository());

    //initial values
    textFieldControllers.nameTextField.text = name;
    textFieldControllers.descriptionTextField.text = description;
    locationController.locationSearch.text = location;
    ratingBarController.currentRating.value = rating;
    tagsController.selectedTags.value = tags;

    return Scaffold(
      body: ListView(children: <Widget>[
        // ----- IMAGE SELECTION ----- //
        Stack(children: [
          // spot for image to show
          Container(
            width: 450,
            height: 390,
            child: fromYourLogsPage
                ? Image.network(
                    originalPictureURL,
                    fit: BoxFit.cover,
                  )
                : Obx(() => imageController.selectedImagePath.value == ''
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
          ),
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
          ),
          Positioned(
            top: 10,
            right: 20,
            child: fromYourLogsPage
                ? IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.cancel_rounded),
                    color: Colors.grey,
                    iconSize: 40,
                  )
                : const SizedBox(),
          )
        ]),

        // ----- NAME TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            controller: textFieldControllers.nameTextField,
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
                              // Reset search
                              locationController.selectedAddress.value = '';
                              locationController.data.clear();
                            },
                            tileColor: Colors.grey.withOpacity(0.3),
                          );
                        })
                : const SizedBox(); // When there are no results from location search
          },
        ),
        // ----- TAG SUGGESTIONS ----- //
        Padding(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TypeAheadField(
              controller: textFieldControllers.tagsTextField,
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Tags',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.tag,
                      color: CCColors.primaryColor,
                    ),
                  ),
                );
              },
              itemBuilder: (BuildContext context, String itemData) {
                return ListTile(
                  title: Text(itemData),
                );
              },
              onSelected: (String suggestion) {
                // add tags only if selected tags doesn't contain 'suggestion'
                if (tagsController.selectedTags.contains(suggestion) == false) {
                  tagsController.selectedTags.add(suggestion);
                  // clear text field upon selection of a tag
                  textFieldControllers.tagsTextField.clear();
                }
              },
              suggestionsCallback: (String query) {
                // list of cuisine tags to select from
                return TagsModel.getSuggestions(query);
              }),
        ),
        // ----- SELECTED TAGS DISPLAY ----- //
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CCSizes.defaultSpace),
          child: Obx(() => tagsController.selectedTags.isEmpty
              ? const Center(
                  child: Text('Select a tag'),
                )
              : Wrap(
                  children: tagsController.selectedTags
                      .map((element) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Chip(
                              label: Text(element),
                              deleteIcon: const Icon(Icons.clear),
                              onDeleted: () =>
                                  tagsController.selectedTags.remove(element),
                            ),
                          ))
                      .toList(),
                )),
        ),
        // ----- DESCRIPTION TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            controller: textFieldControllers.descriptionTextField,
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
        // ----- SAVE/UPDATE LOG BUTTON ----- //
        ElevatedButton(
            onPressed: () async {
              // Check if any of the fields are empty
              if (imageController.selectedImagePath.value.isEmpty ||
                  textFieldControllers.nameTextField.text.isEmpty ||
                  locationController.locationSearch.text.isEmpty ||
                  ratingBarController.currentRating.value.isEqual(0) ||
                  textFieldControllers.descriptionTextField.text.isEmpty ||
                  tagsController.selectedTags.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Container(
                      padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
                      height: 60,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: CCSizes.spaceBtwItems),
                          Text(
                            'Please enter a value for all fields!',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ));
                }
              }
              // All input fields are filled, proceed to save log
              else {
                // Circular progress indicator for saving user logs
                showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: CCColors.primaryColor,
                        ),
                      );
                    });
                // Save user log to Firestore
                fromYourLogsPage
                    ? await userRepository.updateUserLog(
                        docID,
                        originalPictureURL,
                        imageController.selectedImagePath.value,
                        textFieldControllers.nameTextField.text,
                        locationController.locationSearch.text,
                        ratingBarController.currentRating.value,
                        textFieldControllers.descriptionTextField.text,
                        tagsController.selectedTags)
                    : await userRepository.saveUserLog(
                        imageController.selectedImagePath.value,
                        textFieldControllers.nameTextField.text,
                        locationController.locationSearch.text,
                        ratingBarController.currentRating.value,
                        textFieldControllers.descriptionTextField.text,
                        tagsController.selectedTags);
                // Saved log snackbar to tell user log has been saved
                if (context.mounted) {
                  Navigator.of(context)
                      .pop(); // remove circular progress indicator
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Container(
                      padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
                      height: 60,
                      decoration: const BoxDecoration(
                          color: CCColors.secondaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: CCSizes.spaceBtwItems),
                          Text(
                            'Log Saved!',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ));
                }
                // Reset fields upon saving
                imageController.selectedImagePath.value = '';
                textFieldControllers.nameTextField.text = '';
                locationController.locationSearch.text = '';
                textFieldControllers.descriptionTextField.text = '';
                ratingBarController.currentRating.value = 0;
                tagsController.selectedTags.clear();
                textFieldControllers.tagsTextField.clear();

                if (fromYourLogsPage) {
                  Get.back();
                }
              }
            },
            child:
                fromYourLogsPage ? const Text('Update') : const Text('Save')),
      ]),
    );
  }
}
