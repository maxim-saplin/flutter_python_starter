# Flutter-Python Starter Kit

## General idea/architecture

- Allow to use Python code with all 6 platforms that Flutter supports.
- macOS, Windows and Linux - Python code and runtime are packaged as self-contained/standalone executable (via PyInstaller or Nuitka) and bundled with Flutter app as asset. On the first run Python executable is extracted. It contains a self-hosted gRPC server that responds to calls from the Flutter app.
- Android, iOS, Web (and if needed desktop as well) - use the same Python code hosted remotely.
- Use gRPC proto definition as a single source of truth for API used by both Flutter client and Python server. 
- Have code generation (protoc and scripts within this kit) do boilerplate for Dart and Python and let developers focus on business logic.

<p align="center">
<img src="https://github.com/maxim-saplin/flutter_python_starter/assets/7947027/c599464f-49da-4971-8836-7ee22ed2daa8" alt="drawing" />
</p>

## Requirements fulfilled

- Python code packed as self-contained binary not dependent on local Python installation
- Works in Windows, Linux and macOS
- Flutter UI and Python module run in separate OS processes
- gRPC for communication between Flutter and Python
- PyInstaller builds Python into console app that hosts gRPC service
  - As experimental feature can use Nuitka to building standalone binary (smaller and faster)
- The app can request a free port from OS and ask the server to start listening on this port
- Flutter app carries the built Python binary as asset
- Non-pure Python modules (e.g. those ones referencing NumPy or TensorFlow) can be used
- Flutter app manages lifecycle of Python process (starts and kills it), caches the binary (doesn't extract it on each launch), can support versioning and substitute extracted Python with a newer version from assets
  - Timestamp is used for versioning, i.e. date time of PyInstaller execution is used as binary version
- Compatibility mode with remotely hosted Python module for iOS, Android, Web
  - For web client gRPC Proxy is supported, Dart client helper manages the client channel for the user
- For Flutter there're heler classes that wrap the functionality supporting the above requirements

# Overview

The kit is composed of 2 Bash scripts and a number of template source code files (in Python and Dart) that are used for code generation. You can copy the `starter-kit` folder to your project folder and follow the below instructions to get started.

It is assumed that there're 2 folders that contain Flutter and Python projects. 2 scripts are provided to:
1. Generate gRPC stubs and Dart/Pyhton scaffolding from .proto file and copy them to Flutter project (`prepare-sources.sh`)
2. Bundle Python code and dependencies as assets to Flutter project (`bundle-python.sh`)

On mac/Linux, make them runnable: `chmod -x prepare-sources.sh & chmod -x bundle-python.sh prepare-sources.sh `

There're 4 steps:
1. Preparing sources via `prepare-sources.sh` script
2. Manually adding required implementations of gRPC service in Python part (using generated stubs) and using the service via generated Dart client in Flutter part
3. Building Python part via PyInstaller and bundling it as asset within Flutter project
4. Debugging

## Prerequisites to use starter kit

- Flutter SDK 
- Python 3.9+ 
- Chocolately package manager (for Windows)
- Git Bash terminal (for Windows) - install Git for Windows and Git Bash will be setup
- If using Nuitka with macOS and Windows, official recent release of Pyhthon must be installed (https://www.python.org/downloads/macos/), Apple and Windows store versions of Pyhton won't work
 - After installing on Windows you'll have to manually add Python to PATH system environment variable

## 1. Preparing Sources

### 1. Preparing Flutter and Python projects

Put Flutter app and Python code side by side. Let's assume we have Flutter in `app` folder and `service` folder for Python

### 2. Define gRPC service in .proto file

This is the service definition to be implemented by Python and used by Flutter client.

### 3. Dart and Python boilerplate

Run `./prepare-sources.sh --proto ./service.proto --flutterDir ./app --pythonDir ./server` in terminal. 

On Windows:
 - Use Git Bash
 - For the first run (when dependencies are created) you will need admin right for the shell (run as Administrator Bash or VSCode)

 On Linux:
 - Use `bash ./prepare-sources.sh --proto ./service.proto --flutterDir ./app --pythonDir ./server`

What it does is:
1. Installs all dependencies:
  - gRPC tools to generate Python bindings from .proto file: `grpcio`, `grpcio-tools`
  - PyInstaller to build Python as self-contained executable: `tinyaes`, `pyinstaller`
  - Installs `protobuf` compiler
    - On Ubuntu installs `pip`
  - Installs and activates `protoc_plugin` for Dart
  - Creates `.starterDependenciesInstalled` file next to proto file just to keep tract of the fact that dependencies have been installed and do not repeat the heavy process again
2. (Re)creates Dart and Python gRPC client/server bindings and puts the to corresponding folders (`lib/grpc_generated` for Flutter and Python root)
3. Flutter part
  - Adds `grpc`, `protobuf`, `path`, `path_provider` packages to `pubspec.yaml`
  - Disables sandbox for macOS platform project in order to enable network communication and make gRPC calls possible. For that "macos/Runner/DebugProfile.entitlements" and "macos/Runner/Release.entitlements" files are updated with `com.apple.security.app-sandbox` set to `false`
  - Creates client helpers `client.dart`, `client_native.dart` and `client_web.dart` files that wrap gRPC client instantiation for different platforms
    - `client.dart` needs to be updated manually after creation
    - Generation done once
  - Creates helpers to init and run Python executable from the assets
    - `init_py.dart`, `init_py_native.dart` and `init_py_web.dart`
    - Generation done once
  - Creates `py_file_info.dart` defining Python executable name and it's version that is currently stored in the assets
    - Regenereated/rewritten on each source prate and build

4. Creates template `server.py` file that runs self-hosted gRPC server, it needs to be updated to host the actual service

Script parameters:
- `--proto` - points to gRPC PROTO definition of the service
- `--flutterDir` - location of Flutter app, .dart stubs will be created at `$flutterDir/lib/grpc_generated`
- `--pythonDir` - location of Python project
- `--exeName` (optional) - name of the executable to build Python app into using PyInstaller, defaults to 'server_py_flutter'. Must be unique enough since server lifecycle management logic will be using the name to kill any processes with the name on app close (or start - to garbage collect). When building '_win', '_osx' and '_lnx' postfixes are added automatically based on platform.

Upon successful completion you'd get `Dart/Flutter and Python bindings have been generated for 'service.proto' definition` message

## 2. Manual steps

1. Implement the actual service in Python module 
  - Implement the service using generated stubs, add gRPC generated imports with required definitions:
  ```Python
  from grpc import service_pb2_grpc
  from grpc import service_pb2
  ```
  - Update `server.py` to host the implemented service
2. Update Flutter app to use generated Dart client to call the service
  - Add init to main.dart, e.g.
  ```dart
  Future<void> pyInitResult = Future(() => null);

  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    pyInitResult = initPy();
    runApp(const MainApp());
  }
  ```

  Please not it is suggested to not await init in the main but rather have the app start and let Python start in parallel. Besides, you can handle error in this future later. E.g. you can use FutureBuilder somewhere in the widget tree to display loading spinner and error message.
  - Add Python executable shutdown request in app exit, e.g.:
  ```dart
  class MainAppState extends State<MainApp> with WidgetsBindingObserver {
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
   ```
   - Use gRPC clients that were generated for you and put to ./lib/grpc_generated/*.pdgrpc.dart files. Use `getClientChannel()` method from c`lient.dart` as constructor parameter when creating client:
   ```dart
   NumberSortingServiceClient(getClientChannel())
   ```
  
  3. For iOS, to let the app connect to remote gRPC server, in `ios/Runner/Info.plist` add this:
  ```xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsLocalNetworking</key>
        <true/>
    </dict>
  ```

## 3. Bundling Python

Run `./bundle-python.sh --flutterDir ./app --pythonDir ./server` in terminal. You can pass `--nuitka` flag to use Nuitka compiler instead of PyInstaller. It can provide better performance at a cost of lower stability.

On Windows:
 - Use Git Bash

 On Linux:
 - Use `./bundle-python.sh --flutterDir ./app --pythonDir ./server`
 - Be ready to enter sudo password when `protoc` compiler will be installed via `apt`

What it does:
1. Builds `server.py` via PyInstaller into a single executable file using the name defined in `--exeName` parameter (defaults to 'server_py_flutter')
  - '_win', '_osx' and '_lnx' postfixes are added automatically to `--exeName` based on the platform.
2. Copes the generated executable into `$flutterDir/assets/` folder
3. Adds the asset to `pubspec.yaml`
4. Updates `py_file_info.dart` with the name and version of the bundled Python executable

When building Flutter app you can override host and port via --dart-define, e.g.: 
`flutter build macos --dart-define port=8080 --dart-define host=ajax.com`
This is needed when building Web and mobile clients to allow using remote server.

## 4. Debugging & troubleshooting

1. You can skip running server from Flutter assets and have the app to connect to local server. You can pass in true to `Future<void> initPy([bool doNoStartPy = false])` OR  create a separate `launch.json` config and use --dart-define to set this flag (see example). E.g. the following config is automatically recognized via initPy():
            ```          
              "toolArgs": [
                "--dart-define",
                "useRemote=true",
              ]```
  - You can run server via debugger (or without via `python3 server.py`) and  start Flutter app, they both will be using `localhost:50055` by default
  - Building and bundling Python executable can be slow

 2. To easily test the gRPC server you can run it with python and use `grpcurl` or `evans` command line client, e.g.
  ```bash
  evans service.proto --port 50055
  call SortNumbers
  1, 2, 3 -> Ctrl+D
  ```
3. To test gRPC Web locally you can use gRPC-Web-Proxy binary like that:
 `./grpcwebproxy-v0.15.0-osx-x86_64 --backend_addr=localhost:50055 --backend_tls_noverify --allow_all_origins`
 Binaries can be downloaded from here: https://github.com/improbable-eng/grpc-web/releases - note that they are not signed and on Mac you will need to check Security settings and allow it to run

 4. When playing with servers (built binary or started via python interpreter) watch out for running the server on one port multiple times. You might get errors. You can use the following command to kill processes used by default by this starter kit: `kill -9 $(lsof -ti:50055,8080)`

 5. You manually start generated Python binary from Flutter's `./assets` folder to test it for any issues (what if it crashes)

## Remote server, Android and iOS client, Web client and gRPC Proxy

You can target any client to use remote server, though it is specifically useful with mobile and Web as they can't bundle standalone Python server.

To do so you have 2 capabilities:

1. `defaultPort` and `defaultHost` variables in the generated `cleint.dart `- these define the defaults for server address. 
2. You can override them at build/runtime via --dart-define flags, e.g.:
`flutter build macos --dart-define port=50055 --dart-define host=ajax.com`

Web clients can't work over HTTP2 and require a proxy in front of gRPC server. As of 2023 there's no working in process Python proxy (Sonora doesn't work with Dart client). The 2 options are Envoy suggested by Google and https://github.com/improbable-eng/grpc-web.

## Considerations/Notes

- No cross-compilation, Windows, macOS and Linux are required for the build
- Boilerplate works on with one .proto file. In real project there can be multiple proto files/services, scripts would require manual updates
- Nuitka while being a compiled and faster version can be tricky and unstable. I.e. while building example I got successful complication yet upon running the binary I received error that `numpy` import was not found. Only `pip3 install --upgrade numpy` helped solve the issues
  - As of Sept 2023 Python 3.11 + Nuitka 1.8, example works on macOS and Windows. On Linux binary throws error when starting.
- Linux - only Ubuntu was tested
- When using VSCode and having multiple Python installed, make sure you pick the right one (same used for running scripts and for debugging/editing). I.e. is default system Python interpreter is different from the one picked in VSCode you can get all sort of IDE isses, such as wrong warning from PyLace, failed debugging etc.:
  - Click Python version at the bottom (<img width="162" alt="268485002-c35c413d-37e6-4593-80c6-3a3075eb55ca-2" src="https://github.com/maxim-saplin/flutter_python_starter/assets/7947027/3c8b1a04-86bc-49ea-b5dc-abf4dee06aaf">), in the popup check you got the right Python (recomended in my case was not chosen)

    <img width="611" alt="image" src="https://github.com/maxim-saplin/flutter_python_starter/assets/7947027/afd16979-1749-47dc-9611-79ef480d0629">
