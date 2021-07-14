import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_alarm/screens/home_tabs/calender_screen.dart';
import 'package:med_alarm/screens/report/report_screen.dart';
import 'package:med_alarm/utilities/push_notifications.dart';
import 'package:med_alarm/utilities/scroll_behavior.dart';
import '/providers/user_provider.dart';
import '/screens/LoginFresh/login_fresh_screen.dart';
import '/screens/chat/chatroom_screen.dart';
import '/screens/chat/chats_screen.dart';
import '/screens/home_screen.dart';
import '/screens/search_contact_screen.dart';
import '/utilities/sql_helper.dart';
import '/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  //You have to create a list with the type of login's that you are going to import into your application

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    PushNotificationsManager().init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedAlarm',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
      home: _getLandingPage(),
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        BuildLoginFresh.id: (context) => BuildLoginFresh(),
        CalendarScreen.id: (context) => CalendarScreen(),
        SearchContact.id: (context) => SearchContact(),
        ChatRoom.id: (context) => ChatRoom(),
        ChatsScreen.id: (context) => ChatsScreen(),
        ReportScreen.id: (context) => ReportScreen(),
      },
    );
  }

  Widget _getLandingPage() {
    return FutureBuilder<User> (
      future: SQLHelper.getInstant().getUser(),
      builder: (context, snapShot) {
        if(Auth.FirebaseAuth.instance.currentUser == null)
          return Scaffold(body: BuildLoginFresh());
        else if(snapShot.hasError)
          return Scaffold(body: BuildLoginFresh());
        // else if(snapShot.data == null)
        //   return Scaffold(body: BuildLoginFresh());
        else if (snapShot.hasData) {
          try {
            if (Auth.FirebaseAuth.instance.currentUser.email ==
                snapShot.data.email) {
              // if (Users.patientUser) {
              UserProvider.instance.currentUser = snapShot.data;
              return HomeScreen();
            }
            else
              return Scaffold(body: Center(child: CircularProgressIndicator()));
              // return Scaffold(body: BuildLoginFresh());
          } catch(e) {
            return Scaffold(body: BuildLoginFresh());
          }
        }
        else
          return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );

  }
}
