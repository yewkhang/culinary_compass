import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  final String groupName;
  final List<String> groupMembers;
  const GroupsPage(
      {super.key, required this.groupName, required this.groupMembers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: ListView(
        children: groupMembers.map((element) => Text(element)).toList(),
      ),
    );
  }
}
