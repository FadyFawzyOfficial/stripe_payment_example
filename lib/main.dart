import 'dart:convert';

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

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: const Center(child: Text('Hi, Fady')),
    );
  }

  Future<void> makePayment() async {
    try {
      // STEP 1: Create Payment Intent
      final paymentIntent = await createPaymentIntent('100', 'USD');

      // STEP 2: Initialize Payment Sheet
      //* we initialize a payment sheet. This will be used to create the payment
      //* sheet modal where we will fill in our card details and pay.
      //* We pass in the client_secret obtained from the payment intent from the
      //* previous step. You have access to a range of parameters here including
      //* style which allows us to select the dark theme!
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntent[
                    'client_secret'], // Gotten from payment intent
                style: ThemeMode.light,
                merchantDisplayName: 'Fady'),
          )
          .then((value) {});
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
        Uri.parse('https://api.stripe.com/v1/paymnet_intents'),
        headers: {
          'Authorization': 'Bearer $kSecretKey',
          'content-type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print(response.body);
      return json.decode(response.body);
    } catch (e) {
      throw Exception('$e');
    }
  }

  calculateAmount(String amount) => (int.parse(amount) * 100).toString();
}
