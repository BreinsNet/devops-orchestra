# Tools plugin

[[_TOC_]]

This plugin is used as a script wrapper to be able to perform any platform tasks

## Requirements

- helm version >= 3.5
- docker client and server
- aws cli v2
- groovy
- jdk 11
- bash

## Usage

```groovy
plugins {
    id 'com.waitrose.ecomm.wtr-ecomm-platform.tools' version VERSION
}
```
## GIT

### Configuration

```groovy
git {
    path = '/path/were/to/run/git/commands'
}

```

### Tasks

- gitClean

## Sam

### Configuration

```groovy
sam {
    [
        templateFile: '<the path of the target CFN template>',
        stackName: '<The cloudformation stack name>',
        region = 'us-east-1'
        parameters: [
            KEY: 'VALUE',
            KEY: 'VALUE'
        ],
        capabilities: [
            'CAPABILITY_NAMED_IAM'
        ],
    ]
}

```

NOTE: parameters, region and capabilities are optional

### Tasks

- samValidate
- samDeploy
- samDelete
- samChangeSet

## Cloudformation

### Configuration

```groovy
cfn {
    templates = [
        [
            filePath: '<the path of the target CFN template>',
            stackName: '<The cloudformation stack name>',
            cfnParams: [
                KEY: 'VALUE',
                KEY: 'VALUE'
            ],
            capabilities: [
                'CAPABILITY_NAMED_IAM'
            ],
        ],
        [
            filePath: '<the path of the target CFN template>',
            stackName: '<The cloudformation stack name>',
            cfnParams: [
                KEY: 'VALUE',
                KEY: 'VALUE'
            ],
            capabilities: [
                'CAPABILITY_AUTO_EXPAND',
                'CAPABILITY_NAMED_IAM'
            ],
        ]
    ]
}

```

NOTE: cfnParams and capabilities are optional

### Tasks

- cfnLint
- cfnValidate
- cfnDeploy
- cfnDelete

## Docker

### Configuration

```groovy
docker {
    tag = '<docker tag>'
    imageName = '<docker image name>'
    servicePort = '<service port, must respond 200>'
    url = '<Registry URL>'
}
```

NOTE: servicePort is optional

### Tasks

- dockerLint
- dockerTest
- dockerBuild
- dockerScan
- dockerPush

## Helm

### Configuration

```groovy
helm {
    namespace = '(String): Kubernetes namespace>'
    chartName = '(String): Helm name to install the chart'
    valuesList = '(List<String> - optional) will use values.yaml and values-${value}.yaml'
    setKeyValue = '(Map<String,String> - optional) will use a --set override any key/values'
    timeout = '(String - optional) will use a --timeout in helm install'
}

```

### Tasks

- helmLint
- helmInstall
- helmTest
- helmUninstall

## Groovy

### Tasks

- groovyLint

## AWS

### Configuration

```groovy
aws {
    ssmToYaml = [
      key: '(String): The SSM key to be retrieved , converted to a yaml file'
      file: '(String): The destination file'
    ]
    clusterName = '<EKS cluster name>'
    bucketName = 'The bucket Name to be emptied'
}
```

### Tasks

- awsEksInit
- awsEcrLogin
- awsEmptyBucket
- awsSsmToYaml

## LAMBDA

### Configuration

```groovy
lambda {
    name = '<Lambda function name>'
    type = '<Lambda function type [python]>'
    srcPath = '<Lambda function source path>'
    bucketName = '<Destination bucket>'
    version = '<Build version>'
}
```

### Tasks

- lambdaLint
- lambdaBuild
- lambdaUpload

### Other tasks

Will verify tools like helm and aws are installed and with the correct versions

- checkTools

## Util Functions

### Description

A set of common util functions to be used in the project

### orderedTasks

Returns a set of orderd tasks by string

```
task testClean() {
    dependsOn project.ext.orderedTasks(
        ':lambda:ip-allowlist:runTestClean',
        ':cloudformation:ip-allowlist-test:cfnDeploy'
    )
}
```

### getVersion

Returns a script of the following form:

GIT_SHORT_COMMIT_HASH_DIRECTORY_HASH_GENERATED

where:

GIT_SHORT_COMMIT_HASH=git rev-parse --short HEAD
DIRECTORY_HASH_GENERATED=git ls-files -s ${path}|git hash-object --stdin|cut -b -4

The first component allow us to identify the commit this version belongs to.
The second component is a hash generated based on the source code content. This is 
handy when making changes in the code and not having to commit it to generate a new
version on local environments

```
String version = project.ext.getVersion('somedirectory')

```
