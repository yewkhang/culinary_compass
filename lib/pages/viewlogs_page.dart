import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ViewlogsPage extends StatelessWidget {
  final Map<String, dynamic> document;

  const ViewlogsPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "View Log",
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          backgroundColor: CCColors.primaryColor,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              width: 450,
              height: 390,
              child: Image.network(
                document['Picture'],
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: CCSizes.defaultSpace,
                  right: CCSizes.defaultSpace,
                  left: CCSizes.defaultSpace),
              child: CardContainer(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          document['Rating'].toString(),
                          style: const TextStyle(fontSize: 24),
                        ),
                        RatingBarIndicator(
                          rating: document['Rating'],
                          itemCount: 5,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemSize: 15,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: CCSizes.defaultSpace,
                    ),
                    Expanded(
                      child: Text(
                        document['Name'],
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10,
                  right: CCSizes.defaultSpace,
                  left: CCSizes.defaultSpace),
              child: CardContainer(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_sharp,
                      color: CCColors.primaryColor,
                    ),
                    const SizedBox(width: CCSizes.spaceBtwItems),
                    Expanded(
                      child: Text(
                        document['Location'],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10,
                  right: CCSizes.defaultSpace,
                  left: CCSizes.defaultSpace),
              child: CardContainer(
                child: Row(
                  children: [
                    const Icon(
                      Icons.tag_sharp,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: CCSizes.spaceBtwItems),
                    Expanded(
                      child: Wrap(
                        runSpacing: 0,
                        children: document["Tags"]
                            .toList()
                            .map<Widget>(
                              (element) => Padding(
                                // padding between tags
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Chip(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.all(0),
                                  label: Text(element),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10,
                  left: CCSizes.defaultSpace,
                  right: CCSizes.defaultSpace),
              child: CardContainer(
                child: Row(
                  children: [
                    const Icon(
                      Icons.notes,
                      color: CCColors.primaryColor,
                    ),
                    const SizedBox(width: CCSizes.spaceBtwItems),
                    Expanded(
                      child: Text(
                        document['Description'],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Padding(
                padding: const EdgeInsets.all(CCSizes.defaultSpace),
                child: Text('Created by: username')),
          ]),
        ));
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child);
  }
}
