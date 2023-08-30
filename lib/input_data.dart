import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import './offer_letter.dart';

class InputData extends StatefulWidget {
  @override
  State<InputData> createState() => _InputDataState();
}

class _InputDataState extends State<InputData> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _ctcController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _responseDateController = TextEditingController();
  final TextEditingController _interviewDateController =
      TextEditingController();
  var uid;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var uuid = const Uuid();
      uid = uuid.v4();
      print('///////////////////////////');
      print(uid);
      String name = _nameController.text;
      String email = _emailController.text;
      String phone = _phoneController.text;
      String designation = _designationController.text;
      String ctc = _ctcController.text;
      String joiningDate = _joiningDateController.text;
      String responseDate = _responseDateController.text;
      String interviewDate = _interviewDateController.text;

      final offerLetter = OfferLetter(
        name: name,
        email: email,
        phone: phone,
        designation: designation,
        ctc: ctc,
        joiningDate: joiningDate,
        responseDate: responseDate,
        interviewDate: interviewDate,
      );

      createOfferLetter(context, offerLetter);
    }
  }

  Future<void> createOfferLetter(
      BuildContext context, OfferLetter offerLetter) async {
    final docRegister =
        FirebaseFirestore.instance.collection('offer_letter').doc(uid);

    final json = offerLetter.toJson();
    await docRegister.set(json);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Offer_letter(
          ctc: _ctcController.text,
          designation: _designationController.text,
          email: _emailController.text,
          interviewDate: _interviewDateController.text,
          joiningDate: _joiningDateController.text,
          name: _nameController.text,
          phone: _phoneController.text,
          responseDate: _responseDateController.text,
          uid: uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Enter the required fields'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
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
                    decoration: const InputDecoration(labelText: 'Email Id'),
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
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone Number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _designationController,
                    decoration: const InputDecoration(labelText: 'Designation'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Designation is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _ctcController,
                    decoration: const InputDecoration(labelText: 'Ctc'),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Ctc is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101));
                      if (pickedDate != null) {
                        setState(() {
                          _interviewDateController.text =
                              DateFormat('dd MMMM,yyyy').format(pickedDate);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _interviewDateController,
                        decoration:
                            const InputDecoration(labelText: 'Interview Date'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Interview Date is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101));
                      if (pickedDate != null) {
                        setState(() {
                          _joiningDateController.text =
                              DateFormat('dd MMMM,yyyy').format(pickedDate);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _joiningDateController,
                        decoration:
                            const InputDecoration(labelText: 'Joining Date'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Joining Date is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      DateTime? pick = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101));
                      if (pick != null) {
                        setState(() {
                          _responseDateController.text =
                              DateFormat('dd MMMM,yyyy').format(pick);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _responseDateController,
                        decoration:
                            const InputDecoration(labelText: 'Response Date'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Response Date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.account_tree_sharp),
                    label: const Text('Submit'),
                  )
                ],
              ),
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

class OfferLetterPage extends StatelessWidget {
  final OfferLetter offerLetter;

  const OfferLetterPage({super.key, required this.offerLetter});

  @override
  Widget build(BuildContext context) {
    String name = offerLetter.name;
    String email = offerLetter.email;
    String phone = offerLetter.phone;
    String designation = offerLetter.designation;
    String ctc = offerLetter.ctc;
    String joiningDate = offerLetter.joiningDate;
    String responseDate = offerLetter.responseDate;
    String interviewDate = offerLetter.interviewDate;

    var html = '''
      <div style="display: flex; justify-content: space-between; align-items: flex-start;">
        <div style="width: 30%;">
          <img src="assets/images/xornor.png" alt="Company Logo" style="width: 100px; height: 100px;">
        </div>
        <div style="width: 70%; text-align: right;">
          <p style="font-size: 12px; color: #666666;">
            Xornor Technologies Pvt. Ltd<br>
            D-151, INDUSTRIAL AREA, PHASE 8, Mohali, Punjab, 160055, India<br>
            +917009718003, +91-172-4347608<br>
            CIN: U72200PB2016PTC045439<br>
            <a href="https://www.xornor.co" style="font-size: 12px; color: #666666;">www.xornor.co</a><br>
          </p>
        </div>
        <div>
          <b>Name: </b>$name<br>
          <b>Email: </b>$email<br>
          <b>Phone Number: </b>$phone<br>
          <div class="date">
              <h2>Date: <span id="current-date" style="font-size: 16px;"></span></h2>
          </div>
        </div><br>
      </div>

      <p style="font-size: 16px; color: #333333;">Dear $name,</p>
      <br>
      <p style="font-size: 14px; color: #666666;">With reference to your application and subsequent interview held on $interviewDate, we're pleased to offer you the position of $designation in our organization. The detailed appointment letter would be given to you at the time of joining. You are required to join the Company on $joiningDate. Please confirm your joining date via email by $responseDate.</p>

      <p style="font-size: 14px; color: #666666;">You will be paid a fixed monthly CTC of Rs $ctc as agreed in the salary discussion.</p>

      <p style="font-size: 14px; color: #666666;">You are requested to bring original documents along with attested copies of the following at the time of joining:</p>
      <ul style="font-size: 14px; color: #666666;">
          <li>Educational certificates</li>
          <li>Experience and relieving certificates of all the previous organizations</li>
          <li>Last three salary slips/Bank statements of all the previous organizations</li>
          <li>Age proof</li>
          <li>Four passport size photographs</li>
          <li>ID proof: Passport / Aadhaar Card / Driving license / any other</li>
          <li>Address proof: Passport / Aadhaar Card / Driving license / any other</li>
          <li>PAN Card (Must)</li>
      </ul>

      <p style="font-size: 14px;">We are excited about the potential that you bring to our company. At Xornor Technologies, we believe that our team is our biggest strength, and we take pride in hiring ONLY the best and the brightest. We are confident that you would play a significant role in the overall success of the venture and wish you the most enjoyable, learning-packed, and truly meaningful experience with Xornor Technologies.</p>

      <p style="font-size: 14px;">We look forward to you joining us. Please do not hesitate to call us for any information you may need. Also, please sign the duplicate of this offer as your acceptance and forward the same to us.</p>
      <br>
      <p style="font-size: 16px;">Congratulations!</p>
      <br>
      <br>
      <p style="font-size: 14px;">Dinesh Kumar Awasthi</p>
      <p style="font-size: 14px;">Co-founder</p>
    ''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Letter'),
      ),
    );
  }
}

class OfferLetter {
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String ctc;
  final String joiningDate;
  final String responseDate;
  final String interviewDate;

  OfferLetter({
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.ctc,
    required this.joiningDate,
    required this.responseDate,
    required this.interviewDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'designation': designation,
        'ctc': ctc,
        'joiningDate': joiningDate,
        'responseDate': responseDate,
        'interviewDate': interviewDate,
      };
}

Future<String> _getNextDocumentId(CollectionReference collectionRef) async {
  final snapshot = await collectionRef
      .orderBy(FieldPath.documentId, descending: true)
      .limit(1)
      .get();
  if (snapshot.docs.isNotEmpty) {
    final lastDocId = snapshot.docs.first.id;
    final lastId = int.tryParse(lastDocId);
    if (lastId != null) {
      return (lastId + 1).toString();
    }
  }
  return '1';
}
