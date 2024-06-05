import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // for reading and writing files
import 'package:culinary_compass/utils/constants/colors.dart';
// Controllers
import 'package:culinary_compass/utils/controllers/ratingbar_controller.dart';
import 'package:culinary_compass/utils/controllers/location_controller.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({super.key});

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  // Logging values
  // File _picture;
  late String _name;
  late String _location;
  late String _description;

  // TextField Controllers
  TextEditingController nameTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  // Image Controller
  final imageController = Get.put(ImageController());
  // Location Suggestion Controller
  final locationController = Get.put(LocationController());
  // Rating Bar Controller
  final ratingBarController = Get.put(RatingBarController());

  @override
  Widget build(BuildContext context) {
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
        Container(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            controller: nameTextController,
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
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
        Container(
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
                ? ListView.builder(
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
                          _location = locationController.inputAddress.value;
                          // Reset search
                          locationController.selectedAddress.value = '';
                          locationController.data = [];
                        },
                        tileColor: Colors.grey.withOpacity(0.3),
                      );
                    })
                : const SizedBox(); // When there are not results from location search
          },
        ),
        // Tags (TO BE IMPLEMENTED)
        // ----- DESCRIPTION TEXTFIELD ----- //
        Container(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            controller: descriptionTextController,
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
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
              // Reset fields upon saving
              imageController.selectedImagePath.value = '';
              nameTextController.text = '';
              locationController.locationSearch.text = '';
              descriptionTextController.text = '';
              ratingBarController.currentRating.value = 0;
            },
            child: const Text('Save'))
      ]),
    );
  }
}

class ImageController extends GetxController {
  var selectedImagePath = ''.obs;

  void getImage(ImageSource imageSource) async {
    final selectedFile = await ImagePicker().pickImage(source: imageSource);
    if (selectedFile != null) {
      // user picks an image
      selectedImagePath.value = selectedFile.path;
    } else {
      return;
    }
  }
}
