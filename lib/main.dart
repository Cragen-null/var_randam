import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(RandomApp());
}

class RandomApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: RandomPage(),
    );
  }
}

class RandomPage extends StatefulWidget {
  @override
  _RandomPageState createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  List<int> selected = [];
  int generateCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    generateCount = prefs.getInt('count') ?? 0;
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('count', generateCount);
  }

  void generateRandomNumbers() {
    final numbers = List.generate(18, (i) => i + 1)..shuffle();
    setState(() {
      selected = numbers.take(3).toList();
      generateCount++;
    });
    _saveCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("乱数生成アプリ"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 中央に □-□-□ のように数字を表示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: selected.map((num) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                width: 70,  // 幅を固定
                height: 70, // 高さを固定

                //padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // 角を丸くする
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  "$num",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: generateRandomNumbers,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 60), // 横幅いっぱい
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontSize: 20),
          ),
          child: Text("乱数生成"),
        ),
      ),
    );
  }
}
