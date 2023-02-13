package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin
import org.gradle.api.provider.Property
import org.gradle.api.provider.MapProperty

interface AwsPluginExtension {

    Property<String> getClusterName()
    Property<String> getBucketName()
    MapProperty<String,String> getSsmToYaml()

}

class AwsPlugin {

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        AwsPluginExtension extension = project.extensions.create('aws', AwsPluginExtension)

        extension.clusterName.convention('')
        extension.bucketName.convention('')
        extension.ssmToYaml.convention([:])

        project.task('awsSsmToYaml') {
            doLast {
                Map<String,String> ssmToYaml = extension.ssmToYaml.get()

                List<String> params = [ssmToYaml.key, ssmToYaml.file]
                String script = 'aws-ssm-to-yaml.sh'

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('awsEksInit') {
            doLast {
                String clusterName = extension.clusterName.get()

                List<String> params = [clusterName]
                String script = 'aws-eks-init.sh'

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('awsEcrLogin') {
            doLast {
                String script = 'aws-ecr-login.sh'

                FileUtil.runWrapperScript(project, plugin, script)
            }
        }

        project.task('awsEmptyBucket') {
            doLast {
                String bucketName = extension.bucketName.get()

                String script = 'aws-empty-bucket.sh'
                List<String> params = [bucketName]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }
    }

}
