import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../Providers/cart.dart';
import '../Providers/product_provider.dart';
import '../Screens/cart_screen.dart';
import '../Widgets/app_drawer.dart';
import '../Widgets/badge.dart';
import "../Widgets/products_grid.dart";

enum FilterOptions {
  Favourites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {

  static const routeName = "/productOverviewScreen";

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showFavouriteOnly = false;
  var _isinit = true;
  bool _isloading = true;


  // @override
  // void initState() {
    // Provider.of<Products>(context).FetchandSetProducts();
    // Future.delayed(Duration.zero).then((_){
    //   Provider.of<Products>(context,listen: false).FetchandSetProducts();
    // });
  //   super.initState();
  // }


  @override
  void didChangeDependencies() {
    if(_isinit){
      setState((){
        _isloading = true;
      });
      Provider.of<Products>(context).FetchandSetProducts().then((_){
        setState((){
          _isloading = false;
        });
      });
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productContainers = Provider.of<Products>(context, listen: false);

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
        title: const Text("My Shop"),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.Favourites,
                child: Text("Only Favourites"),
              ),
              const PopupMenuItem(
                value: FilterOptions.All,
                child: Text("Show All"),
              )
            ],
            onSelected: (FilterOptions selectedValue) {
              setState((){
                if (selectedValue == FilterOptions.Favourites) {
                  // productContainers.showFavouriteOnly();
                  _showFavouriteOnly = true;
                } else {
                  // productContainers.showAll();
                  _showFavouriteOnly = false;
                }
              });
            },
          ),
          Consumer<Cart>(
            builder: (_,cartdata,_2) => Badge(
              value: cartdata.allTotalItem.toString(),
              color: Colors.red,
              child: _2 as Widget,
            ),
            child: IconButton(
              icon: const Icon(
                  Icons.shopping_cart,
              ),
              onPressed: (){
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isloading
          ?
        const Center(
          child: CircularProgressIndicator(),
        )
          :
        ProductsGrid(_showFavouriteOnly),
    );
  }
}
