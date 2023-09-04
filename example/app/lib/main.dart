import 'dart:math';
import 'dart:ui';

import 'package:app/grpc_generated/client.dart';
import 'package:app/grpc_generated/init_py.dart';
import 'package:app/grpc_generated/init_py_native.dart';
import 'package:app/grpc_generated/service.pbgrpc.dart';
import 'package:flutter/material.dart';

Future<void> pyInitResult = Future(() => null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pyInitResult = initPy(
      const String.fromEnvironment('useRemote', defaultValue: 'false') ==
          'true');
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> with WidgetsBindingObserver {
  List<int> randomIntegers =
      List.generate(40, (index) => Random().nextInt(100));

  @override
  Future<AppExitResponse> didRequestAppExit() {
    shutdownPyIfAny();
    return super.didRequestAppExit();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child:
                    // Add FutureBuilder that awaits pyInitResult
                    FutureBuilder<void>(
                  future: pyInitResult,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Stack(
                        children: [
                          SizedBox(height: 4, child: LinearProgressIndicator()),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                'Loading Python...',
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      // If error is returned by the future, display an error message
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // When future completes, display a message saying that Python has been loaded
                      // Set the text color of the Text widget to green
                      return const Text(
                        'Python has been loaded',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
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
                  //setState(() => randomIntegers.sort());
                  getClient()
                      .sortNumbers(NumberArray(numbers: randomIntegers))
                      .then(
                          (p0) => setState(() => randomIntegers = p0.numbers));
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