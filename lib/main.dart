import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nwsezszpfsntephncsdq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53c2V6c3pwZnNudGVwaG5jc2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwMzYyMDUsImV4cCI6MjA5NDYxMjIwNX0.WKtboZhS9BpBwQwVijW_EEfQngyENFhe0ugY0V8jwOA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}
