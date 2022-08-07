import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ファーストページ')),
      body: IconButton(
        onPressed: () {
          // pushで進む
          Navigator.pushNamed(context, '/second');
        },
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
