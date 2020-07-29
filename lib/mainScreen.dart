library firebase_login_register;

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Widget appIcon;
  final Widget appName;
  final DecorationImage googleImage;
  final DecorationImage facebookImage;
  final DecorationImage emailImage;
  final String databaseName;
  final AssetImage backgroundImageAsset;
  final Widget container;
  const LoginScreen({Key key, this.appIcon, this.appName, this.googleImage, this.facebookImage, this.emailImage, this.databaseName, this.backgroundImageAsset, this.container}): super(key: key);
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  String email,password,displayName,surName,phoneNo,confPassword;
  final formKeyPhone = new GlobalKey<FormState>();
  String verificationId, smsCode;
  bool codeSent = false;
  int _state = 0;
  final formKeyReg = GlobalKey<FormState>();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }
  Widget Home() {
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
                  this.phoneNo = value;
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
                        onTap: (){},
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
                        onTap: (){},
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
                        onTap: (){},
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
  signIn(AuthCredential authCreds) {
    FirebaseAuth.instance.signInWithCredential(authCreds).then((value) =>
    {
      if(value.additionalUserInfo.isNewUser){
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => CompleteRegistration(isNumber:true,data:this.phoneNo,)))
      }else{
        Firestore.instance.collection(widget.databaseName).document(value.user.uid).get()
            .then((DocumentSnapshot result) =>
        (result["CompleteRegister"]==true)?
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())):
        Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteRegistration(isNumber:true,data:this.phoneNo,container: widget.container)))
        )
      }
    }
    );
  }
  signInWithOTP(smsCode, verId) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }
  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      signIn(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
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
  Widget LoginPage() {
    var height = MediaQuery.of(context).size.height;
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
                                        try {
                                          if (formKey.currentState.validate()) {
                                            signInE(email, password, context);
                                            setState(() {
                                              if (_state == 0) {
                                                animateButton();
                                              }
                                            });}
                                        }catch(e){
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
                                          child: setUpButtonChild("SignIn"),
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
                  onTap: (){gotoSignup();},
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
            ],
          ),
        ],
      ),
    );
  }

  Widget SignupPage() {
    var height = MediaQuery.of(context).size.height;
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
                                        try {
                                          if (formKeyReg.currentState.validate()) {
                                            if (password == confPassword) {
                                              signUp(email, password, context);
                                              setState(() {
                                                if (_state == 0) {
                                                  animateButton();
                                                }
                                              });
                                            }else{
                                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Password and Confirm password did not match')));
                                            }
                                          }
                                        }catch(e){
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
                                          child: setUpButtonChild("SignUp"),
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
                    "Don't have an account? Sign In",
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

  gotoLogin() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  gotoSignup() {
    //controller_minus1To0.reverse(from: 0.0);
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  PageController _controller = new PageController(initialPage: 1, viewportFraction: 1.0);
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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
            decoration: BoxDecoration(
              color: Colors.redAccent,
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
              children: <Widget>[LoginPage(), Home(), SignupPage()],
              scrollDirection: Axis.horizontal,
            )),
      ),
    );
  }
  Widget setUpButtonChild(String text) {
    if (_state == 0) {
      return new Text(
        text,
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      );
    } else{
      return ColorLoader(
        dotOneColor: Colors.purple,
        dotTwoColor: Colors.pink,
        dotThreeColor: Colors.red,
        dotType: DotType.circle,
        duration: Duration(seconds:2),
      );
    }
  }

  void animateButton() {
    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 2000), () {
      setState(() {
        _state = 2;
      });
    });
  }
  signInE(String email, String password,context) {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)
          .then((currentUser) => Firestore.instance.collection(widget.databaseName).document(currentUser.user.uid).get())
          .then((DocumentSnapshot result) =>
      (result["CompleteRegister"]==true)?
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())):
      Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteRegistration(isNumber:false,data:email,container: widget.container,)))
      );
    } catch (e){
      return AlertDialog(
          title: Text('error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(e),],),),
          actions: <Widget>[
            FlatButton(
                child: Text('Retry'),
                onPressed: () {
                  Navigator.of(context).pop();})]);
    }
  }

  signUp(email, password,context) {
    FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password,)
        .then((currentUser) =>
        FirebaseAuth.instance.currentUser().then((value) =>
            Firestore.instance.collection(widget.databaseName).document(value.uid).setData({
              "CompleteRegister":false,
            }).then((value) =>
            {Navigator.push(context, MaterialPageRoute(
                builder: (context) => CompleteRegistration(isNumber:false,data:email,container: widget.container,)))}
            )
        )
    );
  }
}
class HomeScreen extends StatefulWidget {
  final Widget homescreen;
  const HomeScreen({Key key, this.homescreen}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.homescreen;
  }
}
class CompleteRegistration extends StatefulWidget {
  final bool isNumber;
  final String data;
  final Widget container;
  const CompleteRegistration({Key key, this.isNumber, this.data, this.container}) : super(key: key);
  @override
  _CompleteRegistrationState createState() => _CompleteRegistrationState();
}

class _CompleteRegistrationState extends State<CompleteRegistration> {
  @override
  Widget build(BuildContext context) {
    return widget.container;

  }

}
class ColorLoader extends StatefulWidget {

  final Color dotOneColor;
  final Color dotTwoColor;
  final Color dotThreeColor;
  final Duration duration;
  final DotType dotType;
  final Icon dotIcon;

  ColorLoader({
    this.dotOneColor = Colors.redAccent,
    this.dotTwoColor = Colors.green,
    this.dotThreeColor = Colors.white,
    this.duration = const Duration(milliseconds: 1000),
    this.dotType = DotType.circle,
    this.dotIcon = const Icon(Icons.blur_on)
  });

  @override
  _ColorLoaderState createState() => _ColorLoaderState();
}

class _ColorLoaderState extends State<ColorLoader>
    with SingleTickerProviderStateMixin {
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

class GoogleLoder extends StatefulWidget {

  final Color dotOneColor;
  final Color dotTwoColor;
  final Color dotThreeColor;
  final Color dotFourColor;
  final Duration duration;
  final DotType dotType;
  final Icon dotIcon;

  GoogleLoder({
    this.dotOneColor = Colors.blue,
    this.dotTwoColor = Colors.red,
    this.dotThreeColor = Colors.yellow,
    this.dotFourColor = Colors.green,
    this.duration = const Duration(milliseconds: 1000),
    this.dotType = DotType.circle,
    this.dotIcon = const Icon(Icons.blur_on)
  });

  @override
  _GoogleLoader createState() => _GoogleLoader();
}

class _GoogleLoader extends State<GoogleLoder>
    with SingleTickerProviderStateMixin {
  Animation<double> animation_1;
  Animation<double> animation_2;
  Animation<double> animation_3;
  Animation<double> animation_4;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: widget.duration, vsync: this);

    animation_1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.70, curve: Curves.ease),
      ),
    );

    animation_2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.8, curve: Curves.ease),
      ),
    );

    animation_3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 0.9, curve: Curves.ease),
      ),
    );

    animation_4 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.3, 1.0, curve: Curves.ease),
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
          Transform.translate(
            offset: Offset(
              0.0,
              -30 *
                  (animation_4.value <= 0.50
                      ? animation_4.value
                      : 1.0 - animation_4.value),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotFourColor,
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