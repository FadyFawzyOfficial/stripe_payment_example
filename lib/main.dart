import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

const title = 'Stripe Payment Example';
const kPublishableKey =
    'pk_test_51N2GkDBqnqSB75ZASvwxTMNXRHgN1h3wouCsOvN0MkcQrE8h2YZE940CSbD57z3fKvjfvehz4tTlZlrYk5V3vXUF00MLO3vBMR';

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
}
