import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../Providers/product.dart';
import '../Providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {

  static const routeName = "/edit_product_screen";

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _PriceFocusNode = FocusNode();
  final _DescriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(id: "", title: "", description: "", price: 0, imageUrl: "");

  var _initvalue = {
    "title" : "",
    "description" : "",
    "price" : "",
    "imageUrl" : "",
  };
  var _isinit = true;
  var _isloading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }


  @override
  void didChangeDependencies() {
    if(_isinit){
      final String? proid = ModalRoute.of(context)!.settings.arguments as String?;
      if(proid != null){
        _editedProduct = Provider.of<Products>(context,listen: false).findById(proid);
        _initvalue = {
          "title" : _editedProduct.title,
          "description" : _editedProduct.description,
          "price" : _editedProduct.price.toString(),
          // "imageUrl" : _editedProduct.imageUrl,
          "imageUrl" :"",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _PriceFocusNode.dispose();
    _DescriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl(){
    if(!_imageUrlFocusNode.hasFocus){
      if(
        (!_imageUrlController.text.startsWith("http") && !_imageUrlController.text.startsWith("https")) ||
        (!_imageUrlController.text.endsWith(".png") && !_imageUrlController.text.endsWith(".jpg") && !_imageUrlController.text.endsWith(".jpeg"))
      ){
        return;
      }
      setState((){
      });
    }
  }

  Future<void> _saveForm() async{
    final isValid = _form.currentState!.validate();
    if(!isValid){
      return;
    }
    _form.currentState?.save();
    setState((){
      _isloading = true;
    });
    if(_editedProduct.id.isNotEmpty){
      await Provider.of<Products>(context,listen: false).update(_editedProduct.id,_editedProduct);
      // setState((){
      //   _isloading = false;
      // });
      // Navigator.of(context).pop();
    }else{
      try{
        await Provider.of<Products>(context,listen: false).addProduct(_editedProduct);
        // setState((){
        //   _isloading = false;
        // });
        // Navigator.of(context).pop();
      }catch(error){
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("An error occured!"),
            content: const Text("Something went wrong!"),
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
      // finally{
        setState((){
          _isloading = false;
        });
        Navigator.of(context).pop();
      // }
    }
    // setState((){
    //   _isloading = false;
    // });
    // Navigator.of(context).pop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors:[
                Colors.orangeAccent,
                Colors.purpleAccent,
              ],
              stops: [0.2,1.0],
            ),
          ),
        ),
        title: const Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isloading
          ?
      const Center(
        child: CircularProgressIndicator(),
      )
          :
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child:  Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _initvalue["title"],
                  decoration: const InputDecoration(labelText: "Title"),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_){
                    FocusScope.of(context).requestFocus(_PriceFocusNode);
                  },
                  validator: (value){
                    if(value!.isEmpty){
                      return "Please Provide a value.";
                    }
                    return null;
                  },
                  onSaved: (value){
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                      title: value as String,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                    );
                  },
                ),
                TextFormField(
                  initialValue: _initvalue["price"],
                  decoration: const InputDecoration(labelText: "Price"),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _PriceFocusNode,
                  onFieldSubmitted: (_){
                    FocusScope.of(context).requestFocus(_DescriptionFocusNode);
                  },
                  validator: (value){
                    if(value!.isEmpty){
                      return "Please enter a price.";
                    }
                    if(double.tryParse(value) == null){
                      return "Please enter number";
                    }
                    if(double.tryParse(value)! <= 0){
                      return "Please enter value greater than zero";
                    }
                    return null;
                  },
                  onSaved: (value){
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      price: double.parse(value!),
                      imageUrl: _editedProduct.imageUrl,
                    );
                  },
                ),
                TextFormField(
                  initialValue: _initvalue["description"],
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  focusNode: _DescriptionFocusNode,
                  validator: (value){
                    if(value!.isEmpty){
                      return "Please Provide a Description.";
                    }
                    return null;
                  },
                  onSaved: (value){
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                      title: _editedProduct.title,
                      description: value as String,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(top: 8,right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: Container(
                          child: _imageUrlController.text.isEmpty
                              ?
                          const Text("Enter Url")
                              :
                          FittedBox(
                            child: Image.network(_imageUrlController.text,fit: BoxFit.cover,),
                          )
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "Image Url"),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        validator: (value){
                          if(value!.isEmpty){
                            return "Please Provide an ImageUrl.";
                          }
                          // if(!value.startsWith("http") && !value.startsWith("https")){
                          //   return "Please enter valid ImageUrl";
                          // }
                          // if(!value.endsWith(".png") && !value.endsWith(".jpg") && !value.endsWith(".jpeg")){
                          //   return "Please enter valid ImageUrl";
                          // }
                          return null;
                        },
                        onEditingComplete: (){
                          setState((){

                          });
                        },
                        onFieldSubmitted: (_){
                          _saveForm();
                        },
                        onSaved: (value){
                          _editedProduct = Product(
                            isFavourite: _editedProduct.isFavourite,
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: value as String,
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

