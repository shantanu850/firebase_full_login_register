library firebase_full_login_register_web;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_full_login_register_web/mainScreen.dart';
import 'package:firebase/firebase.dart' as firebase;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<firebase.User>(
            stream: firebase.auth().onAuthStateChanged,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  //loading
                );
              } else {
                if (snapshot.data != null) {
                  return Loader(
                    uid: snapshot.data.uid,
                    db:widget.userDataBaseName,
                    homepage: widget.homePage,
                    complete: widget.completeRegisterPage,
                    context: context,
                  );
                } else {
                  return LoginScreen(
                    appIcon: widget.appIcon,
                    appName: widget.appName,
                    emailImage: widget.emailImage,
                    googleImage: widget.googleImage,
                    facebookImage: widget.facebookImage,
                    databaseName: widget.userDataBaseName,
                    backgroundImageAsset: widget.backgroundImageAsset,
                    container: widget.completeRegisterPage,
                    home: widget.homePage,
                  );
                }
              }
            }),
      ),
    );
  }
}
class Loader extends StatelessWidget {
  final db;
  final uid;
  final context;
  final homepage;
  final complete;
  const Loader({Key key, this.db, this.uid, this.context, this.homepage, this.complete}) : super(key: key);

  initState(){
    Firestore.instance.collection(db).document(uid)
        .get()
        .then((value) =>
    (value['CompleteRegister'] == true)?
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => HomeScreenMain(home:homepage)),
    ) : Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => Registration(container:complete)),
    )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
    //loading
    );
  }
}
