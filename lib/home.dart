import 'package:culinary_compass/pages/places_page.dart';
import 'package:culinary_compass/utils/constants/curved_edges.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    void showAddPlaces() {
      showModalBottomSheet(
          context: context,
          isDismissible: false,
          builder: (context) {
            return PlacesPage();
          });
    }

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          PrimaryHeaderContainer(
              child: Column(
            children: [
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
              const SizedBox(width: 50),
              ElevatedButton(
                onPressed: () => showAddPlaces(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(2),
                  foregroundColor: CCColors.primaryColor, // <-- Splash color
                ),
                child: const Icon(Icons.add),
              )
            ],
          ),
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
          height: 400,
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
