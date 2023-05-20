import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/screens/admin/add_doctor_screen.dart';
import 'package:palliative_care/screens/authentication/login.dart';
import 'package:palliative_care/screens/authentication/login_and_signup_screen.dart';
import 'package:palliative_care/screens/admin/home_screen_admin.dart';
import 'package:palliative_care/screens/authentication/signup.dart';
import 'package:palliative_care/screens/doctor/new_article_screen.dart';
import 'package:palliative_care/screens/doctor/page_view.dart';
import 'package:palliative_care/screens/joint/all_topics_screen.dart';
import 'package:palliative_care/screens/joint/all_users.dart';
import 'package:palliative_care/screens/patient/all_articles_screen.dart';
import 'package:palliative_care/screens/patient/page_view.dart';
import 'package:palliative_care/screens/joint/splash_screen.dart';
import 'package:palliative_care/shared_preference.dart';
import 'package:palliative_care/statemanagment/provider_topics.dart';
import 'package:palliative_care/statemanagment/provider_user.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferenceHelper.initSharedPreference();

  // This code just for ios and web
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Got a message whilst in the foreground! Any comment');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: Random().nextInt(1000),
              channelKey: subscribedTopicChannel,
              title: message.notification!.title,
              body: message.notification!.body,
              notificationLayout: NotificationLayout.Default
          ),
        );
      }
    }
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    SharedPreferenceHelper.saveToken(newToken);

    print('event onTokenRefresh is: $newToken');
  });


  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelKey: subscribedTopicChannel,
          channelName: 'Subscribed Topic',
          channelDescription: 'Notification channel for Subscribed Topic',
          defaultColor: const Color(0xFF9D50DD),
          playSound: true,
          channelShowBadge: true,
          defaultPrivacy: NotificationPrivacy.Public,
        ),

        NotificationChannel(
          channelKey: sendMessageChannel,
          channelName: 'Send Messages',
          channelDescription: 'Notification channel for Send Messages',
          defaultColor: const Color(0xFF9D50DD),
          playSound: true,
          channelShowBadge: true,
          defaultPrivacy: NotificationPrivacy.Private
        ),
      ],
      // debug: true
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TopicsProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          // ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,

          initialRoute: SplashScreen.id,
          routes: {
            SplashScreen.id: (context) => const SplashScreen(),
            LoginAndSignupScreen.id: (context) => const LoginAndSignupScreen(),
            LoginPageView.id: (context) => const LoginPageView(),
            SignupPageView.id: (context) => const SignupPageView(),
            HomeScreenAdmin.id: (context) => const HomeScreenAdmin(),
            PageViewDoctor.id: (context) => const PageViewDoctor(),
            AllArticlesScreen.id: (context) => const AllArticlesScreen(),
            NewArticleScreen.id: (context) => const NewArticleScreen(),
            PageViewPatient.id: (context) => const PageViewPatient(),
            AllTopicsScreen.id: (context) => const AllTopicsScreen(),
            AllUsersScreen.id: (context) => const AllUsersScreen(),
            AddDoctorScreen.id: (context) => const AddDoctorScreen(),
          },
        ),
      );
  }
}
