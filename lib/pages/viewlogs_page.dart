import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
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
            // Image
            SizedBox(
              width: 450,
              height: 390,
              child: Image.network(
                document['Picture'],
                fit: BoxFit.cover,
              ),
            ),
            // Rating + Name
            Padding(
              padding: const EdgeInsets.only(
                  top: CCSizes.spaceBtwItems,
                  right: CCSizes.spaceBtwItems,
                  left: CCSizes.spaceBtwItems),
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
            // Location
            Padding(
              padding: const EdgeInsets.only(
                  top: 10,
                  right: CCSizes.spaceBtwItems,
                  left: CCSizes.spaceBtwItems),
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
            // Tags
            Padding(
              padding: const EdgeInsets.only(
                  top: 10,
                  right: CCSizes.spaceBtwItems,
                  left: CCSizes.spaceBtwItems),
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
                            .map<Widget>((element) =>
                                CCTagsContainer(label: Text(element)))
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
                  left: CCSizes.spaceBtwItems,
                  right: CCSizes.spaceBtwItems),
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
          ]),
        ));
  }
}
