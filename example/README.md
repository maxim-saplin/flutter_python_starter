A sample of integrating Flutter Desktop Apps with Python by wrapping Python functionality into gRPC service and bundling it as Flutter asset file with self-contained/standalone binary executable (it includes Python runtime and all required dependencies to be independent from local installation).

The app sends int array to Python, has is sorted and received back.

<img width="545" alt="image" src="https://github.com/maxim-saplin/flutter_python_starter/assets/7947027/565f103d-d440-4eab-80c7-3d5b6901d972">

For convenience there 5 VSCode launch configurations in /app folder (Flutter project) that allow to run client app and server in different modes. For Web client gRPC proxy is used, native clients connect directly. They have been tested on macOS, on other platforms they might require fixing (specifically the commands issued in .vscode/tasks.json)

- web app (remote server) - use to run Web Client, doesn't do anything about Python server, expects that you will start gRPC server and gRPC Web Proxy which is listening at 8080
- web app (remote server, auto start) - use to run Web Client, starts server/server.py and launches gRPC Web Proxy on 8080 using `./grpcwebproxy-v0.15.0-osx-x86_64` (other OS's can be found here https://github.com/improbable-eng/grpc-web/releases)
- app (remote server, auto start) - Desktop and Mobile clients, starts server/server.py
- app (remote server) - Desktop and Mobile clients, assumes that you'll start gRPC server listening at 50055 manually
- app - Desktop only, will automatically start server from the assets



# Shortcuts for Bash scripts

chmod 755 ./starter-kit/prepare-sources.sh; chmod 755 ./starter-kit/bundle-python.sh

./starter-kit/prepare-sources.sh --proto ./example/service.proto --flutterDir ./example/app --pythonDir ./example/server
./starter-kit/bundle-python.sh --flutterDir ./example/app --pythonDir ./example/server 
OR
./starter-kit/bundle-python.sh --flutterDir ./example/app --pythonDir ./example/server --nuitka
