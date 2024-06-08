import 'package:culinary_compass/models/logging_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Save user logs
  Future<void> saveUserLog(LoggingModel log) async {
    try {
      await _db.collection("Logs").doc(log.uid).set(log.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }
}