import "dart:convert";

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class Product with ChangeNotifier{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
});

  void _setFavValue(bool newValue){
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String token,String userId) async{
    final oldstatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();

    final url = Uri.parse("https://shop-d418e-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId/$id.json?auth=$token");
    try{
      final response = await http.put(url,body: json.encode(isFavourite));
      if(response.statusCode >= 400){
        _setFavValue(oldstatus);
      }
    }catch(err){
      _setFavValue(oldstatus);
    }
  }
}