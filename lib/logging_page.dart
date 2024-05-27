import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // for reading and writing files
import 'package:culinary_compass/utils/constants/colors.dart';


class LoggingPage extends StatefulWidget {
  const LoggingPage({super.key});

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  // Logging values
  // File _picture;
  late String _name;
  // var _location;
  late String _description;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageController());

    return Scaffold(
      body: ListView(children: <Widget>[
        // Image Selection
        Stack(children: [
          // spot for image to show
          Obx(() => controller.selectedImagePath.value == ''
              ? Container(
                  width: 450,
                  height: 390,
                  color: Colors.grey,
                  child: const Center(
                    child: Text('Select an image'),
                  ),
                )
              : Image.file(
                  File(controller.selectedImagePath.value),
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
                  controller.getImage(ImageSource.gallery);
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
                controller.getImage(ImageSource.camera);
              },
              child: const Icon(Icons.camera_alt),
            ),
          )
        ]),
        // Name TextField
        Container(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Dish Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        // Location TextField (TO BE IMPLEMENTED)
        // Tags (TO BE IMPLEMENTED)
        // Description TextField
        Container(
          padding: const EdgeInsets.all(CCSizes.defaultSpace),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        // Save log button (TO BE IMPLEMENTED)
        ElevatedButton(
            onPressed: () async {
              print(_name);
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
