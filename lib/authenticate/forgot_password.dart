import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/loading.dart';
import 'package:culinary_compass/utils/constants/misc.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  // to access auth services
  final AuthService _auth = AuthService();
  // to help keep track of state of form, can access validation techniques
  final _formKey = GlobalKey<FormState>();
  // loading state
  bool isLoading = false;

  // text field states
  String email = "";
  String error = "";
  String message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CCColors.primaryColor,
        elevation: 0.0,
        title: const Text(
          "Forgot Password?",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: CCColors.light,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Culinary Compass Name
                const SizedBox(height: 0.0),
                const Text(
                  "Culinary Compass",
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)
                ),
                
                // Welcome back
                const SizedBox(height: 30.0),
                const Text(
                  "Forgot your password? Enter your email below!\nWe will send the reset link there! :)",
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
            
                // Email/Password TextFormFields and all below
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[

                        // Email TextForm Field
                        TextFormField(
                          initialValue: email,
                          decoration: textInputDecoration.copyWith(hintText: "Email"),
                          // returns null --> means is valid
                          // can validate more
                          validator: (typedEmail) => typedEmail!.isEmpty ? "Enter an email" : null,
                          onChanged: (typedEmail) {
                            setState(() {
                              email = typedEmail;
                              error = "";
                              message = "";
                            });
                          },
                        ),

                        // Displays error message if there is, else success message displayed
                        const SizedBox(height: 10.0),
                        Text(
                          error,
                          style: const TextStyle(color: Colors.red, fontSize: 14.0)
                        ),
                        Text(
                          message,
                          style: const TextStyle(color: Colors.green, fontSize: 14.0)
                        ),

                        // Button to send reset link
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: 300.0,
                          height: 50.0,
                          child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color?>(CCColors.primaryColor)),
                            child: const Text("Reset Password", style: TextStyle(color: Colors.black)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) { // uses validator properties above
                                setState(() => isLoading = true); // to show loading screen
                                try {
                                  await _auth.passwordReset(email);
                                  setState(() {
                                    message = "You will receive your password reset link shortly! Do check your email!";
                                    isLoading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    error = "This email is not registered. Please enter a valid email.";
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                          ),
                        ),

                        // Loading animation
                        Center(
                          child: Builder(
                            builder: (context) {
                              if (isLoading) {
                                return const Loading();
                              }
                              return Container(color: Colors.white);
                            }
                          )
                        ),
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