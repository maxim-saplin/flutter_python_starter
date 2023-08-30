from concurrent import futures
import numpy as np

import service_pb2_grpc
import service_pb2

class MathOperations(service_pb2_grpc.MathOperationsServicer):
    def MatrixMultiply(self, request, context):
        arr = np.array(request.values)
        result = np.sort(arr)
        return service_pb2.NumberArray(values=result)