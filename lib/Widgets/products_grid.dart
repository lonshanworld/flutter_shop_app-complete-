import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import "../Widgets/product_items.dart";
import "../Providers/product_provider.dart";

class ProductsGrid extends StatelessWidget {

  final bool showFavourite;

  ProductsGrid(this.showFavourite);
  
  @override
  Widget build(BuildContext context) {
    
    final productsData = Provider.of<Products>(context);
    final products = showFavourite ? productsData.Favourites : productsData.items;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3/2,
        crossAxisSpacing:10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx,i) => ChangeNotifierProvider.value(
        // create: (c) => products[i],
        value: products[i],
        child: ProductItem(
          // id: products[i].id,
          // title: products[i].title,
          // imageUrl: products[i].imageUrl,
        ),
      ) ,
      itemCount: products.length,
      padding: const EdgeInsets.all(10),
    );
  }
}
