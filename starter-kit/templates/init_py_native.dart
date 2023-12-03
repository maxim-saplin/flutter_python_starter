import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'py_file_info.dart';
import 'client.dart';

Future<void> initPyImpl({String host = "localhost", int? port}) async {
  var dir = await getApplicationSupportDirectory();
  var filePath = await _prepareExecutable(dir.path);

  // Ask OS to provide a free port if port is null and host is localhost
  if (port == null && host == "localhost") {
    var serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    port = serverSocket.port;
    serverSocket.close();
    defaultPort = port;
  }

  await shutdownPyIfAnyImpl();

  if (defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {
    await Process.run("chmod", ["u+x", filePath]);
  }
  var p = await Process.start(filePath, [port.toString()]);

  int? exitCode;

  p.exitCode.then((v) {
    exitCode = v;
  });

  // Give a couple of seconds to make sure there're no exceptions upon lanuching Python server

  await Future.delayed(const Duration(seconds: 1));
  if (exitCode != null) {
    throw 'Failure while launching server process. It stopped right after starting. Exit code: $exitCode';
  }
}

Future<String> _prepareExecutable(String directory) async {
  var file = File(p.join(directory, _getAssetName()));
  var versionFile = File(p.join(directory, versionFileName));

  if (!file.existsSync()) {
    ByteData pyExe =
        await PlatformAssetBundle().load('assets/${_getAssetName()}');
    await _writeFile(file, pyExe, versionFile);
  } else {
    // Check version file and asset sizes, version in the file and the constant
    // If they do not match or the version file does not exist, update the executable and version file
    var versionMismatch = false;
    ByteData pyExe =
        await PlatformAssetBundle().load('assets/${_getAssetName()}');
    var loadedBinarySize = pyExe.buffer.lengthInBytes;
    var currentBinarySize = await file.length();
    if (loadedBinarySize != currentBinarySize) {
      versionMismatch = true;
    }

    if (!versionFile.existsSync()) {
      versionMismatch = true;
    } else {
      var fileVersion = await versionFile.readAsString();

      if (fileVersion != currentFileVersionFromAssets) {
        versionMismatch = true;
      }
    }

    if (versionMismatch) {
      await _writeFile(file, pyExe, versionFile);
    }
  }

  return file.path;
}

Future<void> _writeFile(File file, ByteData pyExe, File versionFile) async {
  if (file.existsSync()) {
    file.deleteSync();
  }
  await file.create(recursive: true);
  await file.writeAsBytes(pyExe.buffer.asUint8List());
  await versionFile.writeAsString(currentFileVersionFromAssets);
}

/// Searches for any processes that match Python server and kills those
Future<void> shutdownPyIfAnyImpl() async {
  var name = _getAssetName();

  switch (defaultTargetPlatform) {
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      await Process.run('pkill', [name]);
      break;
    case TargetPlatform.windows:
      await Process.run('taskkill', ['/F', '/IM', name]);
      break;
    default:
      break;
  }
}

String _getAssetName() {
  var name = '';

  if (defaultTargetPlatform == TargetPlatform.windows) {
    name += '${exeFileName}_win.exe';
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    name += '${exeFileName}_osx';
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    name += '${exeFileName}_lnx';
  }
  return name;
}
