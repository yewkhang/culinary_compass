import 'package:flutter/material.dart';
import 'package:culinary_compass/utils/constants/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          Container(
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
                      ))
                  
                ],
              ),
            ),
          )
        ],
      ),
    ));
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
