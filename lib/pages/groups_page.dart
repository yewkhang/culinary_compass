import 'package:culinary_compass/pages/groupinfo_page.dart';
import 'package:culinary_compass/pages/recommendations_page.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/grouprecs_controller.dart';
import 'package:culinary_compass/utils/controllers/groups_controller.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsPage extends StatelessWidget {
  final Map<String, dynamic> document;
  final String groupID;
  final groupRecsController = Get.put(GrouprecsController());
  final ProfileController profileController = ProfileController.instance;
  final groupsController = Get.put(GroupsController());
  final userRepository = Get.put(UserRepository());
  GroupsPage({super.key, required this.document, required this.groupID});

  @override
  Widget build(BuildContext context) {
    // Show filter bottom sheet
    void showRecommendations() {
      showModalBottomSheet(
          isDismissible: false,
          context: context,
          builder: (context) {
            return RecommendationsPage();
          });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GroupNameContainer(
            groupName: document['Name'],
            onPressed: () {
              Get.to(GroupInfoPage(
                document: document,
                groupID: groupID,
              ));
            }),
        backgroundColor: CCColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CCSizes.spaceBtwItems),
        child: Stack(children: [
          Column(
            children: [
              // Wrap StreamBuilder in expanded to take up remaining space
              Expanded(
                child: SingleChildScrollView(
                  controller: groupsController.scrollController,
                  child: StreamBuilder(
                    stream: groupsController.fetchGroupMessages(groupID),
                    builder: (context, snapshot) {
                      return (snapshot.connectionState ==
                              ConnectionState.waiting)
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: CCColors.primaryColor,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                                bool isCurrentUser = data['UID'] ==
                                    profileController.user.value.uid;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 8.0,
                                      left: isCurrentUser ? 100 : 8,
                                      right: isCurrentUser ? 8 : 100),
                                  child: ChatBubble(
                                      message: data['Message'],
                                      username: data['Name'],
                                      date: data['Date'],
                                      isCurrentUser: isCurrentUser),
                                );
                              },
                            );
                    },
                  ),
                ),
              ),
              // Row of widgets at the bottom, constrained by Container
              Container(
                padding: const EdgeInsets.only(bottom: CCSizes.spaceBtwItems),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      // ------ MESSAGE TEXTFIELD ------ //
                      child: TextField(
                          controller: groupsController.chatTextController,
                          focusNode: groupsController.focusnode,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Type something',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: CCSizes.spaceBtwItems),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: CCColors.primaryColor, width: 2)),
                            prefixIcon: Container(
                              decoration: const BoxDecoration(
                                  color: CCColors.primaryColor,
                                  shape: BoxShape.circle),
                              margin: const EdgeInsets.only(
                                  left: 5, right: CCSizes.spaceBtwItems),
                              // ------ SHOW RECOMMENDATIONS BUTTON ------ //
                              child: IconButton(
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: CCColors.primaryColor,
                                          ),
                                        );
                                      });
                                  await groupRecsController.herokuAPI(
                                      document['MembersUID']
                                          .whereType<String>()
                                          .toList());
                                  Get.back();
                                  showRecommendations();
                                },
                                icon: const Icon(
                                  Icons.recommend_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )),
                    ),
                    // ------ SEND MESSAGE BUTTON ------ //
                    Container(
                      decoration: const BoxDecoration(
                          color: CCColors.primaryColor, shape: BoxShape.circle),
                      margin: const EdgeInsets.only(left: 5.0),
                      child: IconButton(
                        onPressed: () async {
                          if (groupsController.chatTextController.text
                              .trim()
                              .isNotEmpty) {
                            await groupsController.sendMessageToGroup(
                              groupID,
                              profileController.user.value.username,
                              profileController.user.value.uid,
                              groupsController.chatTextController.text,
                            );
                            groupsController.chatTextController.clear();
                            // scroll chat to show new message
                            groupsController.scrollDown();
                          }
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // press to scroll to bottom
          Positioned(
            bottom: 85,
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400, shape: BoxShape.circle),
                  margin: const EdgeInsets.only(left: 5.0),
                  child: IconButton(
                    onPressed: () => groupsController.scrollDown(),
                    icon: const Icon(
                      Icons.expand_more_rounded,
                      color: Colors.white,
                    ),
                  )))
        ]),
      ),
    );
  }
}
