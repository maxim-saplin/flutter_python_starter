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

# Prerequisites to use starter kit

- Flutter SDK 
- Python 3.9+ 
- Chocolately package manager (for Windows)
- Git Bash terminal (for Windows) - install Git for Windows and Git Bash will be setup
- If using Nuitka with macOS and Windows, official recent release must be installed (https://www.python.org/downloads/macos/), Apple and Windows store version of Pyhton won't work
 - After installing on Windows you'll have to manually add Python to PATH system environment variable


# Requirements fulfilled

- Python code packed as self-contained binary not dependent on local Python installation
- Works in Windows, Linux and macOS
- Flutter UI and Python module run in separate OS processes
- gRPC for communication between Flutter and Python
- PyInstaller builds Python into console app that hosts gRPC service
  - As experimental feature can use Nuitka to building standalone binary (smaller and faster)
- The app can request a free port from OS and ask the server to start listening on this port
- Flutter app carries the built Python binary as asset
- Flutter app manages lifecycle of Python process (starts and kills it), caches the binary (doesn't extract it on each launch), can support versioning and substitute extracted Python with a newer version from assets
  - Timestamp is used for versioning, i.e. date time of PyInstaller execution is used as binary version
- Compatibility mode with remotely hosted Python module for iOS, Android, macOS

# Considerations

- No cross-compilation, Windows, macOS and Linux are required for the build
- Boilerplate works on with one .proto file. In real project there can be multiple proto files/services, scripts would require manual updates
- Nuitka while being a compiled and faster version can be tricky and unstable. I.e. while building example I got successful complication yet upon running the binary I received error that `numpy` import was not found. Only `pip3 install --upgrade numpy` helped solve the issues
  - As of Sept 2023 Python 3.11 + Nuitka 1.8, example works on macOS and Windows. On Linux binary throws error when starting.
- Linux - only Ubuntu was tested

# 1. Preparing Sources

## 1. Preparing Flutter and Python projects

Put Flutter app and Python code side by side. Let's assume we have Flutter in `app` folder and `service` folder for Python

## 2. Define gRPC service in .proto file

This is the service definition to be implemented by Python and used by Flutter client.

## 3. Dart and Python boilerplate

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

# 2. Manual steps

1. Implement the actual service in Python module 
  - Implement the service using generated stubs
  - Update `server.py` to host the implemented service
2. Update Flutter app to use generated Dart client to call the service
  - Update the generated `lib/grpc_generated/client.dart` and put the actual class name of gRPC generated client
  - Add init to main.dart, e.g.
  ```Dart
  Future<void> pyInitResult = Future(() => null);

  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    pyInitResult = initPy();
    runApp(const MainApp());
  }
  ```
  Please not it is suggested to not await init in the main but rather have the app start and let Python start in parallel. Besides, you can handle error in this future later. E.g. you can use FutureBuilder somewhere in the widget tree to display loading spinner and error message.
  - Add Python executable shutdown request in app exit, e.g.:
  ```Dart
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
    ```

# 3. Bundling Python

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

# 4. Notes

1. You can skip running bundled server and expect the app to connect to local server. You can pass in true to `Future<void> initPy([bool doNoStartPy = false])`
 - Building and bundling Python can be slow, you can't debug that way.
 - You can decide certain client to use remote server always
 - For simplicity with VSCode you can create a separate `launch.json` config and use --dart-define to set this flag (see example)
 - You can run server via debugger (or without via `python3 server.py`) and also start Flutter app, they both will be using localhost:50055
 2. Tp easily test the gRPC server you can run it with python and use `grpcurl` or `evans` command line client, e.g.
  ```bash
  evans service.proto --port 50055
  call SortNumbers
  1, 2, 3 -> Ctrl+D
  ```

# 5. To Do

1.[ ]  Proper management of /assets
  - [ ] Handle situation when there're already assets defined in pubspec.yaml
  - [ ] When building for a specific platform make sure to remove assets from other platforms to save room
2. [x] Investigate "Do you want the application “app.app” to accept incoming network connections?" request upon first launch, shouldn't be any - fixed, didn't use loopback address when requesting free port from OS
3. [ ] Fix multi instance launch (currently next instance kills old server)
4. [ ] Slow Python startup when launching Flutter app
5. [ ] Awaiting error code on init, see if can be done faster
     ```dart
      // Give couple of seconds to make sure there're no exceptions upon lanuching Python server
      await Future.delayed(const Duration(seconds: 2));
     ```