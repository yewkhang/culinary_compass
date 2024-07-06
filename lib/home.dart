import 'package:culinary_compass/pages/places_page.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/curved_edges.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = Get.put(UserRepository());

    void showAddPlaces() {
      showModalBottomSheet(
          context: context,
          isDismissible: false,
          builder: (context) {
            return const PlacesPage();
          });
    }

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          PrimaryHeaderContainer(
              child: Column(
            children: [
              const SizedBox( // Empty space at top
                height: 150,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: CCSizes.defaultSpace + 10),
                  child: Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: CCSizes.defaultSpace + 10),
                  child: Text(
                    'User',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                // horizontal padding
                padding: const EdgeInsets.all(CCSizes.defaultSpace),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      SizedBox(width: CCSizes.spaceBtwItems),
                      Text('What would you like to eat today?')
                    ],
                  ),
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
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  showAddPlaces();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.all(2),
                  foregroundColor: CCColors.primaryColor, // <-- Splash color
                ),
                child: const Icon(Icons.add),
              )
            ],
          ),
          StreamBuilder(
              stream: userRepository.fetchPlacesToTry(),
              builder: (context, snapshot) {
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? const Center(
                        // Retrieving from Firestore
                        child: CircularProgressIndicator(
                          color: CCColors.primaryColor,
                        ),
                      )
                    : ListView.builder(
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
                                            title: 'Delete Place',
                                            middleText:
                                                'Are you sure you want to delete this place?',
                                            confirm: ElevatedButton(
                                                onPressed: () {
                                                  userRepository
                                                      .deletePlacesToTry(docID);
                                                  Get.back();
                                                },
                                                child:
                                                    const Text('Delete Place')),
                                            cancel: ElevatedButton(
                                                onPressed: () => Get.back(),
                                                child: const Text('Cancel')),
                                          ))
                                ]),
                            child: Padding(
                              // between cards and screen
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                child: ExpansionTile(
                                  title: Text(
                                    data['Name'],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  subtitle: Row(children: [
                                    const Icon(
                                      Icons.location_on_sharp,
                                      color: CCColors.primaryColor,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2)),
                                    Expanded(child: Text(data['Location']))
                                  ]),
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
                        });
              }),
        ],
      ),
    ));
  }
}

class PrimaryHeaderContainer extends StatelessWidget {
  const PrimaryHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CurvedEdgesWidget(
      child: Container(
        color: CCColors.primaryColor,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: 450,
          child: Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: CircularContainer(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              Positioned(
                  top: 100,
                  right: -300,
                  child: CircularContainer(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  )),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class CurvedEdgesWidget extends StatelessWidget {
  const CurvedEdgesWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomCurvedEdges(),
      child: child,
    );
  }
}

class CircularContainer extends StatelessWidget {
  const CircularContainer({
    super.key,
    // assigned default values
    this.child,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.padding = 0,
    this.backgroundColor = Colors.white,
  });

  // ? indicates optional arguments
  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius), color: backgroundColor),
      child: child,
    );
  }
}
