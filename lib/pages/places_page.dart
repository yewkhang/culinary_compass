import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/location_controller.dart';
import 'package:culinary_compass/utils/controllers/places_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final placesController = Get.put(PlacesController());
    final locationController = Get.put(LocationController());
    final userRepository = Get.put(UserRepository());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a place'),
        backgroundColor: CCColors.primaryColor,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(CCSizes.defaultSpace),
              child: TextField(
                controller: placesController.nameTextField,
                decoration: const InputDecoration(
                    hintText: 'Place Name',
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
                  } else {
                    locationController.selectedAddress.value = '';
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
                                  final placeId = locationController.data[index]
                                      ['description'];
                                  locationController.inputAddress.value =
                                      placeId;
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
            Padding(
              padding: const EdgeInsets.all(CCSizes.defaultSpace),
              child: TextField(
                controller: placesController.descriptionTextField,
                decoration: const InputDecoration(
                    hintText: 'Comments',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.notes,
                      color: CCColors.primaryColor,
                    )),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: CCColors.primaryColor,
                          ),
                        );
                      });
                  await userRepository.savePlacesToTry(
                      placesController.nameTextField.text,
                      locationController.locationSearch.text,
                      placesController.descriptionTextField.text);
                  Get.back(); // remove circular progress indicator
                  // Reset values
                  placesController.nameTextField.text = '';
                  locationController.locationSearch.text = '';
                  placesController.descriptionTextField.text = '';
                  Get.back(); // get back to home page
                  Get.snackbar('', '',
                      titleText: const Text(
                        'Place Saved!',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      messageText: const SizedBox(),
                      icon: const Icon(
                        Icons.check_circle_outline_outlined,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.green,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(20));
                },
                child: const Text('Add place'))
          ],
        ),
      ),
    );
  }
}
