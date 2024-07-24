import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageController extends GetxController {
  var selectedImagePath = ''.obs;

  final ImagePicker imagePicker;

  ImageController({required this.imagePicker});

  void getImage(ImageSource imageSource) async {
    final selectedFile = await imagePicker.pickImage(source: imageSource);
    if (selectedFile != null) {
      // user picks an image
      selectedImagePath.value = selectedFile.path;
    } else {
      return;
    }
  }
}