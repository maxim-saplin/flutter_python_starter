set -e # halt on any error

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

if [[ -z "$proto" ]]; then
    echo "Error: Missing required parameter '--proto'"
    exit 1
fi

if [[ -z "$flutterDir" ]]; then
    echo "Error: Missing required parameter '--flutterDir'"
    exit 1
fi

if [[ -z "$pythonDir" ]]; then
    echo "Error: Missing required parameter '--pythonDir'"
    exit 1
fi

# Convert flutterDir and pythonDir to absolute paths
flutterDir=$(realpath "$flutterDir")
pythonDir=$(realpath "$pythonDir")

serviceName=$(basename "$proto" .proto)

# echo "proto: $proto"
# echo "flutterDir: $flutterDir"
# echo "pythonDir: $pythonDir"

flagFile=".starterDependenciesInstalled"
if [ ! -f "$flagFile" ]; then
    echo "Initializing dependencies"
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
    touch "$flagFile"
fi

workingDir=$(dirname "$(realpath "$0")")
protoDir=$(dirname "$proto")
protoFile=$(basename "$proto")

# Print the file name with extension
echo "$fileNameWithExtension"

# Generate Dart code
mkdir -p $flutterDir/lib/grpc_generated
cd $protoDir # changing dir to avoid created nexted folders in --dart_out beacause of implicitly following grpc namespaces
protoc --dart_out=grpc:"$flutterDir/lib/grpc_generated" $protoFile
echo "$(pwd)"
cd $workingDir

cd $flutterDir
flutter pub add grpc
cd $workingDir

# Generate Python code
mkdir -p $pythonDir
cd $protoDir # changing dir to avoid created nexted folders in --dart_out beacause of implicitly following grpc namespaces
python3 -m grpc_tools.protoc -I. --python_out=$pythonDir --grpc_python_out=$pythonDir $protoFile
cd $workingDir

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