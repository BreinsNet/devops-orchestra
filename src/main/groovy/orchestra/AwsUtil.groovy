package orchestra

class AwsUtil {

    static String getRegion() {
        return System.getenv('AWS_REGION') ?: System.getenv('AWS_DEFAULT_REGION')
    }

    static String getAccount() {
        return 'aws sts get-caller-identity --query "Account" --output text'.execute().trim
    }

    static String getEcrUrl() {
        return "${getAccount()}.dkr.ecr.${getRegion()}.amazonaws.com"
    }

}

