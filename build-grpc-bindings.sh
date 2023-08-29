# Extracting named parameters from Bash script

# Initialize variables
proto=""
flutterDir=""
pythonDir=""

# Loop through command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --proto)
            proto="$2"
            shift 2
            ;;
        --flutterDir)
            flutterDir="$2"
            shift 2
            ;;
        --pythonDir)
            pythonDir="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Prepare Pyhton dependencies
# pip3 install -r requirements.txt
pip3 install grpcio
pip3 install grpcio-tools
pip3 install tinyaes
pip3 install pyinstaller

# Prepare Dart/Flutter
brew install protobuf
dart pub global activate protoc_plugin
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Generate Dart code
mkdir -p ./$flutterDir/lib/grpc_generated
protoc --dart_out=grpc:./$flutterDir/lib/grpc_generated $proto
cd $flutterDir
flutter pub add grpc
cd ..

# Generate Python code
mkdir -p ./$pythonDir/grpc_generated
python3 -m grpc_tools.protoc -I. --python_out=./$pythonDir/grpc_generated --grpc_python_out=./$pythonDir/grpc_generated $proto

echo -e "\e[32m\nDart/Flutter and Python bindings have been generated for '$proto' definition"