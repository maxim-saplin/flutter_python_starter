set -e # halt on any error
#set -x

flutterDir=""
pythonDir=""
exeName="server_py_flutter"
nuitka=false

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
        --nuitka)  # Set `nuitka` to `true` if there's a flag `--nuitka`
            nuitka=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

flutterDir=$(realpath "$flutterDir" | sed 's/\/$//')
pythonDir=$(realpath "$pythonDir" | sed 's/\/$//')
workingDir=$(pwd)

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  PYTHON=python
else
  PYTHON=python3
fi

# Check the OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    exeNameFull="${exeName}_win"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    exeNameFull="${exeName}_osx"
else
    exeNameFull="${exeName}_lnx"
fi

$PYTHON -m pip install -r $pythonDir/requirements.txt

cd $pythonDir
if [[ $nuitka == true ]]; then
    export PYTHONPATH="./grpc_generated"
    $PYTHON -m nuitka server.py --standalone --onefile --output-dir=./dist --output-filename="$exeNameFull"
else
    $PYTHON -m PyInstaller --onefile --noconfirm --clean --log-level=WARN --name="$exeNameFull" --paths="./grpc_generated" server.py
fi
cd $workingDir

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    exeNameFull="$exeNameFull.exe"
fi

mkdir -p $flutterDir/assets/
cp $pythonDir/dist/$exeNameFull $flutterDir/assets/

# Check if assets already exists in pubspec.yaml
if ! grep -q "assets:" "$flutterDir"/pubspec.yaml; then
    echo "  assets:" >> "$flutterDir"/pubspec.yaml
    echo "    - assets/" >> "$flutterDir"/pubspec.yaml
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

GREEN='\033[0;32m'
NC='\033[0m'
echo -e "\n${GREEN}Python built and put to $flutterDir/assets/$exeNameFull${NC}"