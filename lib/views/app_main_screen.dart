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

// State class for AppMainScreen.
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
      body: selectedIndex == 0
          ? MyAppHomeScreen()
          : Center(child: Text("Page index: $selectedIndex")),
    );
  }
}

// Home page of the app shown when the "Home" tab is selected.
class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({Key? key}) : super(key: key);

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

// State class for MyAppHomeScreen.
class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  // currently selected category shown on the Home page; defaults to "All"
  String selectedCategory = "All"; // holds the selected category name
  // list of available category labels used to render category UI later
  List<String> categories = ["All", "Dinner", "Lunch", "Breakfast"];

  @override
  Widget build(BuildContext context) {
    // SafeArea avoids intrusions by system UI (status bar / notches)
    return SafeArea(
      child: Column(
        // align children to the left edge of the column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // outer padding to add horizontal spacing on both sides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // header row (title + notification button)
                headerParts(),
                // spacing between header and search
                SizedBox(height: 20),
                // search input widget (rounded TextField)
                mySearchBar(),
                // spacing between search and banner
                SizedBox(height: 20),
                // banner widget that promotes exploring recipes
                const BannerToExplore(),
                // section label for categories with vertical padding
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ), // EdgeInsets.symmetric
                  child: Text(
                    // visible section title string
                    "Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ), // TextStyle
                  ), // Text
                ), // Padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper that builds the header row containing the title and icon（NO reusable）
  Padding headerParts() {
    return Padding(
      // vertical spacing around the header
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // main multi-line title text on the left
          Text(
            "What are you\ncooking today?",
            style: TextStyle(
              fontSize: 32, // large headline size
              fontWeight: FontWeight.bold, // bold weight for emphasis
              color: Colors.black, // explicit color (overrides theme)
              height: 1, // line height multiplier (tight lines)
            ),
          ),
          // spacer pushes the next widget to the far right
          Spacer(),
          // notification icon button (currently no-op)
          IconButton(
            onPressed: () {}, // TODO: implement notification action
            style: IconButton.styleFrom(
              fixedSize: Size(55, 55), // square tappable area
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: Icon(Iconsax.notification),
          ),
        ],
      ),
    );
  }

  // Small helper returning a rounded search input container（NO reusable）
  Container mySearchBar() {
    return Container(
      width: double.infinity, // take all horizontal space available
      height: 60, // fixed height for the search bar
      decoration: BoxDecoration(
        color: Colors.grey[100], // light grey background
        borderRadius: BorderRadius.circular(30), // pill-shaped corners
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextField(
        // Uncontrolled TextField; if you need the value use a TextEditingController
        decoration: InputDecoration(
          hintText: "Search any recipes", // placeholder text
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: Colors.grey,
          ), // magnifier icon
          border:
              InputBorder.none, // removes TextField border (we use Container)
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

// Small promotional banner widget shown in the Home page
class BannerToExplore extends StatelessWidget {
  const BannerToExplore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // stretch horizontally
      height: 170, // fixed height for the banner
      decoration: BoxDecoration(
        color: Color(0xFF71B77A), // green background color
        borderRadius: BorderRadius.circular(15), // rounded corners
      ),
      child: Stack(
        children: [
          // Left side column: headline and CTA button
          Positioned(
            top: 32,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cook the best\nrecipes at home", // headline
                  style: TextStyle(
                    height: 1.1, // line height for the two lines
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // contrast on the green bg
                  ),
                ),
                SizedBox(height: 10), // spacing between text and button
                ElevatedButton(
                  onPressed: () {}, // TODO: navigate to explore page
                  child: Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF71B77A), // matches banner color
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // white CTA background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right side image: chef graphic loaded from network
          Positioned(
            top: 0,
            bottom: 0,
            right: -20, // offset to let the image overflow slightly
            // child: Image.network(
            //   "https://pngimg.com/d/chef_PNG190.png",
            //   width: 180, // fixed display width for the image
            // ),
            child: Image.asset(
              "assets/images/chef.png",
              width: 180, // fixed display width for the image
            ),
          ),
        ],
      ),
    );
  }
}
