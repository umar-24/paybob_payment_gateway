// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:paymob_pakistan/paymob_payment.dart';

void main() {
  // Initialize Paymob with your API details
  PaymobPakistan.instance.initialize(
    apiKey: "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRZeU1UZzNMQ0p1WVcxbElqb2lhVzVwZEdsaGJDSjkuNGRMTEpzaVNmSTl6bC1iS3pyVWRpTE9vYjZZdWJZbkFIMkI3YmVsX0k3Uk9IQm81Q1lMMlVDZ3J1R3l4VHVZbDUxTk5IQ3hnOGpYODNuQmxqaGI2M3c=", // Replace with your actual API key
    integrationID: 186106,
    iFrameID: 195331,
    jazzcashIntegrationId: 123456,
    easypaisaIntegrationID: 123456,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color(0xFF007aec),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF007aec)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const PaymentView(),
    );
  }
}

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  PaymobResponse? response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paymob'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network('https://paymob.pk/images/paymobLogo.png'),
            const SizedBox(height: 24),
            if (response != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Success ==> ${response?.success}"),
                  const SizedBox(height: 8),
                  Text("Transaction ID ==> ${response?.transactionID}"),
                  const SizedBox(height: 8),
                  Text("Message ==> ${response?.message}"),
                  const SizedBox(height: 8),
                  Text("Response Code ==> ${response?.responseCode}"),
                  const SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              child: const Text('Pay with Jazzcash'),
              onPressed: () async {
                try {
                  // Initialize payment
                  print("Starting payment initialization...");

                  final paymentResponse = await PaymobPakistan.instance.initializePayment(
                    currency: "PKR",
                    amountInCents: "10000",
                  );

                  // Check if the paymentResponse is null or has null fields
                  if (paymentResponse == null) {
                    print("Error: Payment initialization returned null.");
                    return; // Exit early
                  }

                  // Safely extract authToken and orderID with null checks
                  String? authToken = paymentResponse.authToken;
                  int? orderID = paymentResponse.orderID;

                  // Debugging
                  print("Payment initialization response: $paymentResponse");
                  print("Extracted AuthToken: $authToken");
                  print("Extracted OrderID: $orderID");

                  // Validate extracted values
                  if (authToken == null || orderID == null) {
                    print("Error: authToken or orderID is null.");
                    return; // Exit early
                  }

                  // Proceed with making payment
                  print("Proceeding to make payment with AuthToken: $authToken, OrderID: $orderID");

                  await PaymobPakistan.instance.makePayment(
                    context,
                    currency: "PKR",
                    amountInCents: "10000",
                    paymentType: PaymentType.card, // Set to your preferred payment type
                    authToken: authToken,
                    orderID: orderID,
                    onPayment: (paymentResponse) {
                      if (paymentResponse == null) {
                        print("Error: Payment response is null.");
                        return; // Exit if paymentResponse is null
                      }
                      setState(() {
                        this.response = paymentResponse;
                      });
                    },
                  );
                } catch (err) {
                  // Catch and print any errors during payment process
                  print("Payment error: $err");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
