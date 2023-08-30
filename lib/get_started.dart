import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  GetStartedPageState createState() => GetStartedPageState();
}

class GetStartedPageState extends State<GetStartedPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController companyNameController = TextEditingController();
  List<TextEditingController> addressControllers = [];
  String? _selectedDesignation;
  String? _selectedSender;
  String? _selectedAddress;
  TextEditingController customSenderController = TextEditingController();
  TextEditingController customDesignationController = TextEditingController();
  TextEditingController customAddressController = TextEditingController();
  TextEditingController logoController = TextEditingController();
  TextEditingController backgroundImageController = TextEditingController();
  File? logoImage;
  File? backgroundImage;
  bool _showFloatingPage = false;
  List<String> addresses = [];
  List<String> addressOptions = ["Address 1", "Address 2"];
  List<String> selectedAddresses = [];
  int addressCount = 1;

  @override
  void initState() {
    super.initState();
    _initializeAddressControllers();
    _checkFloatingPageStatus();
  }

  void _initializeAddressControllers() {
    if (addressControllers.isEmpty) {
      addressControllers.add(TextEditingController());
    }
  }

  Future<void> _checkFloatingPageStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showFloatingPage = prefs.getBool('showFloatingPage') ?? true;
    setState(() {
      _showFloatingPage = showFloatingPage;
    });
  }

  Future<void> _dismissFloatingPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showFloatingPage', false);
    setState(() {
      _showFloatingPage = false;
    });
  }

  @override
  void dispose() {
    companyNameController.dispose();
    for (var controller in addressControllers) {
      controller.dispose();
    }
    customSenderController.dispose();
    customDesignationController.dispose();
    logoController.dispose();
    backgroundImageController.dispose();
    super.dispose();
  }

  Future<void> uploadImage() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (picked != null && picked.files.isNotEmpty && mounted) {
      final file = picked.files.first;

      setState(() {
        logoImage = File(file.path!);
        logoController.text = file.name;
      });

      print(file);
    }
  }

  Future<void> uploadBackgroundImage() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (picked != null && picked.files.isNotEmpty && mounted) {
      final file = picked.files.first;

      setState(() {
        backgroundImage = File(file.path!);
        backgroundImageController.text = file.name;
      });

      print(file);
    }
  }

  void _addAddressField() {
    setState(() {
      addressControllers.add(TextEditingController());
      addressCount++;
    });
  }

  void _removeAddressField(int index) {
    setState(() {
      addressControllers.removeAt(index);
      addressCount--;
    });
  }

  Widget buildAddressTextField(String address, int index) {
    return TextFormField(
      initialValue: address,
      onChanged: (value) {
        selectedAddresses[index] = value;
      },
      decoration: InputDecoration(
        labelText: "Address ${index + 1}",
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
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter an address';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Get Started"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's Get to Know Your Company",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: companyNameController,
                  decoration: const InputDecoration(
                    labelText: "Company Name",
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
                      return 'Please enter the company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: logoController,
                  decoration: InputDecoration(
                    labelText: "Logo",
                    suffixIcon: IconButton(
                      onPressed: () {
                        uploadImage();
                      },
                      icon: const Icon(Icons.camera_alt),
                    ),
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
                  ),
                  readOnly: true,
                  onTap: uploadImage,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select the company logo';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: backgroundImageController,
                  decoration: InputDecoration(
                    labelText: "Background Image/Logo",
                    suffixIcon: IconButton(
                      onPressed: () {
                        uploadBackgroundImage();
                      },
                      icon: const Icon(Icons.camera_alt),
                    ),
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
                  ),
                  readOnly: true,
                  onTap: uploadBackgroundImage,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select the background image/logo';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Designation",
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
                  value: _selectedDesignation,
                  items: const [
                    DropdownMenuItem<String>(
                      value: "Software Engineer",
                      child: Text("Software Engineer"),
                    ),
                    DropdownMenuItem<String>(
                      value: "Software Test Engineer",
                      child: Text("Software Test Engineer"),
                    ),
                    DropdownMenuItem<String>(
                      value: "Digital Marketing",
                      child: Text("Digital Marketing"),
                    ),
                    DropdownMenuItem<String>(
                      value: "Other",
                      child: Text("Other"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDesignation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select or enter a designation';
                    }
                    return null;
                  },
                ),
                if (_selectedDesignation == "Other")
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: customDesignationController,
                        decoration: const InputDecoration(
                          labelText: "Custom Designation",
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
                            return 'Please enter a custom designation';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Sender",
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
                  value: _selectedSender,
                  items: const [
                    DropdownMenuItem<String>(
                      value: "Hiring Manager",
                      child: Text("Hiring Manager"),
                    ),
                    DropdownMenuItem<String>(
                      value: "Co-Founder",
                      child: Text("Co-Founder"),
                    ),
                    DropdownMenuItem<String>(
                      value: "Other",
                      child: Text("Other"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select or enter a sender';
                    }
                    return null;
                  },
                ),
                if (_selectedSender == "Other")
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: customSenderController,
                        decoration: const InputDecoration(
                          labelText: "Custom Sender",
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
                            return 'Please enter a custom sender';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 10,
                ),
                for (int i = 0; i < addressCount; i++)
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: addressControllers[i],
                              decoration: InputDecoration(
                                labelText: "Company Address ${i + 1}",
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an address';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (i > 0)
                            IconButton(
                              onPressed: () {
                                if (addressCount > 1) {
                                  _removeAddressField(i);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                            ),
                          IconButton(
                            onPressed: () {
                              _addAddressField();
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 16,
                ),
                if (_selectedAddress != null &&
                    _selectedAddress!.startsWith("Address"))
                  TextFormField(
                    controller: customAddressController,
                    decoration: const InputDecoration(
                      labelText: "Custom Address",
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
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                const SizedBox(
                  height: 16,
                ),
                for (int i = 0; i < selectedAddresses.length; i++)
                  buildAddressTextField(selectedAddresses[i], i),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      List<String> addressesList = addressControllers
                          .map((controller) => controller.text)
                          .toList();
                      if (_selectedAddress != null &&
                          _selectedAddress!.startsWith("Address")) {
                        selectedAddresses.add(customAddressController.text);
                        customAddressController.clear();
                      } else if (_selectedAddress != null) {
                        selectedAddresses.add(_selectedAddress!);
                      }

                      String companyName = companyNameController.text;
                      String designation = _selectedDesignation == "Other"
                          ? customDesignationController.text
                          : _selectedDesignation!;
                      String sender = _selectedSender == "Other"
                          ? customSenderController.text
                          : _selectedSender!;

                      final getstarted = GetStarted(
                        companyName: companyName,
                        addresses: addressesList,
                        designation: designation,
                        sender: sender,
                      );
                      createGetStarted(getstarted);
                      displayMessage(
                          context, "Information stored successfully");
                    }
                  },
                  child: const Text('Submit', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void displayMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Align(alignment: Alignment.center, child: Text(message)),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[500],
    ),
  );
}

void createGetStarted(GetStarted getstarted) async {
  final docGetStarted =
      FirebaseFirestore.instance.collection('get_started').doc();
  getstarted.id = docGetStarted.id;
  final Map<String, dynamic> data = getstarted.toJson();
  data['company_addresses'] = getstarted.addresses;

  await docGetStarted.set(data);
}

class GetStarted {
  String id;
  final String companyName;
  final List<String> addresses;
  final String designation;
  final String sender;

  GetStarted({
    this.id = '',
    required this.companyName,
    required this.addresses,
    required this.designation,
    required this.sender,
  });

  Map<String, dynamic> toJson() => {
        'company name': companyName,
        'company addresses': addresses,
        'designation': designation,
        'sender': sender,
      };
}
