import 'package:culinary_compass/pages/places_page.dart';
import 'package:culinary_compass/pages/yourlogs_page.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:flutter/material.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = Get.put(UserRepository());
    final profileController = Get.put(ProfileController());

    void showAddPlaces() {
      showModalBottomSheet(
          context: context,
          isDismissible: false,
          isScrollControlled: true,
          builder: (context) {
            return DraggableScrollableSheet(
                initialChildSize: 0.7,
                expand: false,
                builder: (context, scrollController) {
                  return const PlacesPage();
                });
          });
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Orange Container
              PrimaryHeaderContainer(
                  child: Column(
                children: [
                  // Empty space at top
                  const SizedBox(
                    height: 150,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: CCSizes.defaultSpace + 10),
                      child: Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 45,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: CCSizes.defaultSpace + 10),
                        child: Text(
                          profileController.user.value
                              .username, // To be replaced with username
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Search bar
                  Padding(
                    // horizontal padding
                    padding: const EdgeInsets.all(CCSizes.defaultSpace),
                    child: SearchContainer(
                      onPressed: () => Get.to(YourlogsPage(fromHomePage: true),
                          transition: Transition.rightToLeftWithFade),
                    ),
                  )
                ],
              )),
              Row(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: CCSizes.defaultSpace + 10),
                      child: Text(
                        'Places to try',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showAddPlaces();
                    },
                    style: CCCircularElevatedButtonTheme.lightInputButtonStyle,
                    child: const Icon(Icons.add),
                  )
                ],
              ),
              // List of user's places to try
              StreamBuilder(
                stream: userRepository.fetchPlacesToTry(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: CCColors.primaryColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('An error occurred'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'No places have been added yet!\nTap on the button above to begin!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                          top: 0, bottom: CCSizes.spaceBtwItems),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // ID of each document
                        String docID = snapshot.data!.docs[index].id;
                        // data contains ALL logs from user
                        var data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return Slidable(
                          // Slide to left to delete log
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (context) => Get.defaultDialog(
                                  backgroundColor: Colors.white,
                                  title: 'Delete Place',
                                  middleText:
                                      'Are you sure you want to delete this place?',
                                  confirm: ElevatedButton(
                                    style: CCElevatedTextButtonTheme
                                        .lightInputButtonStyle,
                                    onPressed: () {
                                      userRepository.deletePlacesToTry(docID);
                                      Get.back();
                                      Get.snackbar('', '',
                                          titleText: const Text(
                                            'Place Deleted!',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          messageText: const SizedBox(),
                                          icon: const Icon(
                                            Icons.check_circle_outline_outlined,
                                            color: Colors.white,
                                          ),
                                          backgroundColor: Colors.green,
                                          snackPosition: SnackPosition.BOTTOM,
                                          margin: const EdgeInsets.all(20),
                                          duration: const Duration(seconds: 2));
                                    },
                                    child: const Text(
                                      'Delete Place',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  cancel: ElevatedButton(
                                    style: CCElevatedTextButtonTheme
                                        .unselectedButtonStyle,
                                    onPressed: () => Get.back(),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          child: Padding(
                            // between cards and screen
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Card(
                              color: Colors.white,
                              child: ExpansionTile(
                                title: Text(
                                  data['Name'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_sharp,
                                      color: CCColors.primaryColor,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2)),
                                    Expanded(child: Text(data['Location']))
                                  ],
                                ),
                                shape: const RoundedRectangleBorder(),
                                // padding for the expanded text
                                childrenPadding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 25),
                                expandedAlignment: Alignment.topLeft,
                                children: [
                                  Text(
                                    data['Description'],
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ));
  }
}
