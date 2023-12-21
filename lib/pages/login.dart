import 'dart:convert';
import 'package:crud/auth/auth_provider.dart';
import 'package:crud/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool invalidUsername = false; //validation check
  bool invalidPassword = false; //validation check

  void performLogin(BuildContext context) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        invalidUsername = usernameController.text.isEmpty ? true : false;
        invalidPassword = passwordController.text.isEmpty ? true : false;
      });
      return;
    } else {
      setState(() {
        invalidUsername = false;
        invalidPassword = false;
      });
    }

    final requestBody = {
      'username': usernameController.text,
      'password': passwordController.text,
    };

    final String body = jsonEncode(requestBody);

    try {
      final response = await http.post(
        Uri.parse("http://darknight35-001-site1.atempurl.com/Account/login"),
        headers: {'Content-Type': "application/json"},
        body: body,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // If the API request is successful, save the token and navigate to the dashboard
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String token = jsonResponse['token'];
        await prefs.setString('token', token);
        if (!context.mounted) return;
        Provider.of<AuthProvider>(context, listen: false).login(token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        // If the API request fails, show an error message
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('API Request Failed'),
            content:
                const Text('Failed to log in. Please check your credentials.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print(error);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Request Failed'),
          content: const Text('Failed to log in. Server Error.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void checkExistingToken(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(token);
    final String? token = prefs.getString('token');
    if (!context.mounted) return;
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    checkExistingToken(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: Colors.amber,
            ),
            Text("Ignition")
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      hintText: "Enter Username",
                      border: const OutlineInputBorder(),
                      errorText:
                          invalidUsername ? "Please enter a username" : null),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    border: const OutlineInputBorder(),
                    errorText:
                        invalidPassword ? "Please enter a password" : null,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  // onPressed: () => performLogin(context),
                  onPressed: () => performLogin(context),
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                    minimumSize: const MaterialStatePropertyAll(
                        Size(double.infinity, 60)),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
