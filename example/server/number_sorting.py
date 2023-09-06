from concurrent import futures
import numpy as np
from grpc_generated import service_pb2_grpc
from grpc_generated import service_pb2

class NumberSortingService(service_pb2_grpc.NumberSortingService):
    def SortNumbers(self, request, context):
        arr = np.array(request.numbers)
        result = np.sort(arr)
        print(f"Sorted {len(result)} numbers")
        return service_pb2.NumberArray(numbers=result)