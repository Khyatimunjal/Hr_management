import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import './printable_data.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/services.dart' show PlatformException;

class Offer_letter extends StatelessWidget {
  String name;
  String email;
  String phone;
  String date = DateFormat('dd MMMM, yyyy').format(DateTime.now());
  String designation;
  String ctc;
  String interviewDate;
  String joiningDate;
  String responseDate;
  var uid;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Offer_letter({
    required this.ctc,
    required this.designation,
    required this.email,
    required this.name,
    required this.phone,
    required this.joiningDate,
    required this.responseDate,
    required this.interviewDate,
    required this.uid,
  });
  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context).size.width;
    debugPrint(deviceData.toString());
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.mail_outlined),
              onPressed: () {
                send_Mail();
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () {
                pdfCreate(deviceData);
              },
            ),
          ],
          title: const Text('OFFER LETTER'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _companyImage(),
                      _horizontalSpace(),
                      _companyIfo(context),
                    ]),
                _verticalSpace(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _employeeInfo(name, email, phone, context),
                    _horizontalSpace(),
                    _time(date, context),
                  ],
                ),
                _verticalSpace(),
                Row(
                  children: [
                    _horizontalSpace(),
                    _tittle(context),
                    _horizontalSpace()
                  ],
                ),
                _verticalSpace(),
                _content(name, date, designation, ctc, joiningDate, deviceData,
                    context, responseDate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<pw.Document> pdfCreate(deviceData) async {
    final nameEncoded = Uri.encodeComponent(name);
    final nameDecoded = Uri.decodeComponent(nameEncoded);
    final emailEncoded = Uri.encodeComponent(email);
    final emailDecoded = Uri.decodeComponent(emailEncoded);
    final phoneEncoded = Uri.encodeComponent(phone);
    final dateEncoded = Uri.encodeComponent(date);
    final dateDecoded = Uri.decodeComponent(dateEncoded);
    final designationEncoded = Uri.encodeComponent(designation);
    final ctcEncoded = Uri.encodeComponent(ctc);
    final joiningDateEncoded = Uri.encodeComponent(joiningDate);
    final joiningDateDecoded = Uri.decodeComponent(joiningDateEncoded);
    final responseDateEncoded = Uri.encodeComponent(responseDate);
    final responseDateDecoded = Uri.decodeComponent(responseDateEncoded);
    final image = await imageFromAssetBundle('assets/images/xornor.png');

    final ttf = null;
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return printableData(
              image,
              nameDecoded,
              emailDecoded,
              phoneEncoded,
              dateDecoded,
              designationEncoded,
              ctcEncoded,
              joiningDateDecoded,
              deviceData,
              context,
              ttf,
              responseDateDecoded);
        },
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
    return doc;
  }

  Future<void> send_Mail() async {
    //Asynchronous function for gmail ,package - flutter_email_sender
    print(uid);
    final smtpServer = SmtpServer(
      'sandbox.smtp.mailtrap.io',
      username: '9f6fc7b152a64c',
      password: '4b90db4f45719b',
      port: 2525,
    );

    try {
      final message = Message()
        ..from = const Address('khyatim03@gmail.com', 'Khyati')
        ..recipients.add(email)
        ..subject = 'Offer Letter'
        ..html = 'Click on the link to your offer letter.'
            '<a href="${"http://localhost/programs/offer_letter.html?id=$uid".toString()}">Click Here</a>';

      final File pdfFile = File('downloads/sample.pdf');
      message.attachments.add(FileAttachment(pdfFile));

      final sendReport = await send(message, smtpServer);

      if (sendReport != null) {
        debugPrint('Message sent successfully');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Mail sent successfully!')),
        );
      } else {
        debugPrint('Failed to send the message');
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }
}

Widget _horizontalSpace() {
  //Function to provide horizontal space
  return const Expanded(
    flex: 1,
    child: SizedBox(
      width: 50,
      height: 5,
    ),
  );
}

Widget _verticalSpace() {
  //Function to provide vertical space
  return const SizedBox(
    height: 20,
  );
}

Widget _companyImage() {
  //Returns image location
  return Expanded(
    flex: 2,
    child: Container(
      alignment: Alignment.topLeft,
      child: Image.asset('assets/images/xornor.png'),
    ),
  );
}

Widget _companyIfo(context) {
  //Returns a string containing comapany info
  return const Expanded(
    flex: 2,
    child: FittedBox(
      alignment: Alignment.topRight,
      child: Text(
        'Xornor Technologies Pvt. Ltd\nD-151, INDUSTRIAL AREA, PHASE 8, Mohali, Punjab, 160055, India\n+917009718003 , +91-172-4347608\nCIN: U72200PB2016PTC045439\nwww.xornor.co',
      ),
    ),
  );
}

Widget _employeeInfo(String name, email, phone, context) {
  //Returns a string containing employee info
  return Expanded(
    child: FittedBox(
      child: Text(
        'Name: $name\nEmail: $email\nPhone:$phone',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
  );
}

Widget _time(String date, context) {
  return Expanded(
    child: Container(
      alignment: Alignment.topRight,
      child: Text(
        date,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Widget _tittle(context) {
  return const Expanded(
    child: FittedBox(
      child: Text(
        'OFFER OF EMPLOYMENT',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Widget _content(name, date, designation, ctc, joiningDate, deviceData, context,
    responseDate) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Text(
        'Dear $name,\n\n\nWith reference to your application and subsequent interview held on $date , we\'re pleased to offer you the position of $designation in our organization. The detailed appointment letter would be given to you at the time of joining. You are required to join the Company on $joiningDate. Please confirm your joining date via email by $responseDate. \n\nYou will be paid a fixed monthly CTC of Rs $ctc as agreed in salary discussion. \n\nYou are requested to bring original documents along with attested copies of the following at the time of joining- \n\n - Educational certificates \n - Experience and relieving certificates of all the previous organizations \n - Last three salary slips/Bank statements of all the previous organizations \n - Age proof \n - Four passport size photographs \n - ID proof: Passport /Aadhaar Card/Driving license/any other\n - Address proof: Passport /Aadhaar Card/Driving license/any other\n - PAN Card (Must)\n\nWe are excited about the potential that you bring to our company. At Xornor Technologies,we believe that our team  is our biggest strength and we take pride in hiring ONLY the best and the brightest. We are confident that you  would play a significant role in the overall success of the venture and wish you the most enjoyable, learning  packed and truly meaningful experience with Xornor Technologies.\n \nWe look forward to you joining us. Please do not hesitate to call us for any information you may need. Also,  please sign the duplicate of this offer as your acceptance and forward the same to us.\n\n\n\n\n\n\nCongratulations!\n\n\n\n\n\n\n\n\nDinesh Kumar Awasthi\nCo-founder,\n'),
  );
}
