import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingBarController extends GetxController {
  RxDouble currentRating = 0.0.obs;
  
  // Rating Bar Design
  Widget buildRating(double rating) {
    return RatingBar.builder(
      initialRating: rating,
      allowHalfRating: true,
      itemPadding: EdgeInsets.symmetric(horizontal: 20),
      glow: false,
      itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
      onRatingUpdate: (rating) {
        currentRating.value = rating;
      });
  }
}
