import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/home_controller.dart';
import 'add_product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (ctrl) {
      return Scaffold (
      appBar: AppBar(
        title: Text('Shoes List'),
        backgroundColor: Colors.white24,
      ),
        body: ListView.builder(
        itemCount: ctrl.products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(ctrl.products[index].name ?? ''), // Changed to show different titles
            subtitle: Text((ctrl.products[index].price ?? 0 ).toString()),
            trailing: IconButton(onPressed: () {
              ctrl.deleteProduct(ctrl.products[index].id ?? '');
               }, icon: Icon(Icons.delete,
              color: Colors.deepPurple,
            )
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Get.to(AddProductPage());
      }, child: Icon(Icons.add,
        color: Colors.deepPurple,
      ),
      ),
      );
    });
  }
}
