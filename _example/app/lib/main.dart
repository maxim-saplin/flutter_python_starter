import 'dart:math';

import 'package:app/grpc_generated/client.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  List<int> randomIntegers =
      List.generate(40, (index) => Random().nextInt(100));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                randomIntegers.join(', '),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    randomIntegers =
                        List.generate(40, (index) => Random().nextInt(100));
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(140, 36), // Set minimum width to 120px
                ),
                child: const Text('Regenerate List'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    //randomIntegers.sort(); // Sort the array
                    //client.
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(140, 36), // Set minimum width to 120px
                ),
                child: const Text('Sort'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
