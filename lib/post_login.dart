import 'package:flutter/material.dart';
import './get_started.dart';
import './input_data.dart';
import 'login_page.dart';

class PostLogin extends StatelessWidget {
  final User user;
  const PostLogin({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => InputData()),
                );
              },
              child: const Text('Offer Letter'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const GetStartedPage()));
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
