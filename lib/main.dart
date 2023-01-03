import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:myShop/Screens/splash_screen.dart';
import 'package:myShop/helpers/custom_route.dart';

import '../Providers/auth.dart';
import '../Providers/cart.dart';
import '../Providers/orders.dart';
import '../Screens/auth_screen.dart';
import '../Screens/cart_screen.dart';
import '../Screens/edit_product_screen.dart';
import '../Screens/orders_screen.dart';

import '../Screens/product_details_screen.dart';
import '../Screens/user_product_screen.dart';
import '../Screens/product_overview_screen.dart';
import "./Providers/product_provider.dart";

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth,Products>(
          update: (ctx,auth, previousProducts) => Products(auth.token ?? "",auth.userId ?? "",previousProducts == null ? [] : previousProducts.items),
          create: (ctx) => Products("","",[]) ,
        ),
        ChangeNotifierProvider(
          create: (y)=> Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (z)=> Orders("",[],""),
          update: (z, auth, previousOrders) => Orders(auth.token ?? "", previousOrders == null ? [] : previousOrders.orders,auth.userId ?? ""),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) =>
            MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "MyShopApp",
              theme: ThemeData(
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android : CustomPageTransitionBuilder(),
                    TargetPlatform.iOS : CustomPageTransitionBuilder(),
                  }
                ),
              ),
              // home: ProductOverviewScreen(),
              home: auth.isAuth
                  ?
              ProductOverviewScreen()
                  :
              FutureBuilder(
                future: auth.tryAutoLogin() ,
                builder: (ctx,authResultSnapShot)  =>authResultSnapShot.connectionState == ConnectionState.waiting ? SplashScreen(): AuthScreen(),),
              routes: {
                ProductDetailScreen.routeName: (aa) => ProductDetailScreen(),
                CartScreen.routeName : (bb) => CartScreen(),
                OrdersScreen.routeName : (cc) => OrdersScreen(),
                UsersProductScreen.routeName : (dd) => UsersProductScreen(),
                EditProductScreen.routeName : (ee) => EditProductScreen(),
                AuthScreen.routeName :(ff) =>AuthScreen(),
                ProductOverviewScreen.routeName : (gg) => ProductOverviewScreen(),
              },
        ),
      ),
    );
  }
}

