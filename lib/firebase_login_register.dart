import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_register/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Auth extends StatefulWidget {
  final Widget appIcon;
  final Widget appName;
  final DecorationImage googleImage;
  final DecorationImage facebookImage;
  final DecorationImage emailImage;
  final Widget loadingWidget;
  final String userDataBaseName;
  final AssetImage backgroundImageAsset;
  final Widget completeRegisterPage;


  Auth({ Key key,
    this.userDataBaseName,
    this.loadingWidget,
    this.appIcon,
    this.appName,
    this.googleImage,
    this.facebookImage,
    this.emailImage,
    this.backgroundImageAsset, this.completeRegisterPage
  }) : super(key: key);


  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<Auth> with TickerProviderStateMixin {
  @override
  void initState() {
    FirebaseAuth.instance
        .currentUser()
        .then((currentUser) =>
    {
      if (currentUser == null)
        {Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => LoginScreen(
              appIcon: widget.appIcon,
              appName: widget.appName,
              emailImage: widget.emailImage,
              googleImage: widget.googleImage,
              facebookImage: widget.facebookImage,
              databaseName: widget.userDataBaseName,
              backgroundImageAsset: widget.backgroundImageAsset,
              container: widget.completeRegisterPage,
            )),)}
      else
        {
          Firestore.instance.collection(widget.userDataBaseName).document(currentUser.uid)
              .get()
              .then((value) =>
          (value['CompleteRegister'] == true ||
              value['CompleteRegister'] != null) ?
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ) : Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CompleteRegistration(container:widget.completeRegisterPage,isNumber:false,data:"")),
          )
          ),
        }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: widget.loadingWidget,
      ),
    );
  }
}