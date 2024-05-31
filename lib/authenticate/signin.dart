import 'package:culinary_compass/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function? togglePageView;
  
  const SignIn({super.key, this.togglePageView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  // to access auth services
  final AuthService _auth = AuthService();
  // to help keep track of state of form, can access validation techniques
  final _formKey = GlobalKey<FormState>();

  // text field states
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 225, 219),
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0, // drop shadow
        title: Text("Sign in to Culinary Compass"),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person, color: Colors.black),
            label: Text(
              "Register",
              style: TextStyle(color: Colors.black)), // to swap pages
            onPressed: () {
              widget.togglePageView!(); // toggle pages using function in widget itself
            },
          )
        ]
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child:Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                // returns null --> means is valid
                validator: (typedEmail) =>
// can validate more
                  typedEmail!.isEmpty ? "Enter an email" : null,
                onChanged: (typedEmail) {
                  setState(() => email = typedEmail);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                obscureText: true,
                validator: (typedPassword) => 
                  (typedPassword!.length < 6) ? "Enter a valid password\nRequirement: At least 6 characters long" : null,
                onChanged: (typedPassword) {
                  setState(() => password = typedPassword);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color?>(Colors.pink[400]!)
                ),
                child: Text("Sign In", style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) { // uses validator properties above
                    dynamic result = await _auth.signInUserEmail(email, password);
                    if (result == null) {
                      setState(() => error = "Please enter a valid email and/or password");
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              // Displays error message if there is, else not displayed
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0)
              )
            ],
          )
        )
      )
    );
  }
}