set -e # halt on any error

proto=""
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

OS=$(uname)

if [[ $OS == "Windows" ]]; then
    python -m PyInstaller --onefile --noconfirm --clean --log-level=WARN --key=MySuperSecretPassword --name=$exeName server.py
else
   python3 -m PyInstaller --onefile --noconfirm --clean --log-level=WARN --key=MySuperSecretPassword --strip --name=$exeName server.py  
fi