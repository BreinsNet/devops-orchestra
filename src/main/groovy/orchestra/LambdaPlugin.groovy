package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin
import org.gradle.api.provider.Property
import org.gradle.api.provider.ListProperty

interface LambdaPluginExtension {

    Property<String> getName()
    Property<String> getType()
    Property<String> getSrcPath()
    Property<String> getBucketName()
    Property<String> getVersion()

}

class LambdaPlugin {
    static final validTypes = ['python', 'node']

    static void validateType(String type) {
        if (!validTypes.contains(type)) {
            throw new Exception("Invalid lambda type ${type}")
        }
    }

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        LambdaPluginExtension extension = project.extensions.create('lambda', LambdaPluginExtension)

        project.task('lambdaLint') {
            doLast {
                String type = extension.type.get()
                String srcPath = extension.srcPath.get()

                List<String> params = [srcPath]
                String script = "lambda-${type}-lint.sh"

                this.validateType(type)

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('lambdaBuild') {
            doLast {
                String name = extension.name.get()
                String type = extension.type.get()
                String bucketName = extension.bucketName.get()
                String version = extension.version.get()
                String srcPath = extension.srcPath.get()

                String zipFile = "lambda-${type}-${name}-${version}.zip"
                String script = "lambda-${type}-build.sh"

                List<String> params = [srcPath, zipFile]

                this.validateType(type)

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('lambdaUpload') {
            doLast {
                String name = extension.name.get()
                String type = extension.type.get()
                String bucketName = extension.bucketName.get()
                String version = extension.version.get()

                String zipFile = "lambda-${type}-${name}-${version}.zip"
                String script = "lambda-upload.sh"
                List<String> params = [zipFile, bucketName]

                this.validateType(type)

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }
    }

}
