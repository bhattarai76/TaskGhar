// lib/main.dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/user_model.dart';

void main() {
  runApp(const TaskGharApp());
}

class TaskGharApp extends StatelessWidget {
  const TaskGharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskGhar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    setState(() { _isLoading = true; });

    try {
      // 1. Fire the network request using our API service delivery truck
      UserModel loggedInUser = await _apiService.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 2. Success! Read the profile name and role returned from our Python backend
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Success! Welcome back ${loggedInUser.name} (${loggedInUser.role})'),
          ),
        );

        // 🔽 ADDED: This line tells Flutter to switch from the LoginPage to the DashboardPage!
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(user: loggedInUser),
          ),
        );
      }
    } catch (e) {
      // 3. Catch errors (like a wrong password) and display a red pop-up alert
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'TaskGhar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  backgroundColor: Colors.deepPurple
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Log In', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔽 ADDED: This is the new placeholder screen that shows up after you hit "Log In"
class DashboardPage extends StatelessWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskGhar Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Welcome to TaskGhar, ${user.name}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Account Type: ${user.role.toUpperCase()}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}