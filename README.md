## 1. Preparing Flutter and Python projects

Put Flutter app and Python code side by side. For this example I'm starting with counter at `app` folder and an empty `service` folder

## 2. Define gRPC service in .proto file

This is the service definition to be implemented by Python and used by Flutter client.

## 3. Create Dart and Python bindings from .proto

Run `zsh build-grpc-bindings.sh --proto service.proto --flutterDir app --pythonDir service` in terminal.

It will install all required Python and Dart dependencies (protoс compilers, PyInstaller etc), (re)create Dart and Python bindings/boilerplate code, add `grpc` package to `pubspec.yaml`

- `--proto` - points to gRPC PROTO definition of the service
- `--flutterDir` - location of Flutter app, .dart stubs will be created at `$flutterDir/lib/grpc_generated`
- `--pythonDir` - location of Python project