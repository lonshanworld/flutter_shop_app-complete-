import 'dart:math';

import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../Models/http_exception.dart';
import '../Providers/auth.dart';

enum AuthMode{
  Signup,
  Login
}

class AuthScreen extends StatelessWidget {

  static const routeName = "/auth";

  @override
  Widget build(BuildContext context) {

    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0,1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 50,
                      ),

                      transform: Matrix4.rotationZ(-8 * pi/180)..translate(-10.0),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade900,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(0,5),
                        )],
                      ),
                      child: const Text(
                        "MyShop",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode =AuthMode.Login;
  final Map<String,String> _authData = {
    "email" : "",
    "password" : "",
  };
  final _passwordController = TextEditingController();
  var _isloading = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: const Offset(0,-1.5), end: const Offset(0,0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _opacityAnimation = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    // _heightAnimation.addListener(() => setState(() {print("Hello!");}));
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("An Error Occured!"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: (){
              Navigator.of(ctx).pop();
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async{
    if(!_formKey.currentState!.validate()){
      //Invalid!
      return;
    }
    _formKey.currentState!.save();

    setState((){
      _isloading = true;
    });

    try{
      if(_authMode == AuthMode.Login){
        // Log user in
        await Provider.of<Auth>(context,listen: false).login(_authData["email"] as String, _authData["password"] as String);
        // print("Auth_Screen_login :: $_authData['email']");

      }else{
        //Sign user up
        await Provider.of<Auth>(context,listen: false).signup(_authData["email"] as String, _authData["password"] as String);
      }
      // Navigator.of(context).pushReplacementNamed(ProductOverviewScreen.routeName);
    }on httpException catch(error){
      var errorMessage = "Authentication Failed";
      if(error.toString().contains("EMAIL_EXISTS")){
        errorMessage = "This email address is already in use";
      }else if(error.toString().contains("INVALID_EMAIL")){
        errorMessage = "This is not a valid email address";
      }else if(error.toString().contains("WEAK_PASSWORD")){
        errorMessage = "This password is too weak";
      }else if(error.toString().contains("EMAIL_NOT_FOUND")){
        errorMessage = "Could not find a user with that email";
      }else if(error.toString().contains("INVALID_PASSWORD")){
        errorMessage = "Invalid Password!";
      }
      // print(error);
      _showErrorDialog(errorMessage);
    }catch(error){
      const errorMessage = "Could not authenticate you.  Please try again later!";
      // print("Show error in auth screen : $error");
      _showErrorDialog(errorMessage);
    }

    setState((){
      _isloading = false;
    });
  }


  void _switchAuthMode(){
    if(_authMode == AuthMode.Login){
      setState((){
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    }else{
      setState((){
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {

    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      // child: AnimatedBuilder(
      //   animation: _heightAnimation,
      //   builder: (ctx,ch) =>
      child:AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 320:260,
          // height: _heightAnimation.value.height,
          constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.Signup ? 320:260,
          ),
          width: deviceSize.width * 0.80,
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: "E-mail"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value){
                      if(value!.isEmpty || !value.contains("@")){
                        return "Invalid Email";
                      }
                      return null;
                    },
                    onSaved: (value){
                      _authData["email"] = value as String;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Password is Empty!";
                      }
                      if(value.length < 5){
                        return "Password is too short!";
                      }
                      return null;
                    },
                    onSaved: (value){
                      _authData["password"] = value as String;
                    },
                  ),
                  // if(_authMode == AuthMode.Signup)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      constraints: BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 60 : 0,maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                      curve: Curves.easeIn,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: TextFormField(
                            enabled: _authMode == AuthMode.Signup,
                            decoration: const InputDecoration(labelText: "Confirm Password"),
                            obscureText: true,
                            validator: _authMode == AuthMode.Signup
                                ?
                                (value){
                              if(value != _passwordController.text){
                                return "Password do Not match!";
                              }
                              return null;
                            }
                                :
                            null,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  if(_isloading) const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          overlayColor: MaterialStateProperty.all(Colors.greenAccent),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          )),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          )
                      ),
                      child: Text(
                        _authMode == AuthMode.Login ? "LOGIN" : "SIGN UP",
                      ),
                    ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.cyanAccent),
                      overlayColor: MaterialStateProperty.all(Colors.yellowAccent),
                    ),
                    child: Text(
                        "${_authMode == AuthMode.Login ? "SIGNUP" : "LOGIN"} INSTEAD"
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
