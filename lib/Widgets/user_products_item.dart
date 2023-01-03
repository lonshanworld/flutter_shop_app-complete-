import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import '../Providers/product_provider.dart';
import '../Screens/edit_product_screen.dart';

class UserProductsItem extends StatelessWidget {

  final String id;
  final String title;
  final String ImageUrl;

  const UserProductsItem(this.id,this.title, this.ImageUrl);

  @override
  Widget build(BuildContext context) {
    final scaff = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(ImageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: id);
              }, 
              icon: const Icon(Icons.edit, color: Colors.blue,),
            ),
            IconButton(
              onPressed: () async{
                try{
                  await Provider.of<Products>(context,listen: false).deleteProduct(id);
                }catch(err){
                  scaff.showSnackBar(
                    const SnackBar(content: Text("Deleting Failed!",textAlign: TextAlign.center,)),
                  );
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red,),
            ),
          ],
        ),
      ),
    );
  }
}
