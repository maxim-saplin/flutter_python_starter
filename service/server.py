import sys
from concurrent import futures 
import grpc
from .grpc_generated import service_pb2_grpc

from math_operations import MathOperations  

def serve():
  DEFAULT_PORT = 50055
  # Get the port number from the command line parameter    
  port = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PORT
  HOST = f'localhost:{port}'

  server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))

  service_pb2_grpc.add_MathOperationsServicer_to_server(MathOperations(), server)

  server.add_insecure_port(HOST)
  print(f"gRPC server started and listening on {HOST}")
  server.start()
  server.wait_for_termination()
  
if __name__ == '__main__':
  serve()  
