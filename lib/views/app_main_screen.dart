import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../constants.dart';

/// Main screen of the app that shows a BottomNavigationBar and a body.
///
/// This widget is Stateful because the selected tab index changes over time
/// and the UI needs to update when the user taps different navigation items.
class AppMainScreen extends StatefulWidget {
  const AppMainScreen({Key? key}) : super(key: key);

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  // Index of the currently selected bottom navigation item.
  // 0 represents the first tab ("Home") by default.
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic visual layout structure:
    // app bar, body, bottom navigation, floating action button, etc.
    return Scaffold(
      backgroundColor: Colors.white, // Screen background color
      bottomNavigationBar: BottomNavigationBar(
        // Visual styling for the BottomNavigationBar
        backgroundColor: Colors.white,
        elevation: 0, // Removes the drop shadow to keep a flat look
        iconSize: 28, // Size for the icons shown in the bar
        currentIndex: selectedIndex, // Highlights the active item
        selectedItemColor:
            kprimaryColor, // Color for active item (from constants)
        unselectedItemColor: Colors.grey, // Color for inactive items
        type:
            BottomNavigationBarType.fixed, // Keep labels visible for all items
        // Text style for the selected label. Note: color here is redundant
        // with selectedItemColor but helps with font weight.
        selectedLabelStyle: const TextStyle(
          color: kprimaryColor,
          fontWeight: FontWeight.w600,
        ),
        items: [
          // Each BottomNavigationBarItem has an icon and a label.
          // The first item (Home) uses a single icon.
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
          // For the next items we pick a filled or outlined variant depending
          // on whether it is the selected index. This creates a "pressed" effect.
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
            ),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 3 ? Iconsax.setting5 : Iconsax.setting),
            label: "Setting",
          ),
        ],
        // Handle taps on bottom navigation items. We call setState to update
        // the selectedIndex which triggers a rebuild and updates the UI.
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      // The body is simple for now — it displays the current page index.
      // In a real app you'd swap different pages or a PageView here.
      body: Center(child: Text("Page index: $selectedIndex")),
    );
  }
}
