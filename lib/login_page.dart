import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './post_login.dart';
import './registration_page.dart';
import 'forgot_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool rememberMe = false;
  bool passwordVisible = true;

  @override
  void initState() {
    super.initState();
    loadRememberMe();
  }

  Future<void> loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> saveRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
    if (!value) {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<bool> isEmailRegistered(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .where('email', isEqualTo: email)
        .get();
    return snapshot.docs.isNotEmpty;
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateInputs() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    bool isEmailValid = isValidEmail(email);
    bool isPasswordValid = password.isNotEmpty;

    setState(() {
      _isEmailValid = isEmailValid;
      _isPasswordValid = isPasswordValid;
    });

    if (isEmailValid && isPasswordValid) {
      bool isRegisteredEmail = await isEmailRegistered(email);

      if (isRegisteredEmail) {
        final user = User(email: email, password: password);
        await createUser(user);
        saveCredentials(email, password);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PostLogin(user: user)),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content:
                  const Text('Invalid email. Please enter a registered email.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  bool isValidEmail(String email) {
    List<String> parts = email.split('@');
    if (parts.length != 2) {
      return false;
    }

    String domain = parts[1];
    String domainRegex = r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(domainRegex);
    return regex.hasMatch(domain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                icon: const Icon(
                  Icons.email,
                  size: 30,
                ),
                labelText: 'Email',
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                errorText: _isEmailValid ? null : 'Email is required',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: passwordVisible,
              decoration: InputDecoration(
                icon: const Icon(Icons.key),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(
                      () {
                        passwordVisible = !passwordVisible;
                      },
                    );
                  },
                ),
                alignLabelWithHint: false,
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                errorText: _isPasswordValid ? null : 'Password is required',
              ),
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                        saveRememberMe(value!);
                      },
                      activeColor: Colors.blue,
                    ),
                    const Text(
                      'Remember Me',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _navigateToForgotPasswordPage,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  _validateInputs();
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            GestureDetector(
              onTap: _navigateToRegistrationPage,
              child: const Text(
                "Don't have an account yet?",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRegistrationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  void _navigateToForgotPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }
}

Future<void> createUser(User user) async {
  final collectionRef = FirebaseFirestore.instance.collection('users');
  await collectionRef.add(user.toJson());
}

class User {
  String id;
  final String email;
  final String password;

  User({
    this.id = '',
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
