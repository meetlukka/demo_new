import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';



FirebaseAnalytics analytics = FirebaseAnalytics();
void main() {
  runApp(MaterialApp(
    title: 'Deep Links Example',
    /* routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => MyHomeWidget(), // Default home route
    }, */
    home: MyHomeWidget(),
  ));
}

class MyHomeWidget extends StatefulWidget {
  @override
  MyHomeWidgetState createState() => MyHomeWidgetState();
}

class MyHomeWidgetState extends State<MyHomeWidget> {
  String _referrerDetails = "";
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }

  @override
  void initState() {
    super.initState();
    this.initUniLinks();
    this._retrieveDynamicLink();
    this.initReferrerDetails();

  }
//   @override
//   void initState() {
//  //   super.initState();

  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      print("this is initial link");
      print(initialLink);
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      // print('this is first deeplink $initialLink');
      // print(initialLink.runtimeType);
      // final queryParams = initialLink?.queryParametersAll?.entries?.toList();

      //  Uri url = Uri.parse(initialLink);
      //    print(url.queryParametersAll);
      //    print(url.queryParametersAll['param1']);
      //    print(url.runtimeType);

      var uri = Uri.dataFromString(initialLink); //converts string to a uri
      print(uri);
      print("this is initial link");
      print(initialLink);
      Map<String, String> params =
          uri.queryParameters; // query parameters automatically populated

      var utm_source = params[
          'utm_source']; // return value of parameter "utm_source" from uri
      var utm_medium = params[
          'utm_medium']; // return value of parameter "utm_medium" from uri
      var utm_term =
          params['utm_term']; // return value of parameter "utm_term" from uri
      var utm_content = params[
          'utm_content']; // return value of parameter "utm_content" from uri
      var utm_name =
          params['utm_name']; // return value of parameter "utm_name" from uri

      print("utm_source is $utm_source");
      print("utm_medium is $utm_medium");
      print("utm_term is $utm_term");
      print("utm_content is $utm_content");
      print("utm_name is $utm_name");
      // print("utm_source is $utm_source");
      // print("utm_medium is $utm_medium");
      // print("utm_term is $utm_term");
      // print("utm_content is $utm_content");
      // print("utm_name is $utm_name");

    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      print('no deep link');
    }
  }

  Future<void> _retrieveDynamicLink() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    
    if (deepLink != null) {
      print("Dynamic Link recieved");
      print("this is dynamic link"); //
      print(deepLink);
    }

    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (data) async {
        final Uri deepLink = data?.link;
        if (deepLink != null) {
          print("this is dynamic link"); // '/helloworld'
          print(deepLink);
        }
      },
      onError: (error) async {
        print("Error Occured: $error");
      },
    );
  }
  Future<void> initReferrerDetails() async {
    print("Install referrer api called");
    String referrerDetailsString;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      ReferrerDetails referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
      
      print("below is referrer of App");
      referrerDetailsString = referrerDetails.toString();
      var utm_medium = referrerDetails.installReferrer.split("&")[1].split("=")[1];
      var utm_source = referrerDetails.installReferrer.split("&")[0].split("=")[1];
      print(referrerDetailsString);
      print(referrerDetailsString);
//       print(referrerDetailsString.utm_source);
//       print(referrerDetailsString.utm_medium);
//       print(referrerDetailsString.utm_content);
//       print(referrerDetailsString.utm_term);
      FirebaseAnalytics().logEvent(name: 'Login', parameters: {
              'eventCategory': 'campaign tracking',
              'eventAction': 'campaign demo',
              'utm_source':utm_source,
              'utm_medium':utm_medium
});

    } catch (e) {
      referrerDetailsString = 'Failed to get referrer details: $e';
      print("error encountered");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _referrerDetails = referrerDetailsString;
    });
  }
}
