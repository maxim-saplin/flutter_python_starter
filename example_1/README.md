A sample of integrating Flutter Desktop Apps with Python by wrapping Python functionality into gRPC service and bundling it as Flutter asset file with self-contained/standalone binary executable (it includes Python runtime and all required dependencies to be independent from local installation).

./prepare-sources.sh --proto ./example_1/service.proto --flutterDir ./example_1/app --pythonDir ./example_1/server
./bundle-python.sh --flutterDir ./example_1/app --pythonDir ./example_1/server 
OR
./bundle-python.sh --flutterDir ./example_1/app --pythonDir ./example_1/server --nuitka