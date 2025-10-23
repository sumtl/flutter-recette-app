import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Uncomment when enabling Firebase
import 'Views/app_main_screen.dart';

/// Entry point of the application.
void main() async {
  // Ensures Flutter bindings are initialized before calling native code
  // (needed when using async initialization like Firebase).
  WidgetsFlutterBinding.ensureInitialized();

  // If you use Firebase, initialize it here:
  // await Firebase.initializeApp();

  // Start the Flutter application by inflating the widget tree.
  runApp(const MyApp());
}

/// Root widget of the application.
/// Using a StatelessWidget because this widget itself does not hold mutable state.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the top-level widget that configures
    // theme, navigation, localization, and other app-level settings.
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner in debug mode
      home: AppMainScreen(), // The first screen shown to the user
    );
  }
}
