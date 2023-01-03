import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../Providers/product_provider.dart';
import '../Widgets/app_drawer.dart';
import '../Widgets/user_products_item.dart';

import 'edit_product_screen.dart';

class UsersProductScreen extends StatelessWidget {

  static const routeName = "/user_products_screen";

  Future<void> _refreshProducts(BuildContext context) async{
    await Provider.of<Products>(context,listen: false).FetchandSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {

    // final productsdata = Provider.of<Products>(context);
    print("rebuilding..");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
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
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (fu,snapShot)=> snapShot.connectionState == ConnectionState.waiting
          ?
        const Center(child: CircularProgressIndicator(),)
          :
        RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Consumer<Products>(
            builder: (ctx,productsdata,_) {
              if(productsdata.items.isEmpty){
                return const Center(
                  child: Text("You haven't upload any item so far."),
                );
              }else{
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    itemBuilder: (_,i) => Column(
                      children: [
                        UserProductsItem(
                          productsdata.items[i].id,
                          productsdata.items[i].title,
                          productsdata.items[i].imageUrl,
                        ),
                        const Divider(color: Colors.black, thickness: 1,),
                      ],
                    ),
                    itemCount: productsdata.items.length,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
