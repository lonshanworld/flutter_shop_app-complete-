import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../Providers/cart.dart' show Cart;
import '../Widgets/cart_item.dart';
import "../Providers/orders.dart";


class CartScreen extends StatelessWidget {

  static const routeName = "/cart";

  @override
  Widget build(BuildContext context) {

    final cart = Provider.of<Cart>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: <Widget>[
          Card(
            color: const Color(0xFFf9e0cf),
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Total",style: TextStyle(fontSize: 20),),
                  const Spacer(),
                  Chip(
                    label: Text("\$ ${cart.totalAmount}"),
                    backgroundColor: const Color(0xFFea935b),
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                id : cart.items.values.toList()[i].id,
                productId: cart.items.keys.toList()[i],
                title : cart.items.values.toList()[i].title,
                price : cart.items.values.toList()[i].price,
                quantity : cart.items.values.toList()[i].quantity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {

  var _isloading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isloading) ? null : () async{
        setState((){
          _isloading = true;
        });
        await Provider.of<Orders>(context,listen: false).addOrder(
          widget.cart.items.values.toList(),
          widget.cart.totalAmount,
        );
        setState((){
          _isloading = false;
        });
        widget.cart.clear();
      },
      child: _isloading ? const CircularProgressIndicator() : const Text(
        "Order Now!",
        style: TextStyle(
          color: Colors.purple,
        ),
      ),
    );
  }
}
