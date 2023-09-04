A sample of integrating Flutter Desktop Apps with Python by wrapping Python functionality into gRPC service and bundling it as Flutter asset file with self-contained/standalone binary executable (it includes Python runtime and all required dependencies to be independent from local installation).

./prepare-sources.sh --proto ./example/service.proto --flutterDir ./example/app --pythonDir ./example/server
./bundle-python.sh --flutterDir ./example/app --pythonDir ./example/server 
OR
./bundle-python.sh --flutterDir ./example/app --pythonDir ./example/server --nuitka