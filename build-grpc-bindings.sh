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

# Code:
serviceName="${proto%.proto}"

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

# Pyhton boilderplate code for running self-hosted gRPC server
serverpy=$(cat << EOF
import sys
from concurrent import futures 
import grpc
from .grpc_generated import ${serviceName}_pb2_grpc

# TODO, import service implementation, e.g.
# from math_operations import MathOperations  

def serve():
  DEFAULT_PORT = 50055
  # Get the port number from the command line parameter    
  port = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PORT
  HOST = f'localhost:{port}'

  server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))

  # TODO, add your gRPC service to self-hosted server, e.g.
  # service_pb2_grpc.add_MathOperationsServicer_to_server(MathOperations(), server)

  server.add_insecure_port(HOST)
  print(f"gRPC server started and listening on {HOST}")
  server.start()
  server.wait_for_termination()
  
if __name__ == '__main__':
  serve()  
EOF
)

echo "$serverpy" >| $pythonDir/server.py
echo -e "\e[32m\nDart/Flutter and Python bindings have been generated for '$proto' definition"