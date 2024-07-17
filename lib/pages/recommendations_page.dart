import 'package:culinary_compass/utils/controllers/grouprecs_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecommendationsPage extends StatelessWidget {
  final GrouprecsController grouprecsController =
      Get.put(GrouprecsController());
  RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchContainer(onPressed: () {}),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grouprecsController.data.length,
            itemBuilder: (context, index) {
              var tileData = grouprecsController.data[index];
              String consolidatedDishNames = '';
              for (int i = 0; i < tileData['dishes'].length; i++) {
                if (i == tileData['dishes'].length - 1) {
                  consolidatedDishNames =
                      consolidatedDishNames + tileData['dishes'][i]['Name'];
                } else {
                  // add comma to end of dish if there are more dishes with the same location
                  consolidatedDishNames = "${consolidatedDishNames +
                      tileData['dishes'][i]['Name']}, ";
                }
              }
              return ListTile(
                title: Text(tileData['Location']),
                // Text(tileData['dishes'][0]['Name'])
                subtitle: Text(consolidatedDishNames),
                trailing: Text('${tileData['average_rating']}⭐'),
                onTap: () {},
              );
            }),
      ),
    );
  }
}
