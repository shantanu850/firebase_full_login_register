import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_full_login_register_web/exception_Handaler.dart';
import 'package:firebase/firebase.dart' as firebase;

class LoginScreen extends StatefulWidget {
  final Widget appIcon;
  final Widget appName;
  final DecorationImage googleImage;
  final DecorationImage facebookImage;
  final DecorationImage emailImage;
  final String databaseName;
  final AssetImage backgroundImageAsset;
  final Widget container;
  final onFacebooktap;
  final home;
  final Color backgroundColor;

  const LoginScreen({Key key,
    this.appIcon,
    this.appName,
    this.googleImage,
    this.facebookImage,
    this.emailImage,
    this.databaseName,
    this.backgroundImageAsset,
    this.container,
    this.home,
    this.onFacebooktap,
    this.backgroundColor = Colors.redAccent,
  }): super(key: key);
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  String email,password,displayName,surName,phoneNo,confPassword;
  final formKeyPhone = new GlobalKey<FormState>();
  String verificationId, smsCode;
  bool codeSent = false;
  int _state;
  final formKeyReg = GlobalKey<FormState>();
  final formKey = GlobalKey<FormState>();
  final formKeyReset = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  AuthResultStatus _status;
  PageController _controller = new PageController(initialPage: 1, viewportFraction: 1.0);
  @override
  void initState() {
    _state = 0;
    super.initState();
  }

  ///Alert popups
  showReset(BuildContext context) {
    bool send = false;
    String email;
    AlertDialog alert = AlertDialog(
      title: Text("We will send you password reset link",maxLines:1,),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical:5.0),
        child: Form(
          key: formKeyReset,
          child: TextFormField(
            obscureText: false,
            decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.person,color:Colors.redAccent),
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black),
              fillColor: widget.backgroundColor.withOpacity(0.3),
              filled: true,
              border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(
                    color: Colors.redAccent,
                  )),
              focusedBorder: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(
                    color: Colors.redAccent,
                  )),
              enabledBorder: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(
                    color: Colors.redAccent,
                  )),
            ),
            validator: (val) {
              Pattern pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = new RegExp(pattern);
              if (!regex.hasMatch(val)) {
                return 'Email format is invalid';
              } else {
                return null;
              }
            },
            onChanged: (value) {
              email = value; //get the value entered by user.
            },
            keyboardType: TextInputType.emailAddress,
            style: new TextStyle(
              height: 1.0,
              fontSize: 14,
              fontFamily: "Poppins",
            ),
          ),
        ),
      ),
      actions: [
        (send==false)?ButtonBar(
            children:[
              FlatButton(
                onPressed: () {
                  if (formKeyReset.currentState.validate()) {
                    resetPassword(email, context);
                    setState(() {
                      send = true;
                    });
                  }
                  }, child: Text("Send"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              )
            ]
        ):FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Done"),
        )
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  showError(BuildContext context,message) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    setState(() {
      _state = 2;
    });
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text(message.toString()),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("YES"),
          ),
        ],
      ),
    ) ??
        false;
  }

  ///main widget
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.dstATop),
                image: widget.backgroundImageAsset,
                fit: BoxFit.cover,
              ),
            ),
            child: PageView(
              controller: _controller,
              physics: new AlwaysScrollableScrollPhysics(),
              children: <Widget>[loginPage(context), home(), signUpPage()],
              scrollDirection: Axis.horizontal,
            )),
      ),
    );
  }

  ///main layouts home,loginPage,signUpPage,
  Widget home() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:height*0.2),
            child: Center(
              child: widget.appIcon,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0),
            child:  Center(
              child: widget.appName,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0, top:50.0,bottom:10),
            child: TextFormField(
              obscureText: false,
              decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.phone,color:Colors.white),
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white12,
                filled: true,
                border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                      color: Colors.white,
                    )),
                focusedBorder: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                      color: Colors.white,
                    )),
                enabledBorder: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                      color: Colors.white,
                    )),
              ),
              validator: (val) {
                if(val.length!=10) {
                  return "phone cannot be empty";
                }else{
                  return null;
                }
              },
              onChanged: (value) {
                setState(() {
                  String code = "+91";
                  this.phoneNo = code+value;
                });//get the value entered by user.
              },
              keyboardType: TextInputType.phone,
              style: new TextStyle(
                height: 1,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "Museo",
                color: Colors.white,
              ),
            ),
          ),
          codeSent ?Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0, top:10.0,bottom:10),
            child: TextFormField(
              obscureText: false,
              decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.lock,color:Colors.white),
                labelText: 'OTP',
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white12,
                filled: true,
                border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                      color: Colors.white,
                    )),
                focusedBorder: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                      color: Colors.white,
                    )),
                enabledBorder: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                      color: Colors.white,
                    )),
              ),
              validator: (val) {
                if(val.length==null) {
                  return "OTP cannot be empty";
                }else{
                  return null;
                }
              },
              onChanged: (value) {
                setState(() {
                  this.smsCode = value;
                });//get the value entered by user.
              },
              keyboardType: TextInputType.number,
              style: new TextStyle(
                height: 1.0,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "Museo",
                color: Colors.white,
              ),
            ),
          ):Container(),
          new Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top:10.0,bottom: 20),
            alignment: Alignment.center,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.white,
                    onPressed: () {
                      codeSent ? signInWithOTP(smsCode, verificationId):verifyPhone(phoneNo);
                    },
                    child: new Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(
                              child: codeSent ? Text(
                                "VERIFY",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold),):Text(
                                "SEND OTP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold),)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                Container(
                    child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Divider(
                                indent: 10,
                                endIndent: 10,
                                color: Colors.white,
                                thickness: 1,
                              )
                          ),
                          Text('or',
                              maxLines:1,
                              style: TextStyle(color:Colors.white,fontWeight:FontWeight.normal)),
                          Expanded(
                              child: Divider(
                                indent: 10,
                                endIndent: 10,
                                color: Colors.white,
                                thickness: 1,
                              )
                          ),
                        ]
                    )
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical:10),
                      width: width*0.25,
                      child: Text('Continue With',
                          maxLines:1,
                          style: TextStyle(color:Colors.white,fontWeight:FontWeight.normal))),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:<Widget>[
                      GestureDetector(
                        onTap: (){
                          googleSignIn();
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          width:width*0.15,
                          height:width*0.15,
                          alignment: Alignment.center,
                          decoration: new BoxDecoration(
                            image: widget.googleImage,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          gotoLogin();
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          width:width*0.15,
                          height:width*0.15,
                          alignment: Alignment.center,
                          decoration: new BoxDecoration(
                            image: widget.emailImage,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          widget.onFacebooktap;
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          width:width*0.15,
                          height:width*0.15,
                          alignment: Alignment.center,
                          decoration: new BoxDecoration(
                            image: widget.facebookImage,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget loginPage(context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.center,
      color: Colors.blueGrey.withOpacity(0.3),
      child: new ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin:EdgeInsets.only(top: width*0.3),
                    padding: EdgeInsets.symmetric(horizontal: width*0.1),
                    child: Form(
                        key:formKey,
                        child: new Column(
                          children: <Widget>[
                            Container(
                              margin:EdgeInsets.all(5),
                              child: Text('Login',style:
                              TextStyle(
                                fontFamily: 'Museo',
                                fontSize:22,
                                color: Colors.white,
                              ),),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical:5.0),
                              child: TextFormField(
                                obscureText: false,
                                decoration: new InputDecoration(
                                  prefixIcon: new Icon(Icons.person,color:Colors.white),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  focusedBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                ),
                                validator: (val) {
                                  Pattern pattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = new RegExp(pattern);
                                  if (!regex.hasMatch(val)) {
                                    return 'Email format is invalid';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  email = value; //get the value entered by user.
                                },
                                keyboardType: TextInputType.emailAddress,
                                style: new TextStyle(
                                  height: 1.0,
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical:5.0),
                              child: TextFormField(
                                obscureText: true,
                                decoration: new InputDecoration(
                                  prefixIcon: new Icon(Icons.lock,color:Colors.white),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  focusedBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                ),
                                validator: (val) {
                                  if(val.length==0) {
                                    return "Password cannot be empty";
                                  }else{
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  password = value; //get the value entered by user.
                                },
                                keyboardType: TextInputType.emailAddress,
                                style: new TextStyle(
                                  height: 1.0,
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(vertical:5),
                                child: SizedBox(
                                  height: 56,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: width*0.01),
                                    child :InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () async{
                                        if (formKey.currentState.validate()) {
                                          setState(() {
                                            _state = 1;
                                          });
                                          final status = await signInEmail(email,password,context);
                                          if (status == AuthResultStatus.successful) {
                                            _auth.currentUser().then((value) =>
                                                Firestore.instance.collection(widget.databaseName).document(value.uid).get()
                                                    .then((DocumentSnapshot result) =>
                                                (result["CompleteRegister"]==true)?
                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreenMain(home:widget.home,user:result))):
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => Registration(isNumber:false,data:email,container: widget.container,)))));
                                          } else {
                                            //final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
                                            setState(() {
                                              _state = 0;
                                            });
                                          }
                                        }
                                      },
                                      splashColor: Colors.blue,
                                      highlightColor: Colors.blue,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Center(
                                          child:(_state==0)?Text(
                                            "Login",
                                            style: const TextStyle(
                                              color: Colors.purple,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ):Loader(
                                            dotOneColor: Colors.purple,
                                            dotTwoColor: Colors.pink,
                                            dotThreeColor: Colors.red,
                                            dotType: DotType.circle,
                                            duration: Duration(seconds:2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            )],
                        )
                    ),
                  ),
                ],
              ),
              Container(
                width: width*0.55,
                padding: EdgeInsets.symmetric(vertical:width*0.02),
                child :GestureDetector(
                  onTap: (){gotoSignUp();},
                  child: Text(
                    "Don't have an account? Sign Up",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: width*0.55,
                padding: EdgeInsets.symmetric(vertical:width*0.02),
                child :FlatButton(
                  color: Colors.transparent,
                  onPressed: (){
                    showReset(context);
                  },
                  child: Text(
                    "Forgot Password ? ",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget signUpPage() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.center,
      color: Colors.blueGrey.withOpacity(0.3),
      child: new ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin:EdgeInsets.only(top: width*0.3),
                    padding: EdgeInsets.symmetric(horizontal: width*0.1),
                    child: Form(
                        key:formKeyReg,
                        child: new Column(
                          children: <Widget>[
                            Container(
                              margin:EdgeInsets.all(5),
                              child: Text('Register',style:
                              TextStyle(
                                fontFamily: 'Museo',
                                fontSize:22,
                                color: Colors.white,
                              ),),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical:5.0),
                              child: TextFormField(
                                obscureText: false,
                                decoration: new InputDecoration(
                                  prefixIcon: new Icon(Icons.person,color:Colors.white),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  focusedBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                ),
                                validator: (val) {
                                  Pattern pattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = new RegExp(pattern);
                                  if (!regex.hasMatch(val)) {
                                    return 'Email format is invalid';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  email = value; //get the value entered by user.
                                },
                                keyboardType: TextInputType.emailAddress,
                                style: new TextStyle(
                                  height: 1.0,
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical:5.0),
                              child: TextFormField(
                                obscureText: true,
                                decoration: new InputDecoration(
                                  prefixIcon: new Icon(Icons.lock,color:Colors.white),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  focusedBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                ),
                                validator: (val) {
                                  if(val.length==0) {
                                    return "Password cannot be empty";
                                  }else{
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  password = value; //get the value entered by user.
                                },
                                keyboardType: TextInputType.emailAddress,
                                style: new TextStyle(
                                  color: Colors.white,
                                  height: 1.0,
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical:5.0),
                              child: TextFormField(
                                obscureText: true,
                                decoration: new InputDecoration(
                                  prefixIcon: new Icon(Icons.lock,color:Colors.white),
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  focusedBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                  enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                      )),
                                ),
                                validator: (val) {
                                  if(val.length==0) {
                                    return "Password cannot be empty";
                                  }else{
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  confPassword = value; //get the value entered by user.
                                },
                                keyboardType: TextInputType.emailAddress,
                                style: new TextStyle(
                                  color: Colors.white,
                                  height: 1.0,
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(vertical:5),
                                child: SizedBox(
                                  height: 56,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: width*0.01),
                                    child :InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () async{
                                        if (formKeyReg.currentState.validate()) {
                                          if (password == confPassword) {
                                            setState(() {
                                              _state = 1;
                                            });
                                            final status = await signUpEmail(email,password,context);
                                            if (status == AuthResultStatus.successful) {
                                              _auth.currentUser().then((value) =>
                                                  Firestore.instance.collection(widget.databaseName).document(value.uid).setData({
                                                    "CompleteRegister":false,
                                                  }).then((value) =>
                                                      Navigator.push(context, MaterialPageRoute(
                                                          builder: (context) => Registration(isNumber:false,data:email,container: widget.container,)))
                                                  )
                                              );
                                            } else {
                                              // final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
                                              setState(() {
                                                _state = 0;
                                              });
                                            }
                                          }else{
                                            showError(context, 'Password and Confirm password did not match');
                                          }
                                        }
                                      },
                                      splashColor: Colors.blue,
                                      highlightColor: Colors.blue,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Center(
                                          child:(_state==0)?Text(
                                            "Sign Up",
                                            style: const TextStyle(
                                              color: Colors.purple,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ):Loader(
                                            dotOneColor: Colors.purple,
                                            dotTwoColor: Colors.pink,
                                            dotThreeColor: Colors.red,
                                            dotType: DotType.circle,
                                            duration: Duration(seconds:2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            )],
                        )
                    ),
                  ),
                ],
              ),
              Container(
                width: width*0.55,
                padding: EdgeInsets.symmetric(vertical:width*0.02),
                child :GestureDetector(
                  onTap: (){
                    gotoLogin();
                  },
                  child: Text(
                    "Already an account? Sign In",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///layout swap controller
  gotoLogin() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }
  gotoSignUp() {
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }


  ///sign in methods
  Future<AuthResultStatus> signInEmail(String email, String password,context) async{
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (authResult.user != null) {
            firebase.auth().setPersistence(firebase.Persistence.LOCAL);
            _status = AuthResultStatus.successful;
      } else {
        _status = AuthResultStatus.undefined;
      }
    }catch(e){
      print('Exception @createAccount: $e');
      showError(context,e.message);
      setState(() {
        _state = 0;
      });
      _status = AuthExceptionHandler.handleException(e);
    }
    return _status;
  }
  Future<AuthResultStatus> signUpEmail(email, password,context) async{
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (authResult.user != null) {
        firebase.auth().setPersistence(firebase.Persistence.LOCAL);
        Firestore.instance.collection('user').document(authResult.user.uid).setData({"CompleteRegister":false,});
        authResult.user.sendEmailVerification();
        _status = AuthResultStatus.successful;
      } else {
        _status = AuthResultStatus.undefined;
      }
    }catch(e){
      print('Exception @createAccount: $e');
      showError(context,e.message );
      setState(() {
        _state = 0;
      });
      _status = AuthExceptionHandler.handleException(e);
    }
    return _status;
  }
  Future<AuthResultStatus> googleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    try {
      AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      FirebaseUser user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      assert(user.uid == currentUser.uid);
      if(authResult.user != null) {
        if (authResult.additionalUserInfo.isNewUser) {
          Firestore.instance.collection('user').document(authResult.user.uid).setData({"CompleteRegister":false,});
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) =>
                  Registration(isNumber:false,data:user.email,container:widget.container)));
        } else {
          Firestore.instance.collection(widget.databaseName).document(user.uid)
              .get()
              .then((DocumentSnapshot result) =>
          (result["CompleteRegister"] == true) ?
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => HomeScreenMain(home: widget.home,user:result))) :
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              Registration(isNumber:false,
                  data:authResult.user.email,
                  container: widget.container)))
          );
        }
      }else{
        showError(context,"User is not available , Try again ");
      }
    }catch(e){
      print('Exception @createAccount: $e');
      showError(context,e.message);
      setState(() {
        _state = 0;
      });
      _status = AuthExceptionHandler.handleException(e);
    }
    return _status;
  }
  Future<AuthResultStatus> signIn(AuthCredential authCreds) async{
    try{
      AuthResult authResult = await _auth.signInWithCredential(authCreds);
      if(authResult != null){
        if(authResult.additionalUserInfo.isNewUser){
          Firestore.instance.collection('user').document(authResult.user.uid).setData({"CompleteRegister":false,});
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => Registration(isNumber:true,data:this.phoneNo,container:widget.container)));
        }else{
          Firestore.instance.collection(widget.databaseName).document(authResult.user.uid).get()
              .then((DocumentSnapshot result) =>
          (result["CompleteRegister"]==true)?
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreenMain(home:widget.home,user:result))):
          Navigator.push(context, MaterialPageRoute(builder: (context) => Registration(isNumber:true,data:this.phoneNo,container: widget.container))));
        }
      }
    }catch(e){
      print('Exception @createAccount: $e');
      showError(context,e.message);
      setState(() {
        _state = 0;
      });
      _status = AuthExceptionHandler.handleException(e);
    }
    return _status;
  }
  signInWithOTP(smsCode, verId) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }
  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      signIn(authResult);
    };
    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
      showError(context, authException.message);
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: Duration(seconds: 120),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
  Future<void> resetPassword(String email,context) async {
    await _auth.sendPasswordResetEmail(email: email).whenComplete(() => Navigator.of(context).pop());
  }

}

///complete registration page
class Registration extends StatefulWidget {
  final bool isNumber;
  final String data;
  final Widget container;
  const Registration({Key key, this.isNumber, this.data, this.container}) : super(key: key);
  @override
  _RegistrationState createState() => _RegistrationState();
}
class _RegistrationState extends State<Registration> {
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return widget.container;

  }
}

///color loader
class Loader extends StatefulWidget {

  final Color dotOneColor;
  final Color dotTwoColor;
  final Color dotThreeColor;
  final Duration duration;
  final DotType dotType;
  final Icon dotIcon;

  Loader({
    this.dotOneColor = Colors.redAccent,
    this.dotTwoColor = Colors.green,
    this.dotThreeColor = Colors.white,
    this.duration = const Duration(milliseconds: 1000),
    this.dotType = DotType.circle,
    this.dotIcon = const Icon(Icons.blur_on)
  });

  @override
  _LoaderState createState() => _LoaderState();
}
class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  Animation<double> animation_1;
  Animation<double> animation_2;
  Animation<double> animation_3;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: widget.duration, vsync: this);

    animation_1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.80, curve: Curves.ease),
      ),
    );

    animation_2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.9, curve: Curves.ease),
      ),
    );

    animation_3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 1.0, curve: Curves.ease),
      ),
    );

    controller.addListener(() {
      setState(() {
        //print(animation_1.value);
      });
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Transform.translate(
            offset: Offset(
              0.0,
              -30 *
                  (animation_1.value <= 0.50
                      ? animation_1.value
                      : 1.0 - animation_1.value),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotOneColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              0.0,
              -30 *
                  (animation_2.value <= 0.50
                      ? animation_2.value
                      : 1.0 - animation_2.value),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotTwoColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              0.0,
              -30 *
                  (animation_3.value <= 0.50
                      ? animation_3.value
                      : 1.0 - animation_3.value),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotThreeColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {

    controller.dispose();
    super.dispose();
  }
}
class Dot extends StatelessWidget {
  final double radius;
  final Color color;
  final DotType type;
  final Icon icon;

  Dot({this.radius, this.color, this.type, this.icon});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: type == DotType.icon ?
      Icon(icon.icon, color: color, size: 1.3 * radius,)
          : new Transform.rotate(
        angle: type == DotType.diamond ? pi/4 : 0.0,
        child: Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(color: color, shape: type == DotType.circle? BoxShape.circle : BoxShape.rectangle),
        ),
      ),
    );
  }
}
enum DotType {
  square, circle, diamond, icon
}

///home page
class HomeScreenMain extends StatefulWidget {
  final home;
  final user;
  const HomeScreenMain({Key key, this.home, this.user}) : super(key: key);
  @override
  _HomeScreenMainState createState() => _HomeScreenMainState();
}
class _HomeScreenMainState extends State<HomeScreenMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.home,
    );
  }
}
