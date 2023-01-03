import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import '../Models/http_exception.dart';

import 'product.dart';

class Products with ChangeNotifier{
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: "A red shirt - it is pretty red!.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
    //   price: 29.99,
    //   imageUrl:
    //   'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //   'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavouriteOnly = false;
  final String authtoken;
  final String userId;
  Products(this.authtoken,this.userId,this._items);

  List<Product> get items{
    // if(_showFavouriteOnly){
    //   return _items.where((element) => element.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get Favourites{
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findById(String id){
    return _items.firstWhere((element) => element.id == id);
  }

  // void showFavouriteOnly(){
  //   _showFavouriteOnly = true;
  //   notifyListeners();
  // }
  //
  // void showAll(){
  //   _showFavouriteOnly = false;
  //   notifyListeners();
  // }

  Future<void> FetchandSetProducts([bool filterByUser = false]) async{
    final filterString = filterByUser ? 'orderBy="createrId"&equalTo="$userId"' : '';
    var url = Uri.parse('https://shop-d418e-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken&$filterString');
    // print("Url:: $url");
    try {
      final response = await http.get(url);
      final extratedData = json.decode(response.body) as Map<String,dynamic>;
      if(extratedData == null){
        return;
      }
      url = Uri.parse("https://shop-d418e-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId.json?auth=$authtoken");
      final responseFavourite= await http.get(url);
      final responseFavouriteData = json.decode(responseFavourite.body);
      final List<Product> loadedProducts = [];
      extratedData.forEach((keyproId, valueproData) {
        loadedProducts.add(Product(
          id: keyproId,
          title: valueproData["title"],
          description: valueproData["description"],
          price: valueproData["price"] as double,
          imageUrl: valueproData["imageUrl"],
          isFavourite: responseFavouriteData == null ? false : responseFavouriteData[keyproId] ?? false,
        ));
      });

      _items = loadedProducts;
      // print("Items :: $_items");
      notifyListeners();
    }catch(err){
      // print("Show error :: $err");
      rethrow;
    }
  }

  Future<void> addProduct(Product pro) async{
    final url = Uri.parse("https://shop-d418e-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken");
    try{
      final response = await http.post(url,body: json.encode({
        "title" : pro.title,
        "description" : pro.description,
        "price" : pro.price,
        "imageUrl" : pro.imageUrl,
        "createrId" : userId,
      }),);
      final newPro = Product(
        id: json.decode(response.body)["name"],
        title: pro.title,
        description: pro.description,
        price: pro.price,
        imageUrl: pro.imageUrl,
      );
      _items.add(newPro);
      notifyListeners();
    }catch (err){
        // print("add product :: $err");
        rethrow;
    }

    // }).catchError((error){
    //   print(error);
    //   throw error;
    // });
  }

  Future<void> update(String id, Product newProduct) async{
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if(prodIndex >=0){
      final url = Uri.parse("https://shop-d418e-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authtoken");
      await http.patch(url, body: json.encode({
        "title": newProduct.title,
        "description": newProduct.description,
        "price": newProduct.price,
        "imageUrl": newProduct.imageUrl,
      }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }else{
      // print("...");
    }
  }

  Future<void> deleteProduct(String deid) async{
    final url = Uri.parse("https://shop-d418e-default-rtdb.asia-southeast1.firebasedatabase.app/products/$deid.json?auth=$authtoken");
    final existingProductIndex = _items.indexWhere((element) => element.id == deid);
    Product? existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if(response.statusCode >= 400){
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw httpException("Could not delete this product.");
    }
    existingProduct = null;
  }
}