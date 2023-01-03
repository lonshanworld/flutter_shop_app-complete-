import 'dart:async';
import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/http_exception.dart';

class Auth with ChangeNotifier{
    String? _token;
    DateTime? _expireDate;
    String? _userId;
    Timer? _authTimer;

  bool get isAuth{
    return token != null;
  }

  String? get token{
    if(
    _expireDate != null && _expireDate!.isAfter(DateTime.now()) &&
        _token !=null){
      return _token;
    }
    return null;
  }

  String? get userId{
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlsegment) async{
    try{
      final url = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:$urlsegment?key=AIzaSyALs9vOtf3XUjGcndz45C6d4_uNBocavQ8");
      final response = await http.post(url,body: json.encode({
        "email" : email,
        "password" : password,
        "returnSecureToken": true,
      }));
      // print("Email : $email");
      // print("Password : $password");
      final responseData = json.decode(response.body);
      // print("responseData :: $responseData");
      // print(responseData);
      // print("Token : " +responseData["idToken"]);
      // print( "Localid : "+responseData["localId"]);
      // print( "expireid "+ responseData["expiresIn"]);
      if(responseData["error"] != null){
        throw httpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      var _date = responseData["expiresIn"];
      // print("expire :: $_date");
      _expireDate = DateTime.now().add(Duration(seconds: int.parse(_date)));
        // notifyListeners();
      // print(responseData["idToken"]);
      // print("User Id :: $_userId");
      _autoLogOut();
      // print(DateTime.now().add(Duration(seconds: int.parse(responseData["expiresIn"]))));
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token" : _token,
        "userId" : _userId,
        "expireDate" : _expireDate?.toIso8601String(),
      });
      prefs.setString("UserData",userData);

    }catch(error){
      // print("show auth error in login : $error");
      rethrow;
    }
  }


  Future<void> signup(String email, String password) async{
    return _authenticate(email, password, "signUp");
    // try{
    //   final url = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCZg86uhneIVFnwf9354vH7ZxukiEgYy_A");
    //   final response = await http.post(url,body: json.encode({
    //     "email" : email,
    //     "password" : password,
    //     "returnSecureToken": true,
    //   }));
    //   final responseData = json.decode(response.body);
    //
    //   if(responseData["error"] != null){
    //     throw httpException(responseData["error"]["message"]);
    //   }
    //   _token = responseData["idToken"];
    //   _userId = responseData["localId"];
    //   var _date = responseData["expiresIn"];
    //   print("expire :: $_date");
    //   _expireDate = DateTime.now().add(Duration(seconds: int.parse(_date)));
    //   notifyListeners();
    //
    // }catch(error){
    //   print("show auth error in signin : $error");
    //   throw error;
    // }
  }

  Future<void> login(String email, String password) async{
    return _authenticate(email, password, "signInWithPassword");
    // try{
    //   final url = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCZg86uhneIVFnwf9354vH7ZxukiEgYy_A");
    //   final response = await http.post(url,body: json.encode({
    //     "email" : email,
    //     "password" : password,
    //     "returnSecureToken": true,
    //   }));
    //   print("Email : $email");
    //   print("Password : $password");
    //   final responseData = json.decode(response.body);
    //
    //   print("responseData :: $responseData");
    //
    //   if(responseData["error"] != null){
    //     throw httpException(responseData["error"]["message"]);
    //   }
    //   _token = responseData["idToken"];
    //   _userId = responseData["localId"];
    //   var _date = responseData["expiresIn"];
    //   print("expire :: $_date");
    //   _expireDate = DateTime.now().add(Duration(seconds: int.parse(_date)));
    //   notifyListeners();
    //
    // }catch(error){
    //   print("show auth error in login : $error");
    //   throw error;
    // }
  }

  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey("UserData")){
      return false;
    }
    final extractedUserData = json.decode(prefs.getString("UserData") as String) as Map<String, Object>;
    final expiryUserDate = DateTime.parse(extractedUserData["expireDate"].toString());
    if(expiryUserDate.isBefore(DateTime.now())){
      return false;
    }
    _token = extractedUserData["token"] as String;
    _userId = extractedUserData["userId"] as String;
    _expireDate = expiryUserDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async{
    _token = null;
    _userId = null;
    _expireDate = null;
    if(_authTimer != null){
      _authTimer?.cancel();
      _authTimer = null;
    }
    // print("Ok");
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); // userdata pl shi lo clear lote tr......a myrr g shi yin remove nk pl lote ya ml
  }

  void _autoLogOut(){
    if(_authTimer != null){
      _authTimer?.cancel();
    }
    final timeToExpire = _expireDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire),logOut);
  }
}