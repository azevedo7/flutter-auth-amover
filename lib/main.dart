import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:flutter_appauth/flutter_appauth.dart';

FlutterAppAuth appAuth = FlutterAppAuth();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Login(title: 'Login App'),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    const String clientId = 'flutter-client';
    const String redirectUrl = 'com.example.app:/oauthredirect';
    const String issuer = 'http://localhost:8843/realms/appAuth';
    const String tokenUrl =
        'http://localhost:8843/realms/appAuth/protocol/openid-connect/token';

    try {
      // final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
      //   AuthorizationTokenRequest(
      //     clientId,
      //     redirectUrl,
      //     issuer: issuer,
      //     scopes: ['openid', 'profile', 'email'],
      //   ),
      // );

      // if (result != null) {
      //   print('Access Token: ${result.accessToken}');
      //   print('ID Token: ${result.idToken}');
      //   // Navigate to a logged-in page or perform authenticated actions
      // }

      Dio dio = Dio();

      final response = await dio.post(tokenUrl,
              data: {
                'grant_type': 'password',
                'client_id': clientId,
                'username': email,
                'password': password,
              },
              options: Options(contentType: Headers.formUrlEncodedContentType),
            );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        print('Access Token: $accessToken');
        print('Refresh Token: $refreshToken');
        // Navigate to a logged-in page or store tokens securely
      } else {
        print('Login failed: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials')),
      );
    }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ]),
        ),
      ),
    );
  }
}
