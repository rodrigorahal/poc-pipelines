import boto3
import io
import json
import sys

from zipfile import ZipFile

lambda_client = boto3.client('lambda')
codedeploy_client = boto3.client('codedeploy')


def make_zip_file_bytes(path, name):
    buf = io.BytesIO()
    with ZipFile(buf, 'w') as z:
        z.write(path, name)
    return buf.getvalue()


def update_function_code(function_name):
    response = lambda_client.update_function_code(
        FunctionName=function_name,
        ZipFile=make_zip_file_bytes('./app.zip', 'app.zip'),
        Publish=True,
    )
    target_version = response["Version"]
    return target_version

def get_alias_current_version(function_name):
    response = lambda_client.get_alias(
        FunctionName=function_name,
        Name=f"{function_name}_alias"
    )
    current_version = response["FunctionVersion"]
    return current_version

def create_deployment(application_name, deployment_group_name, current_version, target_version):
    app_spec = {
        "version": 0.0,
        "Resources": [{
            [function_name]: {
                "Type": "AWS::Lambda::Function",
                "Properties": {
                    "Name": function_name,
                    "Alias": f"${function_name}_alias",
                    "CurrentVersion": current_version,
                    "TargetVersion": target_version
                }
            }
        }]
    }

    response = codedeploy_client.create_deployment(
        applicationName=application_name,
        deploymentGroupName=deployment_group_name,
        revision={
            "revisionType": "String",
            "string": {
               "content": json.dumps(app_spec)
            }
        }
    )

    deployment_id = response["deploymentId"]
    return deployment_id

if __name__ == "__main__":
    function_name = sys.argv[0]
    application_name= sys.argv[1]
    deployment_group_name = sys.argv[2]

    target_version = update_function_code()
    print(f"Target version: {target_version}")
    current_version = get_alias_current_version()
    print(f"Current version: {current_version}")
    deployment_id = create_deployment(current_version, target_version)
    print(f"Deployment id: {deployment_id}")
