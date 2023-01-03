import 'dart:math';

import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../Providers/orders.dart" as ord;

class OrderItem extends StatefulWidget {

  final ord.OrderItem order;

  const OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expanded ? min(widget.order.products.length * 20 + 110, 200) : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text("\$ ${widget.order.amount}"),
              subtitle: Text(DateFormat("dd MMMM yyyy hh:mm").format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: (){
                  setState((){
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _expanded ? min(widget.order.products.length * 20 + 10, 100) : 0,
              // height: widget.order.products.length * 20 +20,
              child: ListView(
                children: widget.order.products.map((e) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      e.title,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "${e.quantity} * \$ ${e.price}",
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
