import boto3
import sys


lambda_client = boto3.client('lambda')

def run(function_name):
    response = lambda_client.invoke(
        FunctionName=function_name
    )

    print(response)

    if response["StatusCode"] != 200:
        raise ValueError("Integration tests failed")
    
    print("Integration tests finished succesfully")


if __name__ == "__main__":
    function_name = sys.argv[1]

    run(function_name)