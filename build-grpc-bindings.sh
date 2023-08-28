# Prepare Pyhton dependencies
pip3 install -r requirements.txt

# Prepare Dart/Flutter
brew install protobuf
dart pub global activate protoc_plugin
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Generate Python code
mkdir -p ./math_operations_python/
python3 -m grpc_tools.protoc -I. --python_out=./math_operations_python --grpc_python_out=./math_operations_python service.proto

# Generate Dart code
mkdir -p ./math_operations_flutter/lib/src/generated/
protoc --dart_out=grpc:./math_operations_flutter/lib/src/generated service.proto

echo -e "\e[32m\nDart/Flutter and Python bindings have been generated for PROTO definition"