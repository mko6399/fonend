import 'dart:convert';
import 'dart:io';
import 'package:fonend/pages/productpage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<SharedPreferences> pref = SharedPreferences.getInstance();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    // Add login logic here

                    String email = _emailController.text;
                    String password = _passwordController.text;
                    var json =
                        jsonEncode({"email": email, "password": password});

                    var url = Uri.parse(
                        "https://642021154.pungpingcoding.online/api/login");
                    var response = await http.post(url, body: json, headers: {
                      HttpHeaders.contentTypeHeader: "application/json"
                    });

                    print(response.statusCode);
                    if (response.statusCode == 200) {
                      print(response.body);
                      var jsonStr = jsonDecode(response.body);
                      var tokenlog = jsonStr['token'];
                      print(jsonStr['user']);
                      print("โทเค็นคือ=" + tokenlog);
                      SharedPreferences refer1 = await pref;
                      await refer1.setString(
                          'username', jsonStr['user']['name']);
                      await refer1.setInt('userid', jsonStr['user']['id']);
                      await refer1.setString('token', jsonStr['token']);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => productpages()),
                      );
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Add forgot password logic here
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
