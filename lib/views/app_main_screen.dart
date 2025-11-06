import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import 'view_all_items.dart';

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
  // List<String> categories = ["All", "Dinner", "Lunch", "Breakfast"];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // SafeArea prevents content from being placed under status bar / notches.
    return SafeArea(
      child: Padding(
        // Horizontal padding for the whole page content.
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          // Align children to the left inside the column.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and notification icon.
            headerParts(), // note: this is a method returning a Widget (not a const).
            // Space between header and search bar.
            const SizedBox(height: 20),

            // Search bar widget (method returns a Widget).
            mySearchBar(),

            // Space between search and banner.
            const SizedBox(height: 20),

            // Promotional banner encouraging user to explore recipes.
            const BannerToExplore(),

            // Section title for categories with vertical padding.
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ), // EdgeInsets.symmetric
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,// space between title and possible action
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ), // TextStyle
                  ), // Text
                ],
              ),
            ),

            // Categories row: read category documents from Firestore and render.
            // We use a StreamBuilder to receive realtime updates.
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('categories').snapshots(),
              builder: (context, snapshot) {
                // While waiting for first data, show a small loading area with fixed height
                // so layout doesn't jump when data arrives.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Build a categories list starting with the "All" pseudo-category.
                final categories = <String>['All'];

                // If snapshot has data, extract each document's 'name' field.
                if (snapshot.hasData) {
                  for (final d in snapshot.data!.docs) {
                    // Convert to string and skip empty names.
                    final name = (d['name'] ?? '').toString();
                    if (name.isNotEmpty) categories.add(name);
                  }
                }

                // Render the horizontal category buttons.
                return categoryButtons(categories);
              },
            ),

            // Vertical spacing between categories and grid.
            const SizedBox(height: 20),

            // Popular Recipes section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular Recipes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewAllItems(categoryTitle: "Popular Recipes"),
                      ),
                    );
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                      fontSize: 14,
                      color: kprimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Grid of recipes — Expanded makes it fill the remaining vertical space.
            // Important: Scaffold provides bounded height so using Expanded is valid.
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Choose which query to run based on the selected category.
                // Limit to 4 recipes if "All" category is selected.
                stream: selectedCategory == "All"
                    ? _firestore.collection('details').limit(4).snapshots()
                    : _firestore
                          .collection('details')
                          .where('category', isEqualTo: selectedCategory)
                          .snapshots(),
                builder: (context, snapshot) {
                  // Loading state while query initializes.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // No-data state: show friendly message.
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No recipes found"));
                  }

                  // Data available: render a scrollable GridView.
                  // GridView scrolls independently inside the Expanded area.
                  return GridView.builder(
                    // Small padding at the bottom to avoid touching screen edge.
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    // Grid layout configuration: 2 columns with spacing.
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // two columns
                          crossAxisSpacing: 10, // horizontal gap between tiles
                          mainAxisSpacing: 10, // vertical gap between tiles
                          childAspectRatio: 0.8, // tile height/width ratio
                        ),
                    itemCount: snapshot.data!.docs.length, // number of recipes
                    itemBuilder: (context, index) {
                      // Grab a single recipe document.
                      final recipe = snapshot.data!.docs[index];

                      // Safely read fields and convert to String.
                      final img = (recipe['image'] ?? '').toString();
                      final name = (recipe['name'] ?? '').toString();
                      final time = (recipe['time'] ?? '').toString();
                      final cal = (recipe['cal'] ?? '0').toString();

                      // Card-like container for a recipe tile.
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image area: Expanded so image takes remaining vertical
                            // space inside the tile before the text section.
                            Expanded(
                              child: ClipRRect(
                                // Only top corners are rounded for the image.
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: img.isNotEmpty
                                    // If an image URL exists, load from network.
                                    // Note: on web this URL must allow CORS or use an asset/CDN that allows cross-origin requests.
                                    ? Image.network(img, fit: BoxFit.cover)
                                    // Fallback placeholder when there's no image URL.
                                    : Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            // Textual information area with padding.
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Recipe title (bold).
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  // Short description (muted color).
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.clock,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        time.isNotEmpty ? "$time Min" : "- Min",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Iconsax.flash_1,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$cal Cal",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ), // end Expanded
          ],
        ),
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

  // Helper method to build a horizontal row of category filter buttons
  // Each button represents a category and can be tapped to select it
  Widget categoryButtons(List<String> categories) {
    return Row(
      // horizontal layout for the buttons
      children: categories.map((category) {
        // map each category string to a button widget
        bool isSelected =
            selectedCategory ==
            category; // check if this category is currently selected
        return Padding(
          // add right margin between buttons
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            // make the container tappable
            onTap: () {
              // handle tap to select this category
              setState(() {
                // trigger UI rebuild to reflect selection change
                selectedCategory = category; // update the selected category
              });
            },
            child: Container(
              // styled button container
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ), // internal padding for text
              decoration: BoxDecoration(
                // visual styling for the button
                color: isSelected
                    ? kprimaryColor
                    : Colors.grey[200], // highlight if selected
                borderRadius: BorderRadius.circular(25), // rounded pill shape
              ),
              child: Text(
                // category label text
                category, // display the category name
                style: TextStyle(
                  // text styling
                  color: isSelected
                      ? Colors.white
                      : Colors.grey[600], // contrast color based on selection
                  fontWeight: FontWeight.w600, // semi-bold weight
                  fontSize: 14, // readable font size
                ),
              ),
            ),
          ),
        );
      }).toList(), // convert the mapped widgets to a list
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
