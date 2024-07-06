import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageController extends GetxController {
  var selectedImagePath = ''.obs;

  Future<void> getImage(ImageSource imageSource) async {
    final XFile? selectedFile = await ImagePicker().pickImage(source: imageSource);
    if (selectedFile != null) {
      // user picks an image
      selectedImagePath.value = selectedFile.path;
    } else {
      return;
    }
  }
}