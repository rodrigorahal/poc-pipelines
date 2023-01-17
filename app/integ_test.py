import boto3
import json
import sys


lambda_client = boto3.client('lambda')

def run_integ_tests(function_name, a, b):
    payload = {
        "a": a, "b": b
    }
    response = lambda_client.invoke(
        FunctionName=f"{function_name}:{function_name}_alias",
        Payload=json.dumps(payload)
    )

    res_payload = json.loads(response["Payload"].read())

    assert response["StatusCode"] == 200, "Integration tests failed"

    assert res_payload["result"] == a+b, "Integration tests failed"

    print("Integration tests finished succesfully")


if __name__ == "__main__":
    function_name = sys.argv[1]
    run_integ_tests(function_name, 1, 2)