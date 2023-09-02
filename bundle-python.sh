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