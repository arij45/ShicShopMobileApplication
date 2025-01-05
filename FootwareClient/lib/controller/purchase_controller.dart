import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:footware_client/controller/login_controller.dart';
import 'package:footware_client/pages/home_page.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'dart:convert';

import '../model/user/user.dart';


class PurchaseController extends GetxController {

  double orderPrice = 0;
  String itemName = '';
  String orderAddress = '';

  @override
  void onInit() {

    orderCollection = firestore.collection('orders');
    super.onInit();
    _initDeepLinkListener();

  }

  void _initDeepLinkListener() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // Check the path of the URL
        if (uri.host == 'payment-success') {
          // Handle successful payment
          Get.snackbar('Payment Success', 'Your payment was successful.',colorText: Colors.green);
        } else if (uri.host == 'payment-cancelled') {
          // Handle cancelled payment
          Get.snackbar('Payment Cancelled', 'Your payment was cancelled.',colorText: Colors.red);
        }
      }
    });
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference orderCollection;

  TextEditingController addressController = TextEditingController();

 Future <void> createPayPalPayment({
    required double price,
    required String item,
    required String description,
  }) async {

    orderPrice = price;
    itemName = item ;
    orderAddress = addressController.text;
    print('$orderPrice $itemName $orderAddress');

    const clientId = 'AekOUs9wkvVpMWDLDi0G-b933JW7d-Mg77-QF-SGz5mBcOgDAB9KGWiQeUpQhMm4luGmXyzOoPfFx0cA';
    const secretKey = 'EIx-9-14YO4K0O46QYBLmoYjvnFYZj3EK25uQOVgCYdBSoP5oTorC0EZQRa6T_bTnUhqyQjaG98ZVQJl';

    // Step 1: Get an Access Token
    final auth = base64Encode(utf8.encode('$clientId:$secretKey'));
    final tokenResponse = await http.post(
      Uri.parse('https://api.sandbox.paypal.com/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic $auth',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'grant_type=client_credentials',
    );

    final tokenData = json.decode(tokenResponse.body);
    final accessToken = tokenData['access_token'];

    // Step 2: Create a Payment
    final paymentResponse = await http.post(
      Uri.parse('https://api.sandbox.paypal.com/v1/payments/payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode({
        "intent": "sale",
        "redirect_urls": {
          "return_url": "myapp://payment-success",
          "cancel_url": "myapp://payment-cancelled"
        },
        "payer": {"payment_method": "paypal"},
        "transactions": [
          {
            "amount": {
              "total": price.toStringAsFixed(2),
              "currency": "USD"
            },
            "name" : item,
            "description": description
          }
        ]
      }),
    );

    if (paymentResponse.statusCode == 201) {
      final paymentData = json.decode(paymentResponse.body);
      print("Payment created successfully: $paymentData");
      // Log the full response data for debugging
      print("teeeeeeeeeeeeeeeeeeeeeeessssssssssssssstttttt" + paymentData.toString());
      orderSuccess(transactionId: paymentData['id']);


      // Step 3: Retrieve approval URL from response
      final approvalUrl = paymentData['links']
          .firstWhere((link) => link['rel'] == 'approval_url')['href'];

      // Step 4: Launch the approval URL in a browser or webview
      if (await canLaunch(approvalUrl)) {
        await launch(approvalUrl); // This opens the PayPal approval page
      } else {
        print("Could not launch $approvalUrl");
      }
    } else {
      print("Failed to create payment: ${paymentResponse.statusCode} ${paymentResponse.body}");
    }
  }

  Future<void> orderSuccess({required String? transactionId}) async {
   User? loginUser = Get.find<LoginController>().loginUser;
   try{
     if(transactionId != null){
       DocumentReference docRef = await orderCollection.add({
         'customer':loginUser?.name ??'',
         'phone':loginUser?.number ?? '',
         'item' : itemName,
         'price' : orderPrice,
         'address' : orderAddress,
         'transactionId' : transactionId,
         'dateTime': DateTime.now().toString(),
       });
       print("Order Created Successfully: ${docRef.id}");
       Get.snackbar('Success','Order Created Successfully', colorText: Colors.green);
       showOrderSuccessDialog(docRef.id);
     } else {
       Get.snackbar('Error','Please fill all fields', colorText: Colors.red);
     }
   }
   catch(error){
     print("Failed to register user: $error");
     Get.snackbar('Error','Failed to create Order', colorText: Colors.red);
   }
  }

  void showOrderSuccessDialog(String orderId){
   Get.defaultDialog(
     title: "Order Success",
     content: Text("Your OrderId is $orderId"),
     confirm: ElevatedButton(onPressed: (){
       Get.off(const HomePage());
     },
     child: const Text("Close"),
   ),
   );
  }
}
