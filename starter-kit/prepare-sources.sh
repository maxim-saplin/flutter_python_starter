#!/bin/bash
set -e # halt on any error
#set -x

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
flutterDir=$(realpath "$flutterDir" | sed 's/\/$//')
pythonDir=$(realpath "$pythonDir" | sed 's/\/$//')
scriptDir=$(dirname "$(realpath "$0")")
workingDir=$(pwd)
protoDir=$(dirname "$proto" | sed 's/\/$//')
grpcGeneratedDir=$flutterDir/lib/grpc_generated
protoFile=$(basename "$proto")

serviceName=$(basename "$proto" .proto)

# Set the Python interpreter name
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  PYTHON=python
  grpcGeneratedDir=$(cygpath -w "$grpcGeneratedDir")
else
  PYTHON=python3
fi


flagFile="$protoDir/.starterDependenciesInstalled"

if [ ! -f "$flagFile" ]; then
    echo "Initializing dependencies"
    echo "$OSTYPE"
    # Prepare Dart/Flutter
    # Update the installation command for different operating systems

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install protobuf
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt install protobuf-compiler
        sudo apt install python3-pip
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows
        choco install protoc
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi


    # Prepare Dart/Flutter
    flutter pub global activate protoc_plugin

    # Prepare Python dependencies
    # pip3 install -r requirements.txt
    $PYTHON -m pip install grpcio
    $PYTHON -m pip install grpcio-tools
    $PYTHON -m pip install tinyaes
    $PYTHON -m pip install pyinstaller
    $PYTHON -m pip install nuitka
    touch "$flagFile"
fi

export PATH="$PATH":"$HOME/.pub-cache/bin" # make Dart's protoc_plugin available

# Print the file name with extension
echo "$fileNameWithExtension"

# Generate Dart code
mkdir -p $grpcGeneratedDir
cd $protoDir # changing dir to avoid created nexted folders in --dart_out beacause of implicitly following grpc namespaces
protoc --dart_out=grpc:"$grpcGeneratedDir" $protoFile
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
if [[ ! -f "$grpcGeneratedDir/client.dart" ]]; then
    cp "$scriptDir/templates/client.dart" "$grpcGeneratedDir/client.dart"
fi
if [[ ! -f "$grpcGeneratedDir/client_native.dart" ]]; then
    cp "$scriptDir/templates/client_native.dart" "$grpcGeneratedDir/client_native.dart"
fi
if [[ ! -f "$grpcGeneratedDir/client_web.dart" ]]; then
    cp "$scriptDir/templates/client_web.dart" "$grpcGeneratedDir/client_web.dart"
fi

if [ ! -f "$grpcGeneratedDir/init_py.dart" ]; then
    cp "$scriptDir/templates/init_py.dart" "$grpcGeneratedDir/init_py.dart"
fi
if [ ! -f "$grpcGeneratedDir/init_py_native.dart" ]; then
    cp "$scriptDir/templates/init_py_native.dart" "$grpcGeneratedDir/init_py_native.dart"
fi
if [ ! -f "$grpcGeneratedDir/init_py_web.dart" ]; then
    cp "$scriptDir/templates/init_py_web.dart" "$grpcGeneratedDir/init_py_web.dart"
fi
if [ ! -f "$grpcGeneratedDir/health.pb.dart" ]; then
    cp "$scriptDir/templates/health.pb.dart" "$grpcGeneratedDir/health.pb.dart"
fi
if [ ! -f "$grpcGeneratedDir/health.pbenum.dart" ]; then
    cp "$scriptDir/templates/health.pbenum.dart" "$grpcGeneratedDir/health.pbenum.dart"
fi
if [ ! -f "$grpcGeneratedDir/health.pbgrpc.dart" ]; then
    cp "$scriptDir/templates/health.pbgrpc.dart" "$grpcGeneratedDir/health.pbgrpc.dart"
fi
if [ ! -f "$grpcGeneratedDir/health.pbjson.dart" ]; then
    cp "$scriptDir/templates/health.pbjson.dart" "$grpcGeneratedDir/health.pbjson.dart"
fi



echo "// !Will be rewriten upon \`prepare sources\` or \`build\` actions by Flutter-Python starter kit" > $grpcGeneratedDir/py_file_info.dart
echo "const versionFileName = 'server_py_version.txt';" >> $grpcGeneratedDir/py_file_info.dart
echo "const exeFileName = '$exeName';" >> $grpcGeneratedDir/py_file_info.dart
echo "const currentFileVersionFromAssets = '';" >> $grpcGeneratedDir/py_file_info.dart

cd $workingDir

# Generate Python code
mkdir -p $pythonDir
mkdir -p $pythonDir/grpc_generated
cd $protoDir # changing dir to avoid created nested folders in --dart_out beacause of implicitly following grpc namespaces
$PYTHON -m grpc_tools.protoc -I. --python_out=$pythonDir/grpc_generated --grpc_python_out=$pythonDir/grpc_generated $protoFile
cd $workingDir
cp $scriptDir/templates/__init__.py $pythonDir/grpc_generated

# Pyhton boilderplate code for running self-hosted gRPC server
serverpy=$(cat << EOF
$(<$scriptDir/templates/server.py)
EOF
)

if [ ! -f "$pythonDir/server.py" ]; then
echo "${serverpy//\$\{serviceName\}/$serviceName}" > "$pythonDir/server.py"
fi

if ! grep -q "^grpcio" "$pythonDir/requirements.txt"; then
  echo -e "\ngrpcio" >> "$pythonDir/requirements.txt"
fi

if ! grep -q "^grpcio-health-checking" "$pythonDir/requirements.txt"; then
  echo -e "\ngrpcio-health-checking" >> "$pythonDir/requirements.txt"
fi

GREEN='\033[0;32m'
NC='\033[0m'
echo -e "\n${GREEN}Dart/Flutter and Python bindings have been generated for '$proto' definition${NC}"