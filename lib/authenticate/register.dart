import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/loading.dart';
import 'package:culinary_compass/utils/constants/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function()? togglePageView;
  
  const Register({super.key, this.togglePageView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  // to access auth services
  final AuthService _auth = AuthService(auth: FirebaseAuth.instance);
  // to help keep track of state of form, can access validation techniques
  final _formKey = GlobalKey<FormState>();
  // loading state
  bool isLoading = false;

  // text field states
  String email = "";
  String password = "";
  String passwordConfirmed = "";
  String error = "";

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
                const SizedBox(height: 50.0),
                const Text(
                  "Culinary Compass",
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 15.0),
            
                // Email/Password TextFormFields and all below
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[

                        // Email TextForm Field
                        TextFormField(
                          key: const Key("EmailFieldRegister"),
                          initialValue: email,
                          decoration: textInputDecoration.copyWith(hintText: "Email"),
                          // returns null --> means is valid
                          // can validate more
                          validator: (typedEmail) => typedEmail!.isEmpty ? "Enter an email" : null,
                          onChanged: (typedEmail) {
                            setState(() => email = typedEmail);
                          },
                        ),

                        // Password TextFormField
                        const SizedBox(height: 10.0),
                        TextFormField(
                          key: const Key("PasswordFieldRegister"),
                          initialValue: password,
                          decoration: textInputDecoration.copyWith(hintText: "Password"),
                          obscureText: true,
                          // can validate more
                          validator: (typedPassword) => (typedPassword!.length < 6) ? "Enter a valid password\nRequirement: At least 6 characters long" : null,
                          onChanged: (typedPassword) {
                            setState(() => password = typedPassword);
                          },
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          key: const Key("ConfirmPasswordFieldRegister"),
                          initialValue: passwordConfirmed,
                          decoration: textInputDecoration.copyWith(hintText: "Confirm Password"),
                          obscureText: true,
                          // can validate more
                          validator: (typedConfirmedPassword) => (typedConfirmedPassword != password) ? "Passwords do not match" : null,
                          onChanged: (typedConfirmedPassword) {
                            setState(() => passwordConfirmed = typedConfirmedPassword);
                          },
                        ),



                        // Sign In Button
                        const SizedBox(height: 30.0),
                        SizedBox(
                          width: 300.0,
                          height: 50.0,
                          child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color?>(CCColors.primaryColor)),
                            child: const Text("Register", style: TextStyle(color: Colors.black)),
                            onPressed: () async {
                              setState(() {
                                error = "";
                              });
                              if (_formKey.currentState!.validate()) { // uses validator properties above
                                setState(() => isLoading = true); // to show loading screen
                                dynamic result = await _auth.registerUserEmail(email, password);
                                if (result == null) {
                                  setState(() {
                                    error = "Please enter a valid email.\nOtherwise, this email might already be used!";
                                    isLoading = false; // if credentials are wrong, then show sign in page
                                  });
                                }
                                // no need for else clause, because User enters through stream in _auth anyways and authenticates
                              }
                            },
                          ),
                        ),

                        // Displays error message if there is, else not displayed
                        const SizedBox(height: 10.0),
                        Text(
                          error,
                          style: const TextStyle(color: Colors.red, fontSize: 14.0),
                          textAlign: TextAlign.center,
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

                        // Divider (Or continue with Google)
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              )
                            ),
                            Text(
                              "Or Continue With Google",
                              style: TextStyle(color: Colors.grey[500])),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              )
                            ),
                          ]
                        ),
                        
                        // Other Sign-In Methods
                        // Google Signin Button
                        const SizedBox(height: 40.0),
                        Row( // can remove the row widget in future, in case want to add more stuff
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // from misc.dart
                            OtherSignInMethods(
                              imagePath: 'lib/images/google.png',
                              onTap:() async {
                                setState(() => isLoading = true);
                                dynamic result = await _auth.signInGoogle();
                                if (result == null) {
                                  setState(() {
                                    error = "Error signing in to Google!";
                                    isLoading = false; // if credentials are wrong, then show sign in page
                                  });
                                }
                              }
                            )
                          ],
                        ),

                        // Not a member? Register now!
                        const SizedBox(height: 40.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.grey[700])
                            ),
                            const SizedBox(width: 5.0),
                            GestureDetector(
                              onTap: widget.togglePageView,
                              child: Text(
                                "Log in now!",
                                style: TextStyle(color: Colors.blue[500], fontWeight: FontWeight.bold)
                              ),
                            ),
                          ],
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

/*
class Register extends StatefulWidget {
  final Function? togglePageView;
  
  const Register({super.key, this.togglePageView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  // to access auth services
  final AuthService _auth = AuthService();
  // to help keep track of state of form, can access validation techniques
  final _formKey = GlobalKey<FormState>();
  // loading state
  bool isLoading = false;

  // text field states
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CCColors.primaryColor,
        elevation: 0.0, // drop shadow
        title: const Text("Register with Culinary Compass", style: TextStyle(fontSize: 18.0)),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person, color: Colors.black),
            label: const Text(
              "Sign In",
              style: TextStyle(color: Colors.black)), // to swap pages
            onPressed: () {
              widget.togglePageView!(); // toggle pages using function in widget itself
            },
          )
        ]
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child:Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: "Email"),
                // returns null --> means is valid
                validator: (typedEmail) =>
// can validate more
                  typedEmail!.isEmpty ? "Enter an email" : null,
                onChanged: (typedEmail) {
                  setState(() => email = typedEmail);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: "Password"),
                obscureText: true,
                validator: (typedPassword) => 
                  (typedPassword!.length < 6) ? "Enter a valid password\nRequirement: At least 6 characters long" : null,
                onChanged: (typedPassword) {
                  setState(() => password = typedPassword);
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color?>(CCColors.primaryColor)
                ),
                child: const Text("Register", style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) { // uses validator properties above
                    setState(() => isLoading = true); // to show loading screen
                    dynamic result = await _auth.registerUserEmail(email, password);
                    if (result == null) {
                      setState(() {
                        error = "Please enter a valid email";
                        isLoading = false; // if credentials are wrong, then show sign in page
                      });
                    }
                    // no need for else clause, because User enters through stream in _auth anyways and authenticates
                  }
                },
              ),
              const SizedBox(height: 12.0),
              // Displays error message if there is, else not displayed
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0)
              ),
              Center(
                child: Builder(
                  builder: (context) {
                    if (isLoading) {
                      return const Loading();
                    }
                    return Container(color: Colors.white);
                  }
                )
              )
            ]
          )
        )
      )
    );
  }
}
*/