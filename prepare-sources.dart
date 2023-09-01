// import 'dart:io';
// import 'package:args/args.dart';
// import 'package:path/path.dart' as path;
// import 'package:process_run/cmd_run.dart';

// void main(List<String> arguments) async {
//   final parser = ArgParser()
//     ..addOption('proto')
//     ..addOption('flutterDir')
//     ..addOption('pythonDir');

//   var args = parser.parse(arguments);

//   final proto = args['proto'] as String?;
//   final flutterDir = args['flutterDir'] as String?;
//   final pythonDir = args['pythonDir'] as String?;

//   if (proto == null || flutterDir == null || pythonDir == null) {
//     print('Error: Missing required parameters');
//     exit(1);
//   }

//   // Convert flutterDir and pythonDir to absolute paths
//   final flutterDirAbs = path.absolute(flutterDir);
//   final pythonDirAbs = path.absolute(pythonDir);

//   final serviceName = path.basenameWithoutExtension(proto);

//   final flagFile = '.starterDependenciesInstalled';
//   if (!File(flagFile).existsSync()) {
//     print('Initializing dependencies');
//     // Prepare Dart/Flutter
//     await runCmd(Cmd('brew install protobuf'));
//     await runCmd(Cmd('dart pub global activate protoc_plugin'));

//     // Prepare Pyhton dependencies
//     await runCmd(Cmd('pip3 install grpcio'));
//     await runCmd(Cmd('pip3 install grpcio-tools'));
//     await runCmd(Cmd('pip3 install tinyaes'));
//     await runCmd(Cmd('pip3 install pyinstaller'));
//     await File(flagFile).create();
//   }

//   // Update PATH
//   // TODO: Add Dart's protoc_plugin to PATH

//   final workingDir = Directory.current.path;
//   final protoDir = path.dirname(proto);
//   final protoFile = path.basename(proto);

//   // Generate Dart code
//   await Directory('$flutterDirAbs/lib/grpc_generated').create(recursive: true);
//   // TODO: Run protoc, requires updating PATH and changing to protoDir first

//   // TODO: Run flutter pub add grpc

//   // TODO: Handle macOS entitlements file update

//   // Generate Python code
//   await Directory('$pythonDirAbs').create();
//   // TODO: Run python3 -m grpc_tools.protoc, requires changing to protoDir first

//   // Python boilerplate code for running self-hosted gRPC server
//   // TODO: Read from templates/server.py, replace serviceName, and write to pythonDir/server.py

//   // TODO: Handle $pythonDir/requirements.txt file creation

//   print(
//       '\nDart/Flutter and Python bindings have been generated for \'$proto\' definition');
// }
