import 'dart:core';

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import '../Widgets/app_drawer.dart';
import "../Providers/orders.dart" show Orders;
import "../Widgets/order_item.dart";

class OrdersScreen extends StatefulWidget {

  static const routeName = "/order_screen";

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  late Future _ordersFuture;
  Future _obtainOrderFuture(){
    return Provider.of<Orders>(context,listen: false).fetchandsetOrders();
  }


  @override
  void initState() {
    _ordersFuture = _obtainOrderFuture();
    super.initState();
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
        title: const Text("Your Orders - "),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder:(ctx, datasnapshot){
          if(datasnapshot.connectionState == ConnectionState.waiting){
            return  const Center(child: CircularProgressIndicator());
          }else{
            if(datasnapshot.error != null){
              // Do error handling stuff
              return const Center(
                child: Text("Empty Orders!!"),
              );
            }else{
              return Consumer<Orders>(builder: (ctx,orderData,child) =>ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, i) =>OrderItem(orderData.orders[i]),
              ) );
            }
          }
        },
      )
    );
  }
}
