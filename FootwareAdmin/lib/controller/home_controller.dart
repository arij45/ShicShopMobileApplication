

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/product/product.dart';

class HomeController extends GetxController{

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference productCollection;



  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescriptionCtrl = TextEditingController();
  TextEditingController productImgCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();

  String category = 'general';
  String brand = 'un branded';
  bool offer = false;

  List<Product> products = [];



  @override
  Future<void> onInit() async {
    productCollection = firestore.collection('products');
    await fetchProducts();
    super.onInit();
  }

  addProduct(){
    try {
      DocumentReference doc = productCollection.doc();
      Product product = Product(

            id: doc.id,
            name: productNameCtrl.text,
            category: category,
            description: productDescriptionCtrl.text,
            price: double.tryParse(productPriceCtrl.text),
            brand: brand,
            image: productImgCtrl.text,
            offer: offer,
          );
      final productJson = product.toJson();
      doc.set(productJson);
      Get.snackbar('Success','Product added successfully',colorText: Colors.green);
      setValueDefault();
    } catch (e) {
      Get.snackbar('Error',e.toString(),colorText: Colors.red);
      print(e);
    }
  }

  fetchProducts() async {

    try {
      QuerySnapshot productSnapshot = await productCollection.get();
      final List<Product> retrievedProducts = productSnapshot.docs.map((doc)=>
          Product.fromJson(doc.data() as Map<String, dynamic>)).toList();
      products.clear();
      products.assignAll(retrievedProducts);
      Get.snackbar('Success', 'Product fetch successfully', colorText: Colors.green);
    } catch (e) {
      Get.snackbar(('Error'), e.toString(),colorText: Colors.red);
      print(e);
    }finally{
      update();
    }
  }

  deleteProduct(String id) async{
    try {
      await productCollection.doc(id).delete();
      fetchProducts();
    } catch (e) {
      Get.snackbar(('Error'), e.toString(),colorText: Colors.red);
    }
  }


  setValueDefault(){
    productNameCtrl.clear();
    productPriceCtrl.clear();
    productDescriptionCtrl.clear();
    productImgCtrl.clear();

    category = 'general';
    brand = 'un branded';
    offer = false;
    update();
  }

}

