import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import "../Providers/product_provider.dart";

class ProductDetailScreen extends StatelessWidget {

  // final String title;
  //
  // ProductDetailScreen(this.title);

  static const routeName = "./product_detail_screen";

  @override
  Widget build(BuildContext context) {

    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedproduct = Provider.of<Products>(context,listen: false).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedproduct.title),
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       gradient: LinearGradient(
      //         colors:[
      //           Colors.orangeAccent,
      //           Colors.purpleAccent,
      //         ],
      //         stops: [0.2,1.0],
      //       ),
      //     ),
      //   ),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFFe67b37),
            iconTheme: const IconThemeData(
              color: Color(0xFF74360e),
            ),
            expandedHeight: 600,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedproduct.title,style: const TextStyle(
                color: Color(0xFF74360e),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
              background: Hero(
                tag: loadedproduct.id,
                child: Image.network(
                  loadedproduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 10,),
              Center(
                child: Text(
                  "\$ ${loadedproduct.price}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  loadedproduct.description,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 800,),
            ]),
          ),
        ],
      ),
    );
  }
}
