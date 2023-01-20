def lambda_handler(event, context):
    if "a" not in event or "b" not in event:
        raise ValueError("a and b are required params")

    a = event["a"]
    b = event["b"]

    res = add(a, b)

    return {"result": res}


def add(a, b):
    return a + b
