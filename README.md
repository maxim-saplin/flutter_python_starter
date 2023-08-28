Run `zsh build-grpc-bindings.sh --proto service.proto --flutterDir app --pythonDir service` in terminal.

It will install all required Python and Dart dependencies (protoс compilers, PyInstaller etc) and (re)create Dart and Python bindings/boilerplate code

- `--proto` - points to gRPC PROTO definition of the service
- `--flutterDir` - location of Flutter app, .dart stubs will be created at `$flutterDir/lib/src/generated`
- `--pythonDir` - location of Python project