import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

printableData(image, name, email, phone, date, designation, ctc, joiningDate,
        deviceData, context, ttf, responseDate) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(0),
      child: pw.Column(
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _companyImage(image),
                _horizontalSpace(),
                _companyInfo(context),
                _verticalSpace(),
              ]),
          _verticalSpace(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _verticalSpace(),
              _employeeInfo(name, email, phone, ttf),
              _horizontalSpace(),
              _time(date, ttf),
            ],
          ),
          _verticalSpace(),
          pw.Row(
            children: [
              pw.SizedBox(width: 135, height: 20),
              _tittle(ttf),
              pw.SizedBox(width: 135, height: 20),
            ],
          ),
          _verticalSpace(),
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _content(name, date, designation, ctc, joiningDate, deviceData,
                    ttf, responseDate),
              ])
        ],
      ),
    );
pw.Widget _horizontalSpace() {
  return pw.Expanded(
    flex: 1,
    child: pw.SizedBox(
      width: 50,
      height: 5,
    ),
  );
}

pw.Widget _verticalSpace() {
  return pw.SizedBox(
    height: 20,
  );
}

pw.Widget _companyImage(image) {
  return pw.Expanded(
    flex: 2,
    child: pw.Container(
      alignment: pw.Alignment.topLeft,
      child: pw.Image(image),
    ),
  );
}

pw.Widget _companyInfo(context) {
  return pw.Expanded(
    flex: 2,
    child: pw.FittedBox(
      alignment: pw.Alignment.topRight,
      child: pw.Text(
        'Xornor Technologies Pvt. Ltd\nD-151, INDUSTRIAL AREA, PHASE 8, Mohali, Punjab, 160055, India\n+917009718003 , +91-172-4347608\nCIN: U72200PB2016PTC045439\nwww.xornor.co',
      ),
    ),
  );
}

pw.Widget _employeeInfo(String name, email, phone, ttf) {
  return pw.Text(
    'Name: $name\nEmail: $email\nPhone:$phone',
    style: pw.TextStyle(font: ttf),
  );
}

pw.Widget _time(String date, ttf) {
  return pw.Expanded(
    child: pw.Container(
      alignment: pw.Alignment.topRight,
      child: pw.Text(
        date,
        style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
      ),
    ),
  );
}

pw.Widget _tittle(ttf) {
  return pw.Expanded(
    child: pw.FittedBox(
      child: pw.Container(
        child: pw.Text(
          'OFFER OF EMPLOYMENT',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

pw.Widget _content(
    name, date, designation, ctc, joiningDate, deviceData, ttf, responseDate) {
  return pw.Container(
    width: double.infinity,
    child: pw.Expanded(
      child: pw.Text(
        'Dear $name,\n\n\n With reference to your application and subsequent interview held on $date , we\'re pleased to offer you the position  of $designation in our organization. The detailed appointment letter would be given to you at the time of joining. You are required to join the Company on $joiningDate. Please confirm your joining date via email by $responseDate. \n\nYou will be paid a fixed monthly CTC of Rs $ctc as agreed in salary discussion. \n\nYou are requested to bring original documents along with attested copies of the following at the time of joining- \n\n - Educational certificates \n - Experience and relieving certificates of all the previous organizations \n - Last three salary slips/Bank statements of all the previous organizations \n - Age proof \n - Four passport size photographs \n - ID proof: Passport /Aadhaar Card/Driving license/any other\n - Address proof: Passport /Aadhaar Card/Driving license/any other\n - PAN Card (Must)\n\nWe are excited about the potential that you bring to our company. At Xornor Technologies,we believe that our team  is our biggest strength and we take pride in hiring ONLY the best and the brightest. We are confident that you  would play a significant role in the overall success of the venture and wish you the most enjoyable, learning  packed and truly meaningful experience with Xornor Technologies.\n \nWe look forward to you joining us. Please do not hesitate to call us for any information you may need. Also,  please sign the duplicate of this offer as your acceptance and forward the same to us.\n\n\n\nCongratulations!\n\nDinesh Kumar Awasthi\nCo-founder\n',
        style: pw.TextStyle(font: ttf),
      ),
    ),
  );
}

pw.Document generateOfferLetter() {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text('Offer Letter'),
        );
      },
    ),
  );

  return pdf;
}

void sendEmailWithAttachment() async {
  final pdf = generateOfferLetter();
  final pdfBytes = await pdf.save();

  final message = Message()
    ..from = const Address('khyatim03@gmail.com', 'Khyati Munjal')
    ..recipients.add('recipient@example.com')
    ..subject = 'Offer Letter'
    ..text = 'Click on the link to your offer letter.'
        '<a href="${"http://localhost/programs/offer_letter.html".toString()}">Click Here</a>';

  final smtpServer = SmtpServer('sandbox.smtp.mailtrap.io',
      username: '9f6fc7b152a64c', password: '4b90db4f45719b', port: 2525);

  try {
    final sendReport = await send(message, smtpServer);
    print('Email sent: ${sendReport.toString()}');
  } catch (e) {
    print('Error sending email: $e');
  }
}
