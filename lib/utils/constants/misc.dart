import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

// For Sign In Methods
class OtherSignInMethods extends StatelessWidget {

  final String imagePath;
  final Function()? onTap;

  const OtherSignInMethods({
    super.key,
    required this.imagePath,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200]
        ),
        height: 70,
        child: Image.asset(
          imagePath,
        ),
      ),
    );
  }
}

// Decoration for Textboxes
// note: Color.fromRGBO() is used as constant value
// input hintText by chaining with .copyWith() in other files
const textInputDecoration = InputDecoration(
  fillColor: Color.fromRGBO(238, 238, 238, 1),
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromRGBO(224, 224, 224, 1), width: 2.0)
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0)
  )
);

// Profile Page Textbox Abstraction (Editable)
class ProfileTextboxEditable extends StatelessWidget {
  final String sectionName;
  final String text;
  final void Function()? onPressed;

  const ProfileTextboxEditable({
    super.key,
    required this.sectionName,
    required this.text,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0)
      ),
      padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style: TextStyle(color: Colors.grey[500]),
              ),

              IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.edit,
                  color: Colors.grey[400]
                )
              )
            ],
          ),

          Text(text)
        ],
      )
    );
  }
}

// Profile Page Textbox Abstraction (Non-Editable)
class ProfileTextboxNonEditable extends StatelessWidget {
  final String sectionName;
  final String text;

  const ProfileTextboxNonEditable({
    super.key,
    required this.sectionName,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0)
      ),
      padding: const EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionName,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 15.0),
          Text(text)
        ],
      )
    );
  }
}

// Profile Page UID Textbox Abstraction (Copy to Clipboard)
class ProfileUneditableTextBox extends StatelessWidget {
  final String field;
  final String text;

  const ProfileUneditableTextBox({
    super.key,
    required this.field,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0)
          ),
          padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    field,
                    style: TextStyle(color: Colors.grey[500]),
                  ),

                  IconButton(
                    onPressed: () async {
                      await FlutterClipboard.copy(text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Copied to Clipboard!")
                        )
                      );
                    },
                    icon: Icon(
                      Icons.content_copy,
                      color: Colors.grey[400]
                    )
                  )
                ],
              ),
        
              Text(text)
            ],
          )
        );
      }
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color? color;
  final void Function()? onTap;

  const SettingsRow({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100]
          ),
        child: Row(
          children: [
            const SizedBox(width: 15.0),

            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: color,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
              )
            ),
            const SizedBox(width: 20.0),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            ),
            const Spacer(),
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black,
                size: 50.0,
              )
            )
          ],
        ),
      ),
    );
  }
}