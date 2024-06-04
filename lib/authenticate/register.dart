import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/loading.dart';
import 'package:culinary_compass/utils/constants/misc.dart';
import 'package:flutter/material.dart';

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