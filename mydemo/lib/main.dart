import 'package:flutter/material.dart';
import 'package:mydemo/screens/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://khvedmsrixybqfqqqcbx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtodmVkbXNyaXh5YnFmcXFxY2J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg4NjEzNDksImV4cCI6MjAzNDQzNzM0OX0.0jLJHvEuiMpvwEZDXC7l3XRsxQAzGnLvepaZ-2xt2rs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Home'),
    );
  }
}
