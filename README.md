Starter kit for integrating Flutter and Python

- prepare-sources.sh
- /templates
- README.md

A sample of integrated app is available under `_example` folder

# How To

It is assumed that there're 2 folders that contain Flutter and Python projects. There're 3 stages:
1. Preparing sources via `prepare-sources.sh` script
2. Manually adding required implementations of gRPC service in Python part (using generated stubs) and using the service via generated Dart client in Flutter part
3. Building Python part via PyInstaller and bundling it as asset within Flutter project

# Requirements

- Python code packed as self-contained binary not dependent on local Python installation
- Works in Windows, Linux and macOS
- Flutter UI and Python module run in separate OS processes
- gRPC for communication between Flutter and Python
- PyInstaller builds Python into console app that hosts gRPC service
- Flutter app carries the built Python binary as asset
- Flutter app manages lifecycle of Python process (starts and kills it), caches the binary (doesn't extract it on each launch), can support versioning and substitute extracted Python with a newer version from assets
  - Timestamp is used for versioning, i.e. date time of PyInstaller execution is used as binary version
- Compatibility mode with remotely hosted Python module for iOS, Android, macOS

# Considerations

- Boilerplate works on with one .proto file. In real project there can be multiple proto files/services, scripts would require manual updates

# 1. Preparing Sources

## 1. Preparing Flutter and Python projects

Put Flutter app and Python code side by side. Let's assume we have Flutter in `app` folder and `service` folder for Python

## 2. Define gRPC service in .proto file

This is the service definition to be implemented by Python and used by Flutter client.

## 3. Dart and Python boilerplate

Run `zsh prepare-sources.sh --proto ./service.proto --flutterDir ./app --pythonDir ./service` in terminal.

What it does is:
1. Installs all dependencies:
  - gRPC tools to generate Python bindings from .proto file: `grpcio`, `grpcio-tools`
  - PyInstaller to build Python as self-contained executable: `tinyaes`, `pyinstaller`
  - Installs `protobuf` compiler via brew on macOS
  - Installs and activates `protoc_plugin` for Dart
  - Creates `.starterDependenciesInstalled` file next to proto file just to keep tract of the fact that dependencies have been installed and do not repeat the heavy process again
2. (Re)creates Dart and Python gRPC client/server bindings and puts the to corresponding folders
3. Flutter part
  - Adds `grpc`, `protobuf`, `path`, `path_provider` packages to `pubspec.yaml`
  - Disables sandbox for macOS platform project in order to enable network communication and make gRPC calls possible. For that "macos/Runner/DebugProfile.entitlements" and "macos/Runner/Release.entitlements" files are updated with `com.apple.security.app-sandbox` set to `false`
  - Creates client.dart, client_native.dart and client_web.dart files that wrap gRPC client instantiation for different platforms
4. Creates template `server.py` file that runs self-hosted gRPC server, it needs to be updated to host the actual service

Script parameters:
- `--proto` - points to gRPC PROTO definition of the service
- `--flutterDir` - location of Flutter app, .dart stubs will be created at `$flutterDir/lib/grpc_generated`
- `--pythonDir` - location of Python project
- `--exeName` (optional) - name of the executable to build Python app into using PyInstaller, defaults to 'server_py_flutter'. Must be unique enough since server lifecycle management logic will be using the name to kill any processes with the name on app close (or start - to garbage collect).

Upon successful completion you'd get `Dart/Flutter and Python bindings have been generated for 'service.proto' definition` message

# 2. Manual steps

1. Implement the actual service in Python module 
  - Implement the service using generated stubs
  - Update `server.py` to host the implemented service
2. Update Flutter app to use generated Dart client to call the service
  - Update the generated `lib/grpc_generated/client.dart` and put the actual class name of gRPC generated client

# 2. Bundling Python