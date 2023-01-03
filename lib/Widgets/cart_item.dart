import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../Providers/cart.dart";

class CartItem extends StatelessWidget {

  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.productId,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 25,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_){
        return showDialog(
          context: context,
          builder: (d)=>AlertDialog(
            title: const Text("Are You Sure?"),
            content: const Text("Do you want to remove this item from the cart?"),
            actions: <Widget>[
              TextButton(
                onPressed: (){
                  Navigator.of(d).pop(false);
                },
                child: const Text("No"),
              ),
              TextButton(
                onPressed: (){
                  Navigator.of(d).pop(true);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction){
        Provider.of<Cart>(context,listen: false).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: ListTile(
            // leading: CircleAvatar(
            //   backgroundColor: Colors.orange,
            //   foregroundColor: Colors.purple,
            //   child: Padding(
            //     padding: const EdgeInsets.all(5),
            //     child: FittedBox(
            //       child: Text("\$ ${price}"),
            //     ),
            //   ),
            // ),
            leading: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.orange
              ),
              height: 50,
              width: 100,
              child:  Center(
                child: Text("\$ ${price}",style: TextStyle(color: Colors.purple),),
              ),
            ),
            title: Text(title),
            // subtitle: Text("Total \$ ${(quantity * price).toStringAsFixed(3)}"),
            subtitle: Text("Total \$ ${(quantity * price)}"),
            trailing: Text("$quantity x"),
          ),
        ),
      ),
    );
  }
}
