set -e # halt on any error

flutterDir=""
pythonDir=""
exeName="server_py_flutter"

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

flutterDir=$(realpath "$flutterDir" | sed 's/\/$//')
pythonDir=$(realpath "$pythonDir" | sed 's/\/$//')
workingDir=$(dirname "$(realpath "$0")")

OS=$(uname)

# Check the OS
if [[ $OS == "Windows" ]]; then
    exeName="${exeName}_win"
elif [[ $OS == "Darwin" ]]; then
    exeName="${exeName}_osx"
else
    exeName="${exeName}_lnx"
fi

cd $pythonDir
if [[ $OS == "Windows" ]]; then
   python -m PyInstaller --onefile --noconfirm --clean --log-level=WARN --name=$exeName server.py
else
   python3 -m PyInstaller --onefile --noconfirm --clean --log-level=WARN --strip --name=$exeName server.py  
fi
cd $workingDir

if [[ $OS == "Windows" ]]; then
    exeName="$exeName.exe"
fi

mkdir -p $flutterDir/assets/
cp $pythonDir/dist/$exeName $flutterDir/assets/

if [[ $OS == "Windows" ]]; then
    exeName="${exeName%.exe}"
fi


# Check if assets already exists in pubspec.yaml
if ! grep -q "assets:" "$flutterDir"/pubspec.yaml; then
    echo "assets:" >> "$flutterDir"/pubspec.yaml
    echo "  - assets/" >> "$flutterDir"/pubspec.yaml
fi

# Get current date time and create a string of the following format '2023_09_02_10_24_56'
currentDateTime=$(date +"%Y_%m_%d_%H_%M_%S")

# Update version in py_file_info.dart

numLines=$(wc -l < "$flutterDir"/lib/grpc_generated/py_file_info.dart)
lastLine=$((numLines - 2))
head -n $lastLine "$flutterDir"/lib/grpc_generated/py_file_info.dart > "$flutterDir"/lib/grpc_generated/py_file_info_temp.dart
mv "$flutterDir"/lib/grpc_generated/py_file_info_temp.dart "$flutterDir"/lib/grpc_generated/py_file_info.dart

echo "const exeFileName = '$exeName';" >> "$flutterDir"/lib/grpc_generated/py_file_info.dart
echo "const currentFileVersionFromAssets = '$currentDateTime';" >> "$flutterDir"/lib/grpc_generated/py_file_info.dart