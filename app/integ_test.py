import boto3
import json
import sys


lambda_client = boto3.client('lambda')

def run(function_name, a, b):
    payload = {
        "a": a, "b": b
    }
    response = lambda_client.invoke(
        FunctionName=function_name,
        Payload=json.dumps(payload)
    )

    res_payload = json.loads(response["Payload"].read())
    
    print(res_payload)

    assert response["StatusCode"] == 200, "Integration tests failed"

    assert res_payload["result"] == a+b, "Integration tests failed"

    print("Integration tests finished succesfully")


if __name__ == "__main__":
    function_name = sys.argv[1]

    if len(sys.argv) > 2:
        # fail
        run(function_name, 1, "b")
    else:
        run(function_name, 1, 2)