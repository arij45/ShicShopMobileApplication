import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:footware_client/pages/home_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';

import '../model/user/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class LoginController extends GetxController{

  GetStorage box = GetStorage();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference userCollection;

  TextEditingController registerNameCtrl = TextEditingController();
  TextEditingController registerNumberCtrl = TextEditingController();

  TextEditingController loginNumberCtrl = TextEditingController();

  OtpFieldControllerV2 otpController = OtpFieldControllerV2();
  bool otpFieldShown = false;
  int? otpSend ;
  int? otpEnter ;
  User? loginUser;

 @override
  void onReady() {
   Map<String,dynamic>? user = box.read('loginUser');
   if(user != null){
     loginUser = User.fromJson(user);
     Get.to(const HomePage());
   }
    super.onReady();
  }

  @override
  void onInit(){
    userCollection = firestore.collection('users');
    super.onInit();
  }

  addUser(){
    try {
      if (otpSend == otpEnter) {
        DocumentReference doc = userCollection.doc();
        User user = User(

          id: doc.id,
          name: registerNameCtrl.text,
          number: int.parse(registerNumberCtrl.text),

        );
        final userJson = user.toJson();
        doc.set(userJson);
        Get.snackbar(
            'Success', 'User added successfully', colorText: Colors.green);
        registerNumberCtrl.clear();
        registerNameCtrl.clear();
        otpController.clear();
      }
      else {
        Get.snackbar('Error', 'OTP is incorrect', colorText: Colors.red);
      }
    }
        catch (e) {
      Get.snackbar('Error',e.toString(),colorText: Colors.red);
      print(e);
    }
      }

  Future<void> sendOtp() async {
    try {
      // Validate if the fields are empty
      if (registerNameCtrl.text.isEmpty || registerNumberCtrl.text.isEmpty) {
        Get.snackbar('Error', 'Please fill the fields', colorText: Colors.red);
        return;
      }

      // Generate a random OTP (4 digits)
      final random = Random();
      int otp = 1000 + random.nextInt(9000);
      print("Generated OTP: $otp");

      String accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
      String authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
      String fromPhoneNumber = dotenv.env['TWILIO_PHONE_NUMBER'] ?? '';

      // Format the phone number in E.164 format
      // Ensure to prepend the country code (+216 for Tunisia) to the entered number
      String phoneNumber = '+216${registerNumberCtrl.text}';  // Replace this with the correct country code (for Tunisia: +216)

      // Prepare the API URL
      final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

      // Send OTP via Twilio SMS
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': phoneNumber, // Ensure the phone number is in E.164 format (+2165403XXXX)
          'From': fromPhoneNumber,
          'Body': 'Your OTP is: $otp',
        },
      );

      // Decode the response body to JSON (Twilio returns JSON response)
      final responseJson = jsonDecode(response.body);

      String expectedMessage = 'Sent from your Twilio trial account - Your OTP is: $otp';

      // Check the response from Twilio API
      if (responseJson['body'] == expectedMessage) {
        otpFieldShown = true;
        otpSend = otp; // Save the generated OTP for later verification
        Get.snackbar('Success', 'OTP sent successfully', colorText: Colors.green);
      } else {
        // Log the response body to understand the error
        print('Failed to send OTP. Response body: ${response.body}');
        Get.snackbar('Error', 'Failed to send OTP. Try again later.', colorText: Colors.red);
      }
    } on Exception catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'An error occurred. Please try again later.', colorText: Colors.red);
    } finally {
      update(); // Update the state using GetX
    }
  }

  Future<void> loginWithPhone() async{

    try {
      String phoneNumber = loginNumberCtrl.text;
      if(phoneNumber.isNotEmpty){
            var querySnapshot = await userCollection.where('number', isEqualTo: int.tryParse(phoneNumber)).limit(1).get();
            if(querySnapshot.docs.isNotEmpty){
              var userDoc = querySnapshot.docs.first;
              var userData = userDoc.data() as Map<String, dynamic>;
              box.write('loginUser',userData);
              loginNumberCtrl.clear();
              Get.to(const HomePage());
             Get.snackbar('Success', 'Login successful', colorText: Colors.green);
            }
            else {
              Get.snackbar('Error', 'User not found, please register', colorText: Colors.red);
            }
          }
          else{
            Get.snackbar('Error', 'Please enter a phone number', colorText: Colors.red);
          }
    } catch (error) {
      print("Failed to login: $error");
    }
  }


}