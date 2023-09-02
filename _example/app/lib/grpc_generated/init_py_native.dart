import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'py_file_info.dart';

Future<void> initPyImpl({String host = "localhost", int port = 50055}) async {
  var dir = await getApplicationSupportDirectory();
  var filePath = await _prepareExecutable(dir.path);

  if (defaultTargetPlatform == TargetPlatform.macOS) {
    await Process.run("chmod", ["u+x", filePath]);
  }
  await Process.start(filePath, []);

  // Wait for the server executable to startl,.
  var serverStarted = false;
  while (!serverStarted) {
    try {
      var serverSocket = await ServerSocket.bind(host, port)
          .timeout(const Duration(seconds: 5));
      serverSocket.close();
    } catch (error) {
      serverStarted = true;
    }
  }
}

Future<String> _prepareExecutable(String directory) async {
  var exe = (defaultTargetPlatform == TargetPlatform.windows ? '.exe' : '');
  var file = File(p.join(directory, '$exeFileName$exe'));
  var versionFile = File(p.join(directory, versionFileName));

  if (!file.existsSync()) {
    ByteData pyExe = await PlatformAssetBundle().load('/assets/file$exe');
    await _writeFile(file, pyExe, versionFile);
  } else {
    // Check version file and asset sizes, version in the file and the constant
    // If they do not match or the version file does not exist, update the executable and version file
    var versionMismatch = false;
    ByteData pyExe = await PlatformAssetBundle().load('/assets/file$exe');
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
  await file.delete();
  await file.create(recursive: true);
  await file.writeAsBytes(pyExe.buffer.asUint8List());
  await versionFile.writeAsString(currentFileVersionFromAssets);
}
