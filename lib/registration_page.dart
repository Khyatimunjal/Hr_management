import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hr_project/login_page.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organisationNameController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _employeeNumberController =
      TextEditingController();
  final TextEditingController _setPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedPhoneNumberRange;
  bool setPasswordVisible = true;
  bool confirmPasswordVisible = true;
  int counter = 1;

  @override
  void initState() {
    super.initState();
    fetchCounter();
  }

  Future<void> fetchCounter() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('counter')
        .doc('register')
        .get();
    setState(() {
      counter = snapshot.exists ? snapshot['count'] + 1 : 1;
    });
  }

  Future<void> updateCounter() async {
    await FirebaseFirestore.instance
        .collection('counter')
        .doc('register')
        .set({'count': counter});
  }

  Future<bool> isEmailRegistered(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .where('email', isEqualTo: email)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      bool isRegisteredEmail = await isEmailRegistered(email);

      if (isRegisteredEmail) {
        displayErrorMessage('The email is already registered.');
      } else {
        String name = _nameController.text.trim();
        String organisation = _organisationNameController.text.trim();
        String phone = _phoneNumberController.text.trim();
        String address = _addressController.text.trim();
        String employee = _employeeNumberController.text.trim();
        String setPassword = _setPasswordController.text.trim();
        String confirmPassword = _confirmPasswordController.text.trim();

        debugPrint('Name: $name');
        debugPrint('Email: $email');
        debugPrint('Organisation: $organisation');
        debugPrint('Phone: $phone');
        debugPrint('Address: $address');
        debugPrint('Employee: $employee');
        debugPrint('Phone Number Range: $_selectedPhoneNumberRange');
        debugPrint('Set Password: $setPassword');
        debugPrint('Confirm Password: $confirmPassword');

        // Proceed with saving the registration
        final register = Registrations(
          id: 'REG-$counter',
          name: name,
          email: email,
          organisation: organisation,
          phoneNumber: int.parse(phone),
          address: address,
          employeeCount: employee,
          setPassword: setPassword,
          confirmPassword: confirmPassword,
        );
        await createRegister(context, register);
        displayMessage(context, "Information stored successfully");
        counter++;
        updateCounter();
      }
    }
  }

  Future<void> displayMessage(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Align(alignment: Alignment.center, child: Text(message)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[500],
      ),
    );
  }

  Future<void> displayErrorMessage(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  Future<void> createRegister(BuildContext context, Registrations register) async {
    final docRegister = FirebaseFirestore.instance.collection('registrations').doc();

    final json = register.toJson();
    await docRegister.set(json);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTRATION'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name is required';
                    } else if (_containsNumbers(value)) {
                      return 'Name should only contain letters';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Id',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email Id is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _organisationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Organisation Name',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Organisation Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Phone Number is required';
                    } else if (value.length != 10) {
                      return 'Phone Number should contain 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _employeeNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Employee Count',
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Employee Count is required';
                          } else if (int.parse(value) == 0) {
                            return "Employee Count can't be 0";
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<String>(
                          onChanged: (value) {
                            setState(() {
                              _selectedPhoneNumberRange = value;
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: '0-10',
                              child: Text('0-10'),
                            ),
                            DropdownMenuItem(
                              value: '11-50',
                              child: Text('11-50'),
                            ),
                            DropdownMenuItem(
                              value: '51-80',
                              child: Text(
                                '51-80',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            DropdownMenuItem(
                              value: '81-100',
                              child: Text('81-100'),
                            ),
                            DropdownMenuItem(
                              value: '>100',
                              child: Text('>100'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _setPasswordController,
                  obscureText: setPasswordVisible,
                  decoration: const InputDecoration(
                    labelText: 'Set Password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: confirmPasswordVisible,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _containsNumbers(String value) {
    return RegExp(r'\d').hasMatch(value);
  }
}

class Registrations {
  String id;
  final String name;
  final String email;
  final String organisation;
  final int phoneNumber;
  final String address;
  final String employeeCount;
  final String setPassword;
  final String confirmPassword;

  Registrations({
    this.id = '',
    required this.name,
    required this.email,
    required this.organisation,
    required this.phoneNumber,
    required this.address,
    required this.employeeCount,
    required this.setPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'organisation': organisation,
        'phone number': phoneNumber,
        'address': address,
        'employee count': employeeCount,
        'set password': setPassword,
        'confirm password': confirmPassword,
      };
}
