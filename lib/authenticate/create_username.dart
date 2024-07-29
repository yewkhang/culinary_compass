import 'package:culinary_compass/navigation_menu.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/loading.dart';
import 'package:culinary_compass/utils/constants/misc.dart';
import 'package:culinary_compass/utils/controllers/usernamecreation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateUsernamePage extends StatelessWidget {
  
  CreateUsernamePage({super.key});

  // to help keep track of state of form, can access validation techniques
  final _formKey = GlobalKey<FormState>();

  final UsernameCreationController usernameController = Get.put(UsernameCreationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CCColors.light,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Culinary Compass Name
                const Text(
                  "Culinary Compass",
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)
                ),
                
                // Welcome back
                const SizedBox(height: 30.0),
                const Text(
                  """First time using Culinary Compass?\nCreate your username!\n\nNote: Usernames must be unique!\nYour username cannot be changed in future!""",
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10.0),
            
                // Username TextFormField and all else below
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[

                        // Username TextForm Field
                        TextFormField(
                          key: Key("CreateUsername"),
                          controller: usernameController.usernameTextField,
                          decoration: textInputDecoration.copyWith(hintText: "Username"),
                          validator: (typedUsername) {
                            if (typedUsername!.isEmpty) {
                              return "Enter a username!";
                            } else if (usernameController.usernameAlreadyTaken.value) {
                              return "Username has already been taken!";
                            }
                            return null;
                          },
                          onChanged: (typedUsername) async {
                            await usernameController.checkIfUsernameAlreadyTaken(typedUsername);
                          },
                        ),

                        // Create Username Button
                        const SizedBox(height: 50.0),
                        SizedBox(
                          width: 300.0,
                          height: 50.0,
                          child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color?>(CCColors.primaryColor)),
                            child: const Text("Create Username", style: TextStyle(color: Colors.black)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await usernameController.finalUpdateUsernameToFirebase();
                                Get.off(() => NavigationMenu(imagePicker: ImagePicker()));
                                // clear controller
                              }
                            },
                          ),
                        ),

                        // Loading animation
                        Center(
                          child: Builder(
                            builder: (context) {
                              if (usernameController.isLoading.value) {
                                return const Loading();
                              }
                              return Container(color: Colors.white);
                            }
                          )
                        ),

                        // To center the username textformfield
                        const SizedBox(height: 50.0),
                      ]
                    )
                  )
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}