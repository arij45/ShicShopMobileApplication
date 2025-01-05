import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footware_client/pages/login_page.dart';
import 'package:footware_client/pages/product_description_page.dart';
import 'package:footware_client/widgets/multi_select_drop_down.dart';
import 'package:footware_client/widgets/product_card.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../controller/home_controller.dart';
import '../widgets/drop_down_btn.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Homecontroller>(builder: (ctrl) {
      return RefreshIndicator(
        onRefresh: () async {
          ctrl.fetchProducts();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(
                'Shoes Shop',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  GetStorage box = GetStorage();
                  box.erase();
                  Get.offAll(LoginPage());
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ctrl.productCategories.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        ctrl.filterByCategory(ctrl.productCategories[index].name ?? '');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Chip(label: Text(ctrl.productCategories[index].name ?? 'Error')),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropDownBtn(
                      items: ['Rs: Low to High', 'Rs: High to Low'],
                      selectedItemText: 'Sort',
                      onSelected: (selected) {
                        ctrl.sortByPrice(ascending: selected == 'Rs: Low to High' ? true : false);
                      },
                    ),
                  ),
                  Expanded(
                    child: MultiSelectDropDown(
                      items: ['Nike', 'Tory Burch', 'New Balance', 'Sam Edelman','Skechers','Teva','Haflinger','Birkenstock'],
                      onSelectionChanged: (selectedItems) {
                        print(selectedItems);
                        ctrl.filterByBrand(selectedItems);
                      },
                    ),
                  ),
                ],
              ),
              // Wrap GridView.builder with Expanded to ensure it takes the remaining space
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: ctrl.productShowInUi.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      name: ctrl.productShowInUi[index].name ?? 'No name',
                      imageUrl: ctrl.productShowInUi[index].image ?? 'url',
                      price: ctrl.productShowInUi[index].price ?? 0.0,
                      offerTag: '20 % off',
                      onTap: () {
                        Get.to(ProductDescriptionPage(),arguments: {'data':ctrl.productShowInUi[index]});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
