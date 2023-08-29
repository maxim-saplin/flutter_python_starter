A sample of integrating Flutter Desktop Apps with Python by wrapping Python functionality into gRPC service and bundling it as Flutter asset file with self-contained binary executable (it includes Python runtime and all required dependencies to be independent from local installation).

## 1. Preparing Flutter and Python projects

Put Flutter app and Python code side by side. For this example I'm starting with counter at `app` folder and an empty `service` folder

## 2. Define gRPC service in .proto file

This is the service definition to be implemented by Python and used by Flutter client.

## 3. Dart and Python boilerplate

Run `zsh build-grpc-bindings.sh --proto service.proto --flutterDir app --pythonDir service` in terminal.

What it does is:
1. Installs all dependencies:
  - gRPC tools to generate Python bindings from .proto file: `grpcio`, `grpcio-tools`
  - PyInstaller to build Python as self-contained executable: `tinyaes`, `pyinstaller`
  - Installs `protobuf` compiler via brew on macOS
  - Installs and activates `protoc_plugin` for Dart
2. (Re)creates Dart and Python gRPC client/server bindings and puts the to corresponding folders
3. Adds `grpc` package to `pubspec.yaml`
4. Creates template `server.py` file that runs self-hosted gRPC server, it needs to be updated to host the actual service

Script parameters:
- `--proto` - points to gRPC PROTO definition of the service
- `--flutterDir` - location of Flutter app, .dart stubs will be created at `$flutterDir/lib/grpc_generated`
- `--pythonDir` - location of Python project