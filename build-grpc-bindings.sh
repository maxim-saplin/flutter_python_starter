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
pip3 install -r requirements.txt

# Prepare Dart/Flutter
brew install protobuf
dart pub global activate protoc_plugin
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Generate Dart code
mkdir -p ./$flutterDir/lib/src/generated/
protoc --dart_out=grpc:./$flutterDir/lib/src/generated $proto

# Generate Python code
mkdir -p ./$pythonDir/
python3 -m grpc_tools.protoc -I. --python_out=./$pythonDir --grpc_python_out=./$pythonDir $proto

echo -e "\e[32m\nDart/Flutter and Python bindings have been generated for PROTO definition"