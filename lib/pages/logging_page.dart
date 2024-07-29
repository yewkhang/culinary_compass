// Dependencies
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:culinary_compass/utils/theme/snackbar_theme.dart';
import 'package:culinary_compass/utils/theme/textfield_theme.dart';
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

class LoggingPage extends StatelessWidget {
  final String name, location, description, originalPictureURL, docID;
  final double rating;
  final List<String> tags;
  final bool fromYourLogsPage;
  final ImagePicker imagePicker;


  const LoggingPage(
      {super.key,
      this.fromYourLogsPage = false,
      required this.docID,
      required this.name,
      required this.originalPictureURL,
      required this.location,
      required this.description,
      required this.tags,
      required this.rating,
      required this.imagePicker});

  @override
  Widget build(BuildContext context) {
    // TextField Controllers
    final textFieldControllers = Get.put(TextfieldControllers());
    // Image Controller
    final imageController = Get.put(ImageController(imagePicker: imagePicker));
    // Location Suggestion Controller
    final locationController = Get.put(LocationController());
    // Tags Controller
    final tagsController = Get.put(TagsController());
    // Rating Bar Controller
    final ratingBarController = Get.put(RatingBarController());
    // Profile Controller
    final profileController = ProfileController.instance;
    // User Repository (Methods)
    final userRepository = Get.put(UserRepository());

    //initial values
    textFieldControllers.nameTextField.text = name;
    imageController.selectedImagePath.value = originalPictureURL;
    textFieldControllers.descriptionTextField.text = description;
    locationController.locationSearch.text = location;
    ratingBarController.currentRating.value = rating;
    tagsController.selectedTags.value = tags;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fromYourLogsPage ? "Edit Log" : "Create Log",
          style: const TextStyle(color: Colors.black, fontSize: 24),
        ),
        backgroundColor: CCColors.primaryColor,
      ),
      backgroundColor: Colors.white,
      body: ListView(children: <Widget>[
        // ----- IMAGE SELECTION ----- //
        Stack(children: [
          // spot for image to show
          SizedBox(
              width: 450,
              height: 390,
              child: Obx(() {
                // if routed from search page, image path is Firebase URL
                if (imageController.selectedImagePath.value
                    .startsWith('http')) {
                  return Image.network(
                    imageController.selectedImagePath.value,
                    fit: BoxFit.cover,
                  );
                }
                // if routed from navigation menu, image value is empty
                else if (imageController.selectedImagePath.value == '') {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Text('Select an image'),
                    ),
                  );
                } else {
                  // image from camera/gallery
                  return Image.file(
                    File(imageController.selectedImagePath.value),
                    fit: BoxFit.cover,
                  );
                }
              })),
          // gallery image picker
          Positioned(
            top: 300,
            right: 20,
            child: ElevatedButton(
                onPressed: () {
                  imageController.getImage(ImageSource.gallery);
                },
                style: CCElevatedIconButtonTheme.lightInputButtonStyle,
                child: const Icon(
                  Icons.photo,
                  color: Colors.black,
                )),
          ),
          // camera image picker
          Positioned(
            top: 230,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                imageController.getImage(ImageSource.camera);
              },
              style: CCElevatedIconButtonTheme.lightInputButtonStyle,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
            ),
          ),
        ]),
        // ----- NAME TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.only(
              top: CCSizes.defaultSpace,
              left: CCSizes.defaultSpace,
              right: CCSizes.defaultSpace),
          child: TextField(
              key: Key("DishName"),
              controller: textFieldControllers.nameTextField,
              decoration: textFieldInputDecoration(
                  hintText: 'Dish Name', prefixIcon: Icons.local_dining)),
        ),
        // ----- LOCATION TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.only(
              top: CCSizes.defaultSpace,
              left: CCSizes.defaultSpace,
              right: CCSizes.defaultSpace),
          child: TextField(
            key: Key("Location"),
            controller: locationController.locationSearch,
            onChanged: (String value) {
              if (value.isNotEmpty) {
                locationController.selectedAddress.value = value;
              } else {
                locationController.selectedAddress.value = '';
              }
            },
            decoration: textFieldInputDecoration(
                hintText: 'Location', prefixIcon: Icons.location_on),
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
                            key: Key("ListTile$index"),
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
                            tileColor: Colors.grey.shade100,
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
                    key: Key("Tags"),
                    controller: controller,
                    focusNode: focusNode,
                    decoration: textFieldInputDecoration(
                        hintText: 'Cuisines', prefixIcon: Icons.tag));
              },
              itemBuilder: (BuildContext context, String itemData) {
                return ListTile(
                  title: Text(itemData),
                  tileColor: Colors.white,
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
                      .map((element) => CCTagsContainer(
                          label: Text(element),
                          deleteIcon: const Icon(Icons.clear),
                          onDeleted: () =>
                              tagsController.selectedTags.remove(element)))
                      .toList(),
                )),
        ),
        // ----- DESCRIPTION TEXTFIELD ----- //
        Padding(
          padding: const EdgeInsets.only(
              top: CCSizes.defaultSpace,
              left: CCSizes.defaultSpace,
              right: CCSizes.defaultSpace),
          child: TextField(
              key: Key("Description"),
              controller: textFieldControllers.descriptionTextField,
              maxLines: null,
              decoration: textFieldInputDecoration(
                  hintText: 'Description', prefixIcon: Icons.notes)),
        ),
        // ----- RATING BAR ----- //
        Container(
            padding: const EdgeInsets.all(CCSizes.defaultSpace),
            alignment: Alignment.center,
            child: Obx(() => ratingBarController
                .buildRating(ratingBarController.currentRating.value))),
        // ----- SAVE/UPDATE LOG BUTTON ----- //
        Padding(
          padding: const EdgeInsets.only(
              bottom: CCSizes.defaultSpace, left: 10, right: 10),
          child: ElevatedButton(
              key: Key("SaveLogButton"),
              style: CCElevatedTextButtonTheme.lightInputButtonStyle,
              onPressed: () async {
                // Check if any of the fields are empty
                if (imageController.selectedImagePath.value.isEmpty ||
                    textFieldControllers.nameTextField.text.isEmpty ||
                    locationController.locationSearch.text.isEmpty ||
                    ratingBarController.currentRating.value.isEqual(0) ||
                    tagsController.selectedTags.isEmpty) {
                  CCSnackBarTheme.defaultFailureSnackBar('Please enter a value for all fields!');
                }
                // All input fields are filled, proceed to save log
                else {
                  // Circular progress indicator for saving user logs
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(

                        );
                      });
                  // Save/Update user log to Firestore
                  fromYourLogsPage
                      ? await userRepository.updateUserLog(
                          docID,
                          originalPictureURL,
                          profileController.user.value.username,
                          imageController.selectedImagePath.value,
                          textFieldControllers.nameTextField.text,
                          locationController.locationSearch.text,
                          ratingBarController.currentRating.value,
                          textFieldControllers.descriptionTextField.text,
                          tagsController.selectedTags)
                      : await userRepository.saveUserLog(
                          profileController.user.value.username,
                          imageController.selectedImagePath.value,
                          textFieldControllers.nameTextField.text,
                          locationController.locationSearch.text,
                          ratingBarController.currentRating.value,
                          textFieldControllers.descriptionTextField.text,
                          tagsController.selectedTags);
                  // Saved log snackbar to tell user log has been saved
                  Get.back(); // remove circular progress indicator
                  if (fromYourLogsPage) {
                    Get.back();
                  }
                  CCSnackBarTheme.defaultSuccessSnackBar(fromYourLogsPage ? 'Log Updated!' : 'Log Saved!');
                  // Reset fields upon saving
                  imageController.selectedImagePath.value = '';
                  textFieldControllers.nameTextField.text = '';
                  locationController.locationSearch.text = '';
                  textFieldControllers.descriptionTextField.text = '';
                  ratingBarController.currentRating.value = 0;
                  tagsController.selectedTags.clear();
                  textFieldControllers.tagsTextField.clear();
                }
              },
              child: Text(
                fromYourLogsPage ? 'Update' : 'Save',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
              )),
        ),
      ]),
    );
  }
}
