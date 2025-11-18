import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: BankSampahApp()));
}

class BankSampahApp extends StatefulWidget {
  const BankSampahApp({super.key});

  @override
  State<BankSampahApp> createState() => _BankSampahAppState();
}

class _BankSampahAppState extends State<BankSampahApp> {
  Key appKey = UniqueKey();

  @override
  void reassemble() {
    super.reassemble();
    setState(() {
      appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: appKey,
      title: 'Bank Sampah Kita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorSchemeSeed: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
}
