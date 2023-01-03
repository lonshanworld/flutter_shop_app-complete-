import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:myShop/Screens/auth_screen.dart';
import 'package:myShop/helpers/custom_route.dart';
import '../Providers/auth.dart';
import '../Screens/orders_screen.dart';
import '../Screens/user_product_screen.dart';

class AppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text("Hello everyone"),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.orange,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text("Shop"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Your Orders"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
              // Navigator.of(context).pushReplacement(
              //     CustomRoute(
              //       builder: (ctx) => OrdersScreen(),
              //       settings: null,
              //     )
              // );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Manage Products"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(UsersProductScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("LogOut"),
            onTap: (){
              // Navigator.of(context).popAndPushNamed(AuthScreen.routeName);
              Navigator.of(context).pushReplacementNamed("/");
              Provider.of<Auth>(context,listen: false).logOut();

            },
          ),
        ],
      ),
    );
  }
}
