import 'package:flutter/material.dart';

class TextFieldPage extends StatefulWidget {
  const TextFieldPage({Key? key}) : super(key: key);

  @override
  State<TextFieldPage> createState() => _TextFieldPageState();
}

class _TextFieldPageState extends State<TextFieldPage> {
  final TextEditingController _inputText = TextEditingController();

  String _showText = '';

  void _indicateText(value) {
    setState(() {
      _showText = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テキストフィールド'),
      ),
      body: Column(
        children: [
          TextField(
            // onChanged: (value) => _indicateText(value),
            controller: _inputText,
          ),
          IconButton(
            onPressed: (() {
              _indicateText(_inputText.text);
            }),
            icon: Icon(Icons.abc_rounded),
          ),
          Text('$_showText'),
        ],
      ),
    );
  }
}
