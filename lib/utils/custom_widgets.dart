import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/curved_edges.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchContainer extends StatelessWidget {
  const SearchContainer({
    super.key,
    required this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.person_search_outlined,
              color: Colors.grey,
            ),
            SizedBox(width: CCSizes.spaceBtwItems),
            Text(
              'Search friend recommendations',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}

class PrimaryHeaderContainer extends StatelessWidget {
  const PrimaryHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CurvedEdgesWidget(
      child: Container(
        color: CCColors.primaryColor,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: 400,
          child: Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: CircularContainer(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              Positioned(
                  top: 100,
                  right: -300,
                  child: CircularContainer(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  )),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class CurvedEdgesWidget extends StatelessWidget {
  const CurvedEdgesWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomCurvedEdges(),
      child: child,
    );
  }
}

class CircularContainer extends StatelessWidget {
  const CircularContainer({
    super.key,
    // assigned default values
    this.child,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.padding = 0,
    this.backgroundColor = Colors.white,
  });

  // ? indicates optional arguments
  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius), color: backgroundColor),
      child: child,
    );
  }
}

class CardContainer extends StatelessWidget {
  const CardContainer({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset.fromDirection(1.5, 2),
                color: Colors.grey.shade300)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child);
  }
}

// used to contain all Tags
class CCTagsContainer extends StatelessWidget {
  final Widget label;
  final void Function()? onDeleted;
  final Widget? deleteIcon;

  const CCTagsContainer({
    super.key,
    required this.label,
    this.onDeleted,
    this.deleteIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding between tags
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Chip(
        label: label,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(1),
        deleteIcon: deleteIcon,
        onDeleted: onDeleted,
      ),
    );
  }
}

class GroupNameContainer extends StatelessWidget {
  final String groupName;

  const GroupNameContainer({
    super.key,
    required this.groupName,
    required this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.sizeOf(context).width,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Text(groupName)));
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String username;
  final Timestamp date;
  final bool isCurrentUser;
  const ChatBubble(
      {super.key,
      required this.message,
      required this.username,
      required this.date,
      required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: isCurrentUser ? CCColors.secondaryColor : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$username   ${DateFormat('d/MM/yyyy @ HH:mm').format(date.toDate().toLocal())}"),
          Text(message, style: const TextStyle(fontSize: 18),),
        ],
      ),
    );
  }
}
