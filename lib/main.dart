import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app/cardprovider.dart';
import 'package:tinder_app/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Gallery App';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => CardProvider(),
      child: const MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        home: Homepage(),
      ));
}
