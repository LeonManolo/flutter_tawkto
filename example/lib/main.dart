import 'package:flutter/material.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Tawk'),
          backgroundColor: const Color(0XFFF7931E),
          elevation: 0,
        ),
        body: Tawk(
          directChatLink: 'https://tawk.to/chat/xxxx',
          visitor: TawkVisitor(
            name: 'Leon M',
            additionalAttributes: {
              'userId': '1234567', // key defined by tawk
              'customattribute': 1234, // sometimes its not working for me
              'be14rgec-v': 'working custom attribute' // custom attribute
            }
          ),
          onLoad: () {
            print('Hello Tawk!');
          },
          onLinkTap: (String url) {
            print(url);
          },
          placeholder: const Center(
            child: Text('Loading...'),
          ),
        ),
      ),
    );
  }
}
