import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mydemo/blocs/internet_bloc/internet_bloc.dart';
import 'package:mydemo/screens/Login.dart';
import 'package:mydemo/screens/home.dart'; // Ensure this import matches the correct file path
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
    final client = Supabase.instance.client; // Get SupabaseClient instance

    return BlocProvider(
      create: (context) => InternetBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(), // Set LoginScreen as the initial screen
        routes: {
          '/home': (context) => MyHomePage(
                title: 'Home',
                client: client, // Pass client to MyHomePage
              ),
        },
      ),
    );
  }
}
