set -e # halt on any error

proto=""
flutterDir=""
pythonDir=""
exeName="server_py_flutter"

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
        --exeName)
            exeName="$2"
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

if [[ ! -f "$proto" ]]; then
    echo "Error: Protofile '$proto' does not exist"
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

mkdir -p $flutterDir
mkdir -p $pythonDir

# Convert flutterDir and pythonDir to absolute paths
flutterDir=$(realpath "$flutterDir")
pythonDir=$(realpath "$pythonDir")
workingDir=$(dirname "$(realpath "$0")")
protoDir=$(dirname "$proto")
protoFile=$(basename "$proto")

serviceName=$(basename "$proto" .proto)

# echo "proto: $proto"
# echo "flutterDir: $flutterDir"
# echo "pythonDir: $pythonDir"

# Change to assume the flagFile is stored under protoDir

# Update the flagFile path to be stored under protoDir
flagFile="$protoDir/.starterDependenciesInstalled"

if [ ! -f "$flagFile" ]; then
    echo "Initializing dependencies"
    # Prepare Dart/Flutter
    brew install protobuf
    dart pub global activate protoc_plugin
    dart pub global activate flutter_asset_manager

    # Prepare Python dependencies
    # pip3 install -r requirements.txt
    pip3 install grpcio
    pip3 install grpcio-tools
    pip3 install tinyaes
    pip3 install pyinstaller
    touch "$flagFile"
fi

export PATH="$PATH":"$HOME/.pub-cache/bin" # make Dart's protoc_plugin available

# Print the file name with extension
echo "$fileNameWithExtension"

# Generate Dart code
mkdir -p $flutterDir/lib/grpc_generated
cd $protoDir # changing dir to avoid created nexted folders in --dart_out beacause of implicitly following grpc namespaces
protoc --dart_out=grpc:"$flutterDir/lib/grpc_generated" $protoFile
echo "$(pwd)"
cd $workingDir

cd $flutterDir
flutter pub add grpc || echo "Can't add `grpc` to Flutter project, continuing..."
flutter pub add protobuf || echo "Can't add `protobuf` to Flutter project, continuing..."
flutter pub add path_provider || echo "Can't add 'path_provider' to Flutter project, continuing..."
flutter pub add path || echo "Can't add 'path' to Flutter project, continuing..."

# macOS, update entitlements files and disable sandbox
entitlements_file_1="macos/Runner/DebugProfile.entitlements"
entitlements_file_2="macos/Runner/Release.entitlements"

if [ -f "$entitlements_file_1" ]; then
    # H;1h;$!d;x; - this part enables whole file processing (rather than line-by-line)
    entitlements_content=$(echo "$entitlements_content" | sed 'H;1h;$!d;x; s/<key>com\.apple\.security\.app-sandbox<\/key>[[:space:]]*<true\/>/<key>com.apple.security.app-sandbox<\/key>\n\t<false\/>/' "$entitlements_file_1")
    echo "$entitlements_content" > "$entitlements_file_1"
fi

if [ -f "$entitlements_file_2" ]; then
    entitlements_content=$(echo "$entitlements_content" | sed 'H;1h;$!d;x; s/<key>com\.apple\.security\.app-sandbox<\/key>[[:space:]]*<true\/>/<key>com.apple.security.app-sandbox<\/key>\n\t<false\/>/' "$entitlements_file_2")
    echo "$entitlements_content" > "$entitlements_file_2"
fi

# Dart clients
if [[ ! -f "$flutterDir/lib/grpc_generated/client.dart" ]]; then
    cp "$workingDir/templates/client.dart" "$flutterDir/lib/grpc_generated/client.dart"
fi

if [[ ! -f "$flutterDir/lib/grpc_generated/client_native.dart" ]]; then
    cp "$workingDir/templates/client_native.dart" "$flutterDir/lib/grpc_generated/client_native.dart"
fi

if [[ ! -f "$flutterDir/lib/grpc_generated/client_web.dart" ]]; then
    cp "$workingDir/templates/client_web.dart" "$flutterDir/lib/grpc_generated/client_web.dart"
fi

echo "// !Will be rewriten upon \`prepare sources\` or \`build\` actions by Flutter-Python starter kit" > $flutterDir/lib/grpc_generated/py_file_info.dart
echo "const versionFileName = 'server_py_version.txt';" >> $flutterDir/lib/grpc_generated/py_file_info.dart
echo "const exeFileName = '$exeName';" >> $flutterDir/lib/grpc_generated/py_file_info.dart
echo "const currentFileVersionFromAssets = '';" >> $flutterDir/lib/grpc_generated/py_file_info.dart

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