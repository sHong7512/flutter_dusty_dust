import 'package:dusty_dust/main.dart';
import 'package:dusty_dust/screen/test2_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TestScreen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<Box>(
            // Box 를 Stream 하는것처럼 동작한다.
            valueListenable: Hive.box(testBox).listenable(),
            builder: (context, box, widget) {
              return Column(
                children: box.values.map((e) => Text(e.toString())).toList(),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);
              print('keys : ${box.keys.toList()}');
              print('values : ${box.values.toList()}');
            },
            child: Text('박스 프린트하기!'),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);

              // box.add('test 3');
              box.put(1000, '새로운 데이터!!!');
            },
            child: Text('데이터 넣기'),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);

              // print(box.get(2));
              print(box.getAt(3));
            },
            child: Text('특정 값 가져오기'),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);

              // box.delete(2);
              box.deleteAt(2);
            },
            child: Text('삭제하기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => Test2Screen()),
              );
            },
            child: Text('다음화면'),
          ),
        ],
      ),
    );
  }
}
