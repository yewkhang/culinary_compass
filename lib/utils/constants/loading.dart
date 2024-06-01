import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:culinary_compass/utils/constants/colors.dart';

// displays a wave loading widget when called (best with loading condition)
class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CCColors.light,
      child: const Center(
        child: SpinKitWave(
          color: CCColors.primaryColor,
          size: 50.0
        ),
      )
    );
  }
}