A sample of integrating Flutter Desktop Apps with Python by wrapping Python functionality into gRPC service and bundling it as Flutter asset file with self-contained binary executable (it includes Python runtime and all required dependencies to be independent from local installation).

zsh prepare-sources.sh --proto ./_example/service.proto --flutterDir ./_example/app --pythonDir ./_example/service
zsh bundle-python.sh --flutterDir ./_example/app --pythonDir ./_example/service 
OR
zsh bundle-python.sh --flutterDir ./_example/app --pythonDir ./_example/service --nuitka