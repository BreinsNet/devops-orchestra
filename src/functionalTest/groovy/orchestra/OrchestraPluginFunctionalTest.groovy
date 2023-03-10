/*
 * This Groovy source file was generated by the Gradle 'init' task.
 */
package orchestra

import spock.lang.Specification
import spock.lang.TempDir
import org.gradle.testkit.runner.GradleRunner
import org.gradle.testkit.runner.BuildResult
/**
 * A simple functional test for the 'orchestra' plugin.
 */
class OrchestraPluginFunctionalTest extends Specification {
    @TempDir
    private File projectDir

    private environmentVariables = [
        'DEBUG': 'true',
        'TEST': 'true',
        'PATH': System.getenv('PATH')
    ]

    private File getBuildFile() {
        return new File(projectDir, 'build.gradle')
    }

    private File getSettingsFile() {
        return new File(projectDir, 'settings.gradle')
    }

    private String loadBuildFile(String name) {
        String buildFolderPath = 'src/functionalTest/groovy/orchestra/buildFiles/'

        return new File(buildFolderPath + name).text
    }

    private GradleRunner createGradleRunner(
        String taskName, File projectDir,
        Map<String,String> environmentVariables = ['PATH': System.getenv('PATH')]
    ) {
        GradleRunner runner = GradleRunner.create()

        runner.forwardOutput()
        runner.withPluginClasspath()
        runner.withArguments(taskName)
        runner.withEnvironment(environmentVariables)
        runner.withProjectDir(projectDir)

        return runner
    }

    void "can run wrapper script task"() {
        given:
        settingsFile << ''
        buildFile << loadBuildFile('build.all.gradle')

        when:
        BuildResult result = createGradleRunner(task, projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        task                  |  output
        'dockerLint'          |  'SUCCESS: The task has run successfully'
        'dockerBuild'         |  'SUCCESS: The task has run successfully'
        'dockerScan'          |  'SUCCESS: The task has run successfully'
        'dockerTest'          |  'SUCCESS: The task has run successfully'
        'dockerPush'          |  'SUCCESS: The task has run successfully'
        'cfnLint'             |  'SUCCESS: The task has run successfully'
        'cfnValidate'         |  'SUCCESS: The task has run successfully'
        'cfnDelete'           |  'SUCCESS: The task has run successfully'
        'samValidate'         |  'SUCCESS: The task has run successfully'
        'samDeploy'           |  'SUCCESS: The task has run successfully'
        'samChangeSet'        |  'SUCCESS: The task has run successfully'
        'samDelete'           |  'SUCCESS: The task has run successfully'
        'helmUninstall'       |  'SUCCESS: The task has run successfully'
        'helmTest'            |  'SUCCESS: The task has run successfully'
        'helmLint'            |  'SUCCESS: The task has run successfully'
        'gitClean'            |  'SUCCESS: The task has run successfully'
        'GroovyLint'          |  'SUCCESS: The task has run successfully'
        'awsEksInit'          |  'SUCCESS: The task has run successfully'
        'awsEcrLogin'         |  'SUCCESS: The task has run successfully'
        'awsEmptyBucket'      |  'SUCCESS: The task has run successfully'
        'awsSsmToYaml'        |  'SUCCESS: The task has run successfully'
        'lambdaLint'          |  'SUCCESS: The task has run successfully'
        'lambdaBuild'         |  'SUCCESS: The task has run successfully'
        'lambdaUpload'        |  'SUCCESS: The task has run successfully'
        'batsTest'            |  'SUCCESS: The task has run successfully'
        'checkTools'          |  'SUCCESS: The task has run successfully'
        'cfnChangeSetCreate'  |  'SUCCESS: The task has run successfully'
        'cfnChangeSetView'    |  'SUCCESS: The task has run successfully'
        'cfnChangeSetExec'    |  'SUCCESS: The task has run successfully'
        'cfnChangeSetDelete'  |  'SUCCESS: The task has run successfully'
        'ansiblePlaybook'     |  'SUCCESS: The task has run successfully'
        'ansibleCheck'        |  'SUCCESS: The task has run successfully'
    }

    void "can run helmInstall script tasks with different options"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner('helmInstall', projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                       | output
        loadBuildFile('build.helm-0.gradle') | 'helm upgrade --install --namespace test --create-namespace ' +
                                               '--wait --wait-for-jobs --values values.yaml test .'
        loadBuildFile('build.helm-1.gradle') | 'helm upgrade --install --namespace test --create-namespace ' +
                                               '--wait --wait-for-jobs --values values.yaml --timeout test test .'
        loadBuildFile('build.helm-2.gradle') | 'helm upgrade --install --namespace test --create-namespace ' +
                                               '--wait --wait-for-jobs --values values.yaml ' +
                                               '--set key1=value1 --set key2=value2 test .'
        loadBuildFile('build.helm-3.gradle') | 'helm upgrade --install --namespace test --create-namespace ' +
                                               '--wait --wait-for-jobs --values values.yaml ' +
                                               '--values values-value1.yaml --values values-value2.yaml test .'
        loadBuildFile('build.helm-4.gradle') | 'helm upgrade --install --namespace test --create-namespace ' +
                                               '--wait --wait-for-jobs --values values.yaml ' +
                                               '--values values-value1.yaml --values values-value2.yaml ' +
                                               '--set key1=value1 --set key2=value2 --timeout test test .'
        loadBuildFile('build.helm-5.gradle') | 'helm upgrade --install --namespace test --create-namespace ' +
                                               '--wait --wait-for-jobs --values values.yaml ' +
                                               '--values values-value1.yaml --values values-value2.yaml ' +
                                               '--set key1=value1 --set key2=value2 --timeout test test .'
        loadBuildFile('build.helm-6.gradle') | 'helm upgrade --install --namespace test --create-namespace ' +
                                               '--wait --wait-for-jobs --values values.yaml ' +
                                               '--set key1=value1\\,value2 test .'

    }

    void "can run helmDiff script tasks with different options"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner('helmDiff', projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                       | output
        loadBuildFile('build.helm-0.gradle') | 'helm diff upgrade --install --namespace test ' +
                                               '--values values.yaml test .'
        loadBuildFile('build.helm-2.gradle') | 'helm diff upgrade --install --namespace test ' +
                                               '--values values.yaml --set key1=value1 ' +
                                               '--set key2=value2 test .'
        loadBuildFile('build.helm-4.gradle') | 'helm diff upgrade --install --namespace test ' +
                                               '--values values.yaml --values values-value1.yaml ' +
                                               '--values values-value2.yaml --set key1=value1 ' +
                                               '--set key2=value2 test .'
        loadBuildFile('build.helm-5.gradle') | 'helm diff upgrade --install --namespace test ' +
                                               '--values values.yaml --values values-value1.yaml ' +
                                               '--values values-value2.yaml --set key1=value1 ' +
                                               '--set key2=value2 test .'
        loadBuildFile('build.helm-6.gradle') | 'helm diff upgrade --install --namespace test ' +
                                               '--values values.yaml --set key1=value1\\,value2 test .'

    }

    void "can run cfn deploy script tasks with different options"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner('cfnDeploy', projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                       | output
        loadBuildFile('build.cfn-0.gradle')  | 'aws cloudformation update-stack ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1'
        loadBuildFile('build.cfn-1.gradle')  | 'aws cloudformation update-stack ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1 ' +
                                               "--parameters ParameterKey=TEST1,ParameterValue='\\''value1"
        loadBuildFile('build.cfn-2.gradle')  | 'aws cloudformation update-stack ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1 ' +
                                               "--parameters ParameterKey=TEST1,ParameterValue='\\''value1"
        loadBuildFile('build.cfn-2.gradle')  | 'aws cloudformation update-stack ' +
                                               '--stack-name test2 ' +
                                               '--template-body file://test2 ' +
                                               "--parameters ParameterKey=TEST2,ParameterValue='\\''value2"
        loadBuildFile('build.cfn-3.gradle')  | 'aws cloudformation update-stack ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1 ' +
                                               "--parameters ParameterKey=TEST1,ParameterValue='\\''value1'\\'' " +
                                               '--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND'
        loadBuildFile('build.cfn-4.gradle')  | 'AWS_REGION=eu-west-1'
        loadBuildFile('build.cfn-4.gradle')  | 'AWS_DEFAULT_REGION=eu-west-1'
    }

    void "can run cfn create change set script tasks with differnt options"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner('cfnChangeSetCreate', projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                       | output
        loadBuildFile('build.cfn-0.gradle')  | 'aws cloudformation create-change-set ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1 ' +
                                               '--change-set-name test1-d41d8'
        loadBuildFile('build.cfn-1.gradle')  | 'aws cloudformation create-change-set ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1 ' +
                                               '--change-set-name test1-d41d8 ' +
                                               "--parameters ParameterKey=TEST1,ParameterValue='\\''value1"
        loadBuildFile('build.cfn-2.gradle')  | 'aws cloudformation create-change-set ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1 ' +
                                               '--change-set-name test1-d41d8 ' +
                                               "--parameters ParameterKey=TEST1,ParameterValue='\\''value1"
        loadBuildFile('build.cfn-2.gradle')  | 'aws cloudformation create-change-set ' +
                                               '--stack-name test2 ' +
                                               '--template-body file://test2 ' +
                                               '--change-set-name test2-d41d8 ' +
                                               "--parameters ParameterKey=TEST2,ParameterValue='\\''value2"
        loadBuildFile('build.cfn-3.gradle')  | 'aws cloudformation create-change-set ' +
                                               '--stack-name test1 ' +
                                               '--template-body file://test1 ' +
                                               '--change-set-name test1-d41d8 ' +
                                               "--parameters ParameterKey=TEST1,ParameterValue='\\''value1'\\'' " +
                                               '--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND'
    }

    void "can check if a docker image is present"() {
        given:
        settingsFile << ''
        buildFile << loadBuildFile('build.all.gradle')

        when:
        BuildResult result = createGradleRunner(taskName, projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        taskName            | output
        'dockerEcrTagCheck' | 'aws ecr describe-images --repository-name=test --image-ids=imageTag=test'
        'dockerEcrTagCheck' | 'true'
    }

    void "can run docker test script tasks with different options"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner('dockerTest', projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                         | output
        loadBuildFile('build.docker-0.gradle') | 'bats test'
        loadBuildFile('build.docker-1.gradle') | 'bats test'
    }

    void "can run awsSsmToYaml task"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner('awsSsmToYaml', projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                    | output
        loadBuildFile('build.all.gradle') | 'aws ssm get-parameters --name test --with-decryption ' +
                                            '--output text --query \'Parameters[].Value\''
        loadBuildFile('build.all.gradle') | 'cfn-flip output.json test'
    }

    void "can run lambda tasks with different providers"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner(task, projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                         | task           | output
        loadBuildFile('build.lambda-0.gradle') | 'lambdaLint'   | 'SUCCESS: The task has run successfully'
        loadBuildFile('build.lambda-0.gradle') | 'lambdaBuild'  | 'SUCCESS: The task has run successfully'
        loadBuildFile('build.lambda-0.gradle') | 'lambdaUpload' | 'SUCCESS: The task has run successfully'
        loadBuildFile('build.lambda-1.gradle') | 'lambdaLint'   | 'SUCCESS: The task has run successfully'
        loadBuildFile('build.lambda-1.gradle') | 'lambdaBuild'  | 'SUCCESS: The task has run successfully'
        loadBuildFile('build.lambda-1.gradle') | 'lambdaUpload' | 'SUCCESS: The task has run successfully'
    }

    void "can run sam deploy script tasks with different options"() {
        given:
        settingsFile << ''
        buildFile << inputBuildFile

        when:
        BuildResult result = createGradleRunner('samDeploy', projectDir, environmentVariables).build()

        then:
        result.output.contains(output)

        where:
        inputBuildFile                       | output
        loadBuildFile('build.sam-0.gradle')  | 'sam deploy --no-fail-on-empty-changeset --stack-name test1 --template-file test1'
        loadBuildFile('build.sam-1.gradle')  | 'sam deploy --no-fail-on-empty-changeset --stack-name test1 --template-file test1 ' +
                                               "--parameter-overrides ParameterKey=TEST1,ParameterValue='\\''value1"
        loadBuildFile('build.sam-2.gradle')  | 'sam deploy --no-fail-on-empty-changeset --stack-name test1 --template-file test1 ' +
                                               "--parameter-overrides ParameterKey=TEST1,ParameterValue='\\''value1'\\'' " +
                                               '--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND'
        loadBuildFile('build.sam-3.gradle')  | 'AWS_REGION=XXX'
        loadBuildFile('build.sam-3.gradle')  | 'AWS_DEFAULT_REGION=XXX'
    }

    void "When a script errors, it should output the line where it failed plus expanded variables"() {
        given:
        settingsFile << ''
        buildFile << loadBuildFile('build.sam-0.gradle')

        when:
        BuildResult result = createGradleRunner('samDeploy', projectDir).buildAndFail()

        then:
        result.output.contains(' >> bash -c "sam deploy --no-fail-on-empty-changeset --stack-name test1 --template-file test1"')
    }

    void "Should pass shelcheck on all scripts"() {
        given:
        Process proc = "shellcheck ${file}".execute()

        when:
        proc.waitForOrKill(1000)
        println(proc.text)

        then:
        proc.exitValue() == 0

        where:
        file << 'find ./src/main/resources/scripts -type f -name *.sh'.execute().text.split("\n")
    }

    void "Should have getVersion function"() {
        given:
        settingsFile << ''
        buildFile << loadBuildFile('build.getVersion.gradle')

        when:
        BuildResult result = createGradleRunner('build', projectDir).build()

        then:
        result.output =~ /[0-9a-z]{7}\n[0-9a-z]{7}\n/
    }

    void "Should have getVersion fail if path doesn't exist"() {
        given:
        settingsFile << ''
        buildFile << loadBuildFile('build.getVersionNotExist.gradle')

        when:
        BuildResult result = createGradleRunner('build', projectDir).buildAndFail()

        then:
        result.output.contains("The path asdf doesn't exist")
    }
}
