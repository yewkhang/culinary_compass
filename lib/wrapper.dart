import 'package:culinary_compass/authenticate/authenticate.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:culinary_compass/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  final ImagePicker imagePicker;
  const Wrapper({super.key, required this.imagePicker});

  @override
  Widget build(BuildContext context) {
    // return either home or authenticate --> is like the governing class
    // dynamic: hence will listen for any auth changes and correctly display appropriate page

    final myUser = Provider.of<MyUser?>(context);
    if (myUser == null) {
      return const Authenticate();
    } else {
      return NavigationMenu(imagePicker: imagePicker);
    }
  }
}