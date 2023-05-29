import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart';

const title = 'Stripe Payment Example';
const kPublishableKey =
    'pk_test_51N2GkDBqnqSB75ZASvwxTMNXRHgN1h3wouCsOvN0MkcQrE8h2YZE940CSbD57z3fKvjfvehz4tTlZlrYk5V3vXUF00MLO3vBMR';
const kSecretKey =
    'sk_test_51N2GkDBqnqSB75ZAWkbqrzHjcYB2FtT9LhLf7voAAzAYagydEagiH0pGeCB30manqYVesgKtLjrxJQajkmLZzDqt00e2T9Es4B';

void main() {
  // Initialize Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();

  // Assign publishable key to flutter stripe
  Stripe.publishableKey = kPublishableKey;

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: Center(
        child: ElevatedButton(
          child: const Text('Make Payment'),
          onPressed: () async => await makePayment(),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      // STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent('100', 'USD');
      debugPrint('$paymentIntent');

      // STEP 2: Initialize Payment Sheet
      //* we initialize a payment sheet. This will be used to create the payment
      //* sheet modal where we will fill in our card details and pay.
      //* We pass in the client_secret obtained from the payment intent from the
      //* previous step. You have access to a range of parameters here including
      //* style which allows us to select the dark theme!
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret:
                  paymentIntent!['client_secret'], // Gotten from payment intent
              style: ThemeMode.light,
              customerId: paymentIntent!['customer'],
              merchantDisplayName: 'Fady',
              // applePay: const PaymentSheetApplePay(
              //   merchantCountryCode: 'US',
              // ),
            ),
          )
          .then((value) {});

      // STEP 3: Display Payment Sheet
      displayPaymentSheet();
    } catch (e) {
      throw Exception(e);
    }
  }

  // STEP 1: Create Payment Intent — We Start by creating payment intent by
  // defining a createPaymentIntent function that takes the amount we’re
  // paying and the currency.
  //* We send a post request to Stripe with a body containing the currency we’re
  //* paying in and the amount multiplied by 100 so it maintains its value when
  //* it is converted to a double by flutter_stripe. In response, Stripe sends
  //* back a payment intent. We will be using this in STEP 2 to initialize our
  //* payment sheet.
  createPaymentIntent(String amount, String currency) async {
    // Request body
    final body = {
      'amount': calculateAmount(amount),
      'currency': currency,
    };

    try {
      final response = await post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $kSecretKey',
          'content-type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      debugPrint(response.body);
      return json.decode(response.body);
    } catch (e) {
      throw Exception('$e');
    }
  }

  // STEP 3: Display Payment Sheet
  //* The final step is to display the modal sheet.
  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
                SizedBox(height: 16),
                Text('Payment Successful!'),
              ],
            ),
          ),
        );
        // Clear paymentIntent variable after successful payment.
        paymentIntent = null;
      }).onError((error, stackTrace) => throw Exception(e));
    } on StripeException catch (e) {
      debugPrint('Error is: ---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 100,
                ),
                SizedBox(height: 16),
                Text('Payment Failed'),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('$e');
    }
  }

  calculateAmount(String amount) => (int.parse(amount) * 100).toString();
}
