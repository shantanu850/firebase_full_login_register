library firebase_full_login_register_web;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_full_login_register_web/mainScreen.dart';

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
  final Widget homePage;


  Auth({ Key key,
    this.userDataBaseName,
    this.loadingWidget,
    this.appIcon,
    this.appName,
    this.googleImage,
    this.facebookImage,
    this.emailImage,
    this.backgroundImageAsset,
    this.completeRegisterPage,
    this.homePage
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
              home: widget.homePage,
            )),)}
      else
        {
          Firestore.instance.collection(widget.userDataBaseName).document(currentUser.uid)
              .get()
              .then((value) =>
          (value['CompleteRegister'] == true)?
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreenMain(home:widget.homePage,user:value)),
          ) : Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Registration(container:widget.completeRegisterPage,isNumber:null,data:"")),
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