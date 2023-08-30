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

serviceName=$(basename "$proto" .proto)

# echo "proto: $proto"
# echo "flutterDir: $flutterDir"
# echo "pythonDir: $pythonDir"

# Prepare Dart/Flutter
brew install protobuf
dart pub global activate protoc_plugin
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Prepare Pyhton dependencies
# pip3 install -r requirements.txt
pip3 install grpcio
pip3 install grpcio-tools
pip3 install tinyaes
pip3 install pyinstaller

# Generate Dart code
mkdir -p $flutterDir/lib/grpc_generated
protoc --dart_out=grpc:$flutterDir/lib/grpc_generated $proto
# Store current working directory to a variable

currentDir=$(pwd)
cd $flutterDir
flutter pub add grpc
cd $currentDir

# Generate Python code
mkdir -p $pythonDir
python3 -m grpc_tools.protoc -I. --python_out=$pythonDir --grpc_python_out=$pythonDir $proto

# Pyhton boilderplate code for running self-hosted gRPC server
serverpy=$(cat << EOF
$(<templates/server.py)
EOF
)

if [ ! -f "$pythonDir/server.py" ]; then
echo "${serverpy//\$\{serviceName\}/$serviceName}" > "$pythonDir/server.py"
fi

if [ ! -f "$pythonDir/requirements.txt" ]; then
echo "grpcio" > "$pythonDir/requirements.txt"
fi

echo -e "\e[32m\nDart/Flutter and Python bindings have been generated for '$proto' definition"