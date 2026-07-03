import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Task',
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  //String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _auth.userChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  Future<void> _signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _showSnack("Sign Up Successful!");
    }on FirebaseAuthException catch (e) {
      _showSnack("Sign Up Failed: ${e.toString()}");
    }
  }
  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _showSnack("Login Successful!");
    }on FirebaseAuthException catch (e) {
      _showSnack("Login Failed: ${e.toString()}");
    }
  }
  Future<void> _logout() async {
    await _auth.signOut();
    _showSnack("Logged Out!");
  }
  Future<void> _deleteAccount() async {
    try {
      if (_currentUser != null) {
        await _currentUser!.delete();
        _showSnack("Account Deleted Successfully!");
      }
    // ignore: unused_catch_clause
    }on FirebaseAuthException catch (e) {
      _showSnack("Error: Re-login required before deleting account.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Auth")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentUser == null) ...[
                  const Text("Welcome! Please Sign Up or Login", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: _signUp, child: const Text("Sign Up")),
                      ElevatedButton(onPressed: _login, child: const Text("Login")),
                    ],
                  ),
                ] else ...[
                  Text("Logged in as:\n${_currentUser!.email}", 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _logout, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text("Logout"),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _deleteAccount, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Delete Account"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}