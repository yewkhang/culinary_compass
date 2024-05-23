import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // for reading and writing files

class LoggingPage extends StatelessWidget {
  const LoggingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(children: [
              // spot for image to show
              Obx(() => controller.selectedImagePath.value == ''
                  ? Container(width: 450, height: 400, color: Colors.grey, child: const Center(child: Text('Select an image'),),)
                  : Image.file(
                      File(controller.selectedImagePath.value),
                      fit: BoxFit.cover,
                      width: 450,
                      height: 400,
                    )),
              // gallery image picker
              Positioned(
                top: 300,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    controller.getImage(ImageSource.gallery);
                  },
                  backgroundColor: Colors.amber,
                  child: const Icon(Icons.photo)
                ),
              ),
              // camera image picker
              Positioned( // camera image picker
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
            const Text('To be implemented')
          ],
        ),
      ),
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
