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

  shutdownPyIfAny();

  if (defaultTargetPlatform == TargetPlatform.macOS) {
    await Process.run("chmod", ["u+x", filePath]);
  }
  var p = await Process.start(filePath, [port.toString()],
      runInShell: defaultTargetPlatform == TargetPlatform.linux ? true : false);

  bool exiCodeReuturned = false;

  p.exitCode.whenComplete(() {
    exiCodeReuturned = true;
  });

  // Wait for the server executable to respond..
  var serverStarted = false;
  while (!serverStarted) {
    try {
      var serverSocket = await ServerSocket.bind(host, port ?? 50055)
          .timeout(const Duration(seconds: 1));

      serverSocket.close();
    } catch (error) {
      serverStarted = true;
    }
  }
  // Give couple of seconds to make sure there're no exceptions upon lanuching Python server
  await Future.delayed(const Duration(seconds: 2));
  if (exiCodeReuturned) {
    serverStarted = false;
    throw 'Failure while launching server process. It stopped right after starting';
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
Future<void> shutdownPyIfAny() async {
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
