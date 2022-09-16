import 'package:dusty_dust/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Test2Screen extends StatefulWidget {
  const Test2Screen({Key? key}) : super(key: key);

  @override
  State<Test2Screen> createState() => _TestScreenState();
}

class _TestScreenState extends State<Test2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test2Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<Box>(  // Box 를 Stream 하는것처럼 동작한다.
            valueListenable: Hive.box(testBox).listenable(),
            builder: (context, box, widget) {
              return Column(
                children: box.values.map((e) => Text(e.toString())).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
