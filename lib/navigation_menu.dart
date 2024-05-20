import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80, // height of navigation bar
          elevation: 0,
          selectedIndex: controller.selectedIndex.value, //access int wrapped in Rx context
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.book), label: 'Past Logs'),
            NavigationDestination(icon: Icon(Icons.camera), label: 'Log'),
            NavigationDestination(icon: Icon(Icons.people), label: 'Groups'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  // observed current navigation page index
  final Rx<int> selectedIndex = 0.obs; // integer value wrapped in Rx context

  // Change when screens are created
  final screens = [
    Container(color: Colors.green),
    Container(color: Colors.amber),
    Container(color: Colors.blue),
    Container(color: Colors.orange),
    Container(color: Colors.purple)
  ];
}