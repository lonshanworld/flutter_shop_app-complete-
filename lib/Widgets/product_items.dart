import "package:flutter/material.dart";
import "package:provider/provider.dart";

import '../Providers/auth.dart';
import '../Providers/cart.dart';

import '../Screens/product_details_screen.dart';
import "../Providers/product.dart";

class ProductItem extends StatelessWidget {

//   final String id;
//   final String title;
//   final String imageUrl;
//
//   ProductItem({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
// });

  @override
  Widget build(BuildContext context) {

    final product = Provider.of<Product>(context,listen: false);
    final cart = Provider.of<Cart>(context,listen: false);
    final authdata = Provider.of<Auth>(context,listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black38,
          title: Text(
            product.title,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(product.isFavourite ? Icons.favorite : Icons.favorite_border_outlined, size: 20,),
              color: Colors.redAccent,
              onPressed: (){
                product.toggleFavouriteStatus(authdata.token as String, authdata.userId as String);
              },
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart,size: 20,),
            color: Colors.greenAccent,
            onPressed: (){
              cart.AddItem(product.id, product.title, product.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Item Added"),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "Undo",
                    onPressed: (){
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: const AssetImage("assets/images/289 product-placeholder.png"),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          onTap: (){
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
        ),
      ),
    );
  }
}
