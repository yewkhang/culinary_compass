import 'dart:io';
import 'dart:typed_data';

import 'package:culinary_compass/authenticate/create_username.dart';
import 'package:culinary_compass/authenticate/signin.dart';
import 'package:culinary_compass/main.dart';
import 'package:culinary_compass/navigation_menu.dart';
import 'package:culinary_compass/pages/groupinfo_page.dart';
import 'package:culinary_compass/pages/groups_page.dart';
import 'package:culinary_compass/pages/home.dart';
import 'package:culinary_compass/pages/logging_page.dart';
import 'package:culinary_compass/pages/settings_page.dart';
import 'package:culinary_compass/pages/socials_page.dart';
import 'package:culinary_compass/pages/yourlogs_page.dart';
import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';



// test account 1: testtesttest@test.com 1234567890
// test account 2: test1@test.com 1234567890 (has one existing log "Hamburger")

void main() {

  LiveTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: "testing",
        options: const FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: 'fake-app-id',
          messagingSenderId: 'fake-messaging-sender-id',
          projectId: 'fake-project-id',
        ),
      );
    }
  });


  // CLICK ON RUN OVER MAIN(): DESIGNED TO RUN ALL TOGETHER SEQUENTIALLY, BUT INITIALLY TESTED AS STANDALONE

  // 1111111111111111111111111111111111111111111111111111111111111111111111111111111111
  
  group('Auth Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    // late FakeFirebaseFirestore fakeFirestore;
    // late MockGoogleSignIn mockGoogleSignIn;
    late FakeImagePicker fakeImagePicker;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      fakeImagePicker = FakeImagePicker();

      // fakeFirestore = FakeFirebaseFirestore();
      // mockGoogleSignIn = MockGoogleSignIn();
            // filling in food logging fields
      when(() => fakeImagePicker.pickImage(source: ImageSource.gallery))
        .thenAnswer(
          (_) async {
            final ByteData data = await rootBundle.load('lib/images/spaghetti_integrationtesting.jpg');
            final Uint8List bytes = data.buffer.asUint8List();
            final Directory tempDir = await getTemporaryDirectory();
            final File file = await File(
              '${tempDir.path}/doc.png',
            ).writeAsBytes(bytes);

            return XFile(file.path);
          }
        );
    });

    int number = 0;


    // ------------- Testing Signing In with Email and Password and Logging Out ------------- //
    testWidgets('Login with email and password, then logout', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      // enter email and password
      await tester.enterText(find.byKey(Key("EmailField")), "testtesttest@test.com");
      await tester.enterText(find.byKey(Key("PasswordField")), "1234567890");

      // clicking on sign-in button
      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      // expecting that the user is signed in
      expect(find.byType(NavigationMenu), findsOneWidget);

      // clicking on settings icon and logout button
      await tester.tap(find.text("Settings"));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.tap(find.text("Log Out"));
      await tester.pumpAndSettle();
      expect(find.byType(SignIn), findsOneWidget);


    });
    // ------------- Testing Signing In with Email and Password and Logging Out ------------- //





    // ------------- Testing Registering with Email and Password ------------- //
    testWidgets('Registering with email and password', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      // clicking on Register button
      await tester.tap(find.text("Register Now!"));
      await tester.pumpAndSettle();

      // enter email and password
      await tester.enterText(find.byKey(Key("EmailFieldRegister")), "testaccount$number@test.com");
      await tester.enterText(find.byKey(Key("PasswordFieldRegister")), "1234567890");
      await tester.enterText(find.byKey(Key("ConfirmPasswordFieldRegister")), "1234567890");

      // clicking on sign-in button
      await tester.tap(find.text("Register"));
      await tester.pumpAndSettle();

      // expecting that the user is reaches the username creation page
      expect(find.byType(CreateUsernamePage), findsOneWidget);
      
      // enter username
      await tester.enterText(find.byKey(Key("CreateUsername")), "testaccount$number");
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1));
      await tester.tap(find.text("Create Username"));
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));
      await tester.pumpAndSettle;

      // expecting that the user is signed in
      expect(find.byType(NavigationMenu), findsOneWidget);

      // clicking on settings icon and logout button
      await tester.tap(find.text("Settings"));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.tap(find.text("Log Out"));
      await tester.pumpAndSettle();
      expect(find.byType(SignIn), findsOneWidget);
    });
    // ------------- Testing Registering with Email and Password ------------- //
  });

  group('Add/Delete Friend Test', () {
    late MockFirebaseAuth mockFirebaseAuth;
    // late FakeFirebaseFirestore fakeFirestore;
    // late MockGoogleSignIn mockGoogleSignIn;
    late FakeImagePicker fakeImagePicker;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      fakeImagePicker = FakeImagePicker();

      // fakeFirestore = FakeFirebaseFirestore();
      // mockGoogleSignIn = MockGoogleSignIn();
    });

    // ------------- Testing Adding Friends after Logging In ------------- //
    testWidgets('Adding Friends', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );
      
      // enter email and password
      await tester.enterText(find.byKey(Key("EmailField")), "testtesttest@test.com");
      await tester.enterText(find.byKey(Key("PasswordField")), "1234567890");

      // clicking on sign-in button
      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      // expecting that the user is signed in
      expect(find.byType(NavigationMenu), findsOneWidget);

      // clicking on social icon and add_friends button
      await tester.tap(find.text("Social"));
      await tester.pumpAndSettle();
      expect(find.byType(SocialsPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_add_alt_1));
      await tester.pumpAndSettle();
      expect(find.byType(AddFriendsCreateGroupsDialog), findsOneWidget);

      // enter test account name to add friend, and click on "Add Friend" button
      await tester.enterText(find.byKey(Key("AddFriendsTextField")), "HaPS3hZsyaXziFIiNyIZKYBViui2"); // uid of qwerty@aaa.com
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text("Add Friend"));
      // to get rid of Get.back() dialog closing animation
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // check if friend is successfully added
      expect(find.text("qwerty"), findsAny);

    });
    // ------------- Testing Adding Friends after Logging In ------------- //





    // ------------- Testing Deleting Friends after Logging In ------------- //
    testWidgets('Deleting Friends', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load
      
      // navigating to socials page
      await tester.tap(find.text("Social"));
      await tester.pumpAndSettle();
      expect(find.byType(SocialsPage), findsOneWidget);
      
      expect(find.text("qwerty"), findsOneWidget);

      // deleting friend
      await tester.tap(find.byKey(Key("DeleteFriendqwerty"))); // delete icon
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("RemoveFriendButton"))); // delete icon
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text("qwerty"), findsNothing);

    });
  });

  group('Food Logging', () {
    late MockFirebaseAuth mockFirebaseAuth;
    // late FakeFirebaseFirestore fakeFirestore;
    // late MockGoogleSignIn mockGoogleSignIn;
    late FakeImagePicker fakeImagePicker;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      fakeImagePicker = FakeImagePicker();

      // fakeFirestore = FakeFirebaseFirestore();
      // mockGoogleSignIn = MockGoogleSignIn();
    });
    

    // ------------- Testing Creating Food Log Successfully ------------- //
    testWidgets('Creating Food Log and Viewing Food Log', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      /*    
      // enter email and password
      await tester.enterText(find.byKey(Key("EmailField")), "testtesttest@test.com");
      await tester.enterText(find.byKey(Key("PasswordField")), "1234567890");

      // clicking on sign-in button
      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      // expecting that the user is signed in
      expect(find.byType(NavigationMenu), findsOneWidget);
    */

      // clicking on Log (camera icon)
      await tester.tap(find.text("Log"));
      await tester.pumpAndSettle();
      expect(find.byType(LoggingPage), findsOneWidget);
      
      // filling in food logging fields
      when(() => fakeImagePicker.pickImage(source: ImageSource.gallery))
        .thenAnswer(
          (_) async {
            final ByteData data = await rootBundle.load('lib/images/spaghetti_integrationtesting.jpg');
            final Uint8List bytes = data.buffer.asUint8List();
            final Directory tempDir = await getTemporaryDirectory();
            final File file = await File(
              '${tempDir.path}/doc.png',
            ).writeAsBytes(bytes);

            return XFile(file.path);
          }
        );

      // Photo
      await tester.tap(find.byIcon(Icons.photo));
      await tester.pumpAndSettle();
      
      // Scrolling
      await tester.drag(find.byType(LoggingPage), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Dish Name
      await tester.enterText(find.byKey(Key("DishName")), "Steak");

      // Location
      await tester.enterText(find.byKey(Key("Location")), "The Feather Blade, Singapore");
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.tap(find.byKey(Key("ListTile0"))); // tapping on location suggestions
      await tester.pumpAndSettle();

      // Scrolling
      await tester.drag(find.byType(LoggingPage), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Tags
      await tester.enterText(find.byKey(Key("Tags")), "Ameri");
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile)); // tapping on tag suggestions ("American")
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard
      await tester.pump(const Duration(milliseconds: 500));

      // Description + Scrolling
      await tester.enterText(find.byKey(Key("Description")), "Really nice!");
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 500));

      // Rating Bar
      await tester.ensureVisible(find.byType(RatingBar));
      await tester.pumpAndSettle();
      final ratingBarFinder = find.byType(RatingBar);
      await tester.longPress(ratingBarFinder);
      await tester.pumpAndSettle();

      // Save Log
      await tester.tap(find.text("Save"));
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));
      // await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // clicking on Past Logs Page (book icon)
      await tester.tap(find.text("Your Logs"));
      await tester.pumpAndSettle();
      expect(find.byType(YourlogsPage), findsOneWidget);
      expect(find.text("Steak"), findsOneWidget);


    });
    // ------------- Testing Creating Food Log Successfully ------------- //





    // ------------- Testing Filtering and Editing Log ------------- //
    testWidgets('Filtering Food Log and Editing', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      // clicking on Past Logs Page (book icon)
      await tester.tap(find.text("Your Logs"));
      await tester.pumpAndSettle();
      expect(find.byType(YourlogsPage), findsOneWidget);
      expect(find.text("Steak"), findsOneWidget);

      ////////// FILTERING //////////
      // Click on filter button
      await tester.tap(find.byIcon(Icons.filter_alt));
      await tester.pumpAndSettle();

      // Filter by "Chinese", should have no results
      await tester.tap(find.byKey(Key('🇨🇳 Chinese')));
      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.text("Steak"), findsNothing);

      // Click on filter button
      await tester.tap(find.byIcon(Icons.filter_alt));
      await tester.pumpAndSettle();

      // Now remove filter, drag filters, filter by "American", should have results
      await tester.tap(find.text("Clear Tags"));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.dragUntilVisible(find.byKey(Key('🇺🇸 American')), find.byKey(Key("FilteringListView")), const Offset(-100, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('🇺🇸 American')));
      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.text("Steak"), findsAny);


      ////////// EDITING //////////
      // Click on food log to edit
      await tester.tap(find.text("Steak"));
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1));

      // Editing name as part of testing
      await tester.enterText(find.byKey(Key("DishName")), "");
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key("DishName")), "Spaghetti");
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 500));

      // Scrolling down
      await tester.drag(find.byType(LoggingPage), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Editing description as part of testing
      await tester.enterText(find.byKey(Key("Description")), "");
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key("Description")), "Not so good.");
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 500));

      // Update Log
      await tester.tap(find.text("Update"));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text("Spaghetti"), findsOneWidget);
      expect(find.text("Steak"), findsNothing);

    });
    // ------------- Testing Filtering and Editing Log ------------- //





    // ------------- Testing Deleting Log Successfully ------------- //
    testWidgets('Deleting Food Log', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load
      
      // clicking on Past Logs Page (book icon)
      await tester.tap(find.text("Your Logs"));
      await tester.pumpAndSettle();
      expect(find.byType(YourlogsPage), findsOneWidget);
      expect(find.text("Spaghetti"), findsOneWidget);

      // Drag log to tap on delete
      await tester.drag(find.text("Spaghetti"), const Offset(-200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byKey(Key("DeleteLog")));
      await tester.pumpAndSettle();

      expect(find.text("Spaghetti"), findsNothing);
      expect(find.text("Steak"), findsNothing);

    });
    // ------------- Testing Deleting Log Successfully ------------- //





    // ------------- Testing Viewing All Logs (Including from Friends) ------------- //
    testWidgets('Viewing Food Logs from user and friend, from Home Page', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      /*
      // enter email and password
      await tester.enterText(find.byKey(Key("EmailField")), "testtesttest@test.com");
      await tester.enterText(find.byKey(Key("PasswordField")), "1234567890");

      // clicking on sign-in button
      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      // expecting that the user is signed in
      expect(find.byType(NavigationMenu), findsOneWidget);
      */

      ////////// CREATING OWN FOOD LOG AGAIN
      // clicking on Log (camera icon)
      await tester.tap(find.text("Log"));
      await tester.pumpAndSettle();
      expect(find.byType(LoggingPage), findsOneWidget);
      
      // filling in food logging fields
      when(() => fakeImagePicker.pickImage(source: ImageSource.gallery))
        .thenAnswer(
          (_) async {
            final ByteData data = await rootBundle.load('lib/images/spaghetti_integrationtesting.jpg');
            final Uint8List bytes = data.buffer.asUint8List();
            final Directory tempDir = await getTemporaryDirectory();
            final File file = await File(
              '${tempDir.path}/doc.png',
            ).writeAsBytes(bytes);

            return XFile(file.path);
          }
        );

      // Photo
      await tester.tap(find.byIcon(Icons.photo));
      await tester.pumpAndSettle();
      
      // Scrolling
      await tester.drag(find.byType(LoggingPage), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Dish Name
      await tester.enterText(find.byKey(Key("DishName")), "Steak");

      // Location
      await tester.enterText(find.byKey(Key("Location")), "The Feather Blade, Singapore");
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.tap(find.byKey(Key("ListTile0"))); // tapping on location suggestions
      await tester.pumpAndSettle();

      // Scrolling
      await tester.drag(find.byType(LoggingPage), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Tags
      await tester.enterText(find.byKey(Key("Tags")), "Ameri");
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile)); // tapping on tag suggestions ("American")
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard
      await tester.pump(const Duration(milliseconds: 500));

      // Description + Scrolling
      await tester.enterText(find.byKey(Key("Description")), "Really nice!");
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 500));

      // Rating Bar
      await tester.ensureVisible(find.byType(RatingBar));
      await tester.pumpAndSettle();
      final ratingBarFinder = find.byType(RatingBar);
      await tester.longPress(ratingBarFinder);
      await tester.pumpAndSettle();

      // Save Log
      await tester.tap(find.text("Save"));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();


      ////////// ADDING FRIEND (WITH 1 EXISTING FOOD LOG)
      // clicking on social icon and add_friends button
      await tester.tap(find.text("Social"));
      await tester.pumpAndSettle();
      expect(find.byType(SocialsPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_add_alt_1));
      await tester.pumpAndSettle();
      expect(find.byType(AddFriendsCreateGroupsDialog), findsOneWidget);

      // enter test account name to add friend, and click on "Add Friend" button
      await tester.enterText(find.byKey(Key("AddFriendsTextField")), "BYGLBVz9FHYWFwZGCo8ImhkbjTM2"); // uid of test1@test.com
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text("Add Friend"));
      // to get rid of Get.back() dialog closing animation
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // check if friend is successfully added
      expect(find.text("test1"), findsAny);

      // clicking on Home Page (home icon)
      await tester.tap(find.text("Home"));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      // clicking on Search Bar ("Search friend recommendations")
      await tester.tap(find.text("Search friend recommendations"));
      await tester.pumpAndSettle();
      expect(find.byType(YourlogsPage), findsOneWidget); // with fromHomePage == true

      // to load
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));

      expect(find.text("Steak"), findsAny); // expect to find own created Food Log
      expect(find.text("Hamburger"), findsOneWidget); // expect to find friend's Food Log "Hamburger"

      // exit out of the current logs page
      await tester.tapAt(const Offset(20, 50));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

    });
    // ------------- Testing Viewing All Logs (Including from Friends) ------------- //

  });



  group('Home Page Tests - Places to Try', () {
    late MockFirebaseAuth mockFirebaseAuth;
    // late FakeFirebaseFirestore fakeFirestore;
    // late MockGoogleSignIn mockGoogleSignIn;
    late FakeImagePicker fakeImagePicker;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      fakeImagePicker = FakeImagePicker();

      // fakeFirestore = FakeFirebaseFirestore();
      // mockGoogleSignIn = MockGoogleSignIn();
    });


    // ------------- Testing Adding, Viewing and Deleting Places To Try ------------- //
    testWidgets('Adding, Viewing and Deleting Places to Try', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      /*
      // enter email and password
      await tester.enterText(find.byKey(Key("EmailField")), "testtesttest@test.com");
      await tester.enterText(find.byKey(Key("PasswordField")), "1234567890");

      // clicking on sign-in button
      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      // expecting that the user is signed in
      expect(find.byType(NavigationMenu), findsOneWidget);
      */

      ////////// ADDING PLACES TO TRY
      // clicking on + button to add places to try
      await tester.tap(find.byKey(Key("AddPlacesToTry")));
      await tester.pumpAndSettle();

      // Dish Name
      await tester.enterText(find.byKey(Key("DishNamePlacesToTry")), "Fish");

      // Dish Location
      await tester.enterText(find.byKey(Key("DishLocationPlacesToTry")), "Crystal Jade Orchard Road");
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.tap(find.byKey(Key("ListTilePlacesToTry2"))); // tapping on location suggestions
      await tester.pumpAndSettle();
      
      // Comments
      await tester.enterText(find.byKey(Key("CommentsPlacesToTry")), "Been waiting!");
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 1000));

      // Add places to try
      await tester.tap(find.text("Add place"));
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text("Fish"), findsAny);

      // To view comments
      await tester.tap(find.text("Fish"));
      await tester.pumpAndSettle();

      expect(find.text("Been waiting!"), findsAny);

      ////////// DELETING PLACES TO TRY
      // To close comments
      await tester.tap(find.text("Fish"));
      await tester.pumpAndSettle();

      // Drag places-to-try pane to tap on delete
      await tester.drag(find.text("Fish"), const Offset(-200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byKey(Key("DeletePlacesToTry"),));
      await tester.pumpAndSettle();

      expect(find.text("Fish"), findsNothing);
      
    });
    // ------------- Testing Adding, Viewing and Deleting Places To Try ------------- //

  });







  group('Social Group Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    // late FakeFirebaseFirestore fakeFirestore;
    // late MockGoogleSignIn mockGoogleSignIn;
    late FakeImagePicker fakeImagePicker;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      fakeImagePicker = FakeImagePicker();

      // fakeFirestore = FakeFirebaseFirestore();
      // mockGoogleSignIn = MockGoogleSignIn();
    });


    // ------------- Testing Creating Social Group and Sending Message ------------- //
    testWidgets('Creating Social Group and Sending Message', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      /*
      // enter email and password
      await tester.enterText(find.byKey(Key("EmailField")), "testtesttest@test.com");
      await tester.enterText(find.byKey(Key("PasswordField")), "1234567890");

      // clicking on sign-in button
      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      // expecting that the user is signed in
      expect(find.byType(NavigationMenu), findsOneWidget);
      */

      // clicking on social icon
      await tester.tap(find.text("Social"));
      await tester.pumpAndSettle();
      expect(find.byType(SocialsPage), findsOneWidget);
      expect(find.text("test1"), findsOneWidget); // created in earlier test

      // navigating to the groups tabview
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsList), findsOneWidget);

      // clicking on add_friends button
      await tester.tap(find.byIcon(Icons.person_add_alt_1));
      await tester.pumpAndSettle();
      expect(find.byType(AddFriendsCreateGroupsDialog), findsOneWidget);

      // navigating to the create_groups tabview
      await tester.tap(find.text("Create Groups"));
      await tester.pumpAndSettle();
      expect(find.byType(CreateGroupDialog), findsOneWidget);

      // enter group name
      await tester.enterText(find.byKey(Key("GroupName")), "Test Group");

      // adding friend
      await tester.enterText(find.byKey(Key("GroupEnterUsername")), "test1"); // friend's username
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("GroupEnterUsernameListTiletest1")));
      await tester.pumpAndSettle();

      // create group
      await tester.tap(find.byKey(Key("CreateGroupButton")));
      await tester.pumpAndSettle();
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // "bug" while testing: need to scroll to groups page from friends page
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsList), findsOneWidget);

      expect(find.text("Test Group"), findsOneWidget);

      // tap into group and send message
      await tester.tap(find.text("Test Group"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsPage), findsOneWidget);

      await tester.enterText(find.byKey(Key("GroupMessageTextField")), "Hello!");
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus(); // close keyboard to tap
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.tap(find.byKey(Key("GroupSendMessageButton")));
      await tester.pumpAndSettle();

      expect(find.byKey(Key("testtesttest Hello!")), findsOneWidget); // ChatBubble message sent

    });
    // ------------- Testing Creating Social Group and Sending Message ------------- //





    // ------------- Testing Sending Food Recommendations to Group ------------- //
    testWidgets('Sending Food Recommendations to Group', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      // clicking on social icon
      await tester.tap(find.text("Social"));
      await tester.pumpAndSettle();
      expect(find.byType(SocialsPage), findsOneWidget);
      expect(find.text("test1"), findsOneWidget); // created in earlier test

      // need to renavigate to group page
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsList), findsOneWidget);
      await tester.tap(find.text("Test Group"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsPage), findsOneWidget);

      // tapping on recommendations button and sending own recommendation "Hamburger"
      await tester.tap(find.byIcon(Icons.recommend_rounded));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Hamburger"));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("GroupSendMessageButton")));
      await tester.pumpAndSettle();

      expect(find.byType(ChatBubble), findsNWidgets(2));


      // exit out of the group page
      await tester.tapAt(const Offset(20, 50));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsList), findsOneWidget);

    });
    // ------------- Testing Sending Food Recommendations to Group ------------- //
    





    // ------------- Testing Adding New Friend to Group ------------- //
    testWidgets('Adding New Friend to Group', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      // clicking on social icon
      await tester.tap(find.text("Social"));
      await tester.pumpAndSettle();
      expect(find.byType(SocialsPage), findsOneWidget);
      expect(find.text("test1"), findsOneWidget); // created in earlier test

      ////////// ADDING ONE MORE FRIEND (from above)
      await tester.tap(find.byIcon(Icons.person_add_alt_1));
      await tester.pumpAndSettle();
      expect(find.byType(AddFriendsCreateGroupsDialog), findsOneWidget);

      // enter test account name to add friend, and click on "Add Friend" button
      await tester.enterText(find.byKey(Key("AddFriendsTextField")), "HaPS3hZsyaXziFIiNyIZKYBViui2"); // uid of qwerty@aaa.com
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text("Add Friend"));
      // to get rid of Get.back() dialog closing animation
      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // check if friend is successfully added
      expect(find.text("qwerty"), findsOneWidget);

      ////////// ADDING FRIEND TO GROUP
      // small testing "bug" (need to renavigate to group page)
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsList), findsOneWidget);
      await tester.tap(find.text("Test Group"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsPage), findsOneWidget);

      // tap into Group Info page
      await tester.tap(find.text("Test Group"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupInfoPage), findsOneWidget);

      // in Group Info page, adding friend
      await tester.tap(find.text("Add Members"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key("GroupAddFriendDialog")), "qwerty");
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("GroupAddFriendDialogListTileqwerty")));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("GroupAddFriendDialogButton")));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      expect(find.text("qwerty"), findsOneWidget);

      // exit out of the group info page and group page
      await tester.tapAt(const Offset(20, 50));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsPage), findsOneWidget);
      await tester.tapAt(const Offset(20, 50));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsList), findsOneWidget);


    });
    // ------------- Testing Adding New Friend to Group ------------- //





    // ------------- Testing Leaving Group ------------- //
    testWidgets('Leaving Group', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker),
        ),
      );

      await tester.pumpFrames(MyApp(auth: AuthService(auth: mockFirebaseAuth), imagePicker: fakeImagePicker), const Duration(seconds: 1)); // to allow app to load

      // clicking on social icon
      await tester.tap(find.text("Social"));
      await tester.pumpAndSettle();
      expect(find.byType(SocialsPage), findsOneWidget);
      expect(find.text("test1"), findsOneWidget); // created in earlier test

      // small testing "bug" (need to renavigate to group page)
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.byType(GroupsList), findsOneWidget);
      expect(find.text("Test Group"), findsOneWidget);
      
      // Drag group to tap on delete
      await tester.drag(find.text("Test Group"), const Offset(-200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byKey(Key("LeaveGroupButton")));
      await tester.pumpAndSettle();

      expect(find.text("Test Group"), findsNothing);

    });
    // ------------- Testing Testing Leaving Group ------------- //

  });
}


class FakeImagePicker extends Mock implements ImagePicker {
  /*
  @override
  Future<XFile?> pickImage({
    int? imageQuality,
    double? maxHeight,
    double? maxWidth,
    CameraDevice? preferredCameraDevice,
    bool? requestFullMetadata,
    required ImageSource source
  }) async {
    final ByteData data = await rootBundle.load('lib/images/spaghetti_integrationtesting.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final Directory tempDir = await getTemporaryDirectory();
    final File file = await File(
      '${tempDir.path}/doc.png',
    ).writeAsBytes(bytes);

    return XFile(file.path);
  }
  */
}

class FakeImagePickerPlatform extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    final ByteData data = await rootBundle.load('lib/images/spaghetti_integrationtesting.jph');
    final Uint8List bytes = data.buffer.asUint8List();
    final Directory tempDir = await getTemporaryDirectory();
    final File file = await File(
      '${tempDir.path}/doc.png',
    ).writeAsBytes(bytes);

    return XFile(file.path);
  }

  @override
  Future<List<XFile>> getMultiImageWithOptions({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    final ByteData data = await rootBundle.load('assets/home/binoculars.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Directory tempDir = await getTemporaryDirectory();
    final File file = await File(
      '${tempDir.path}/binoculars.png',
    ).writeAsBytes(bytes);
    return <XFile>[
      XFile(
        file.path,
      )
    ];
  }
}