package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin
import org.gradle.api.provider.Property
import org.gradle.api.provider.MapProperty
import org.gradle.api.provider.ListProperty

interface SamPluginExtension {

    Property<String> getTemplateFile()
    Property<String> getStackName()
    Property<String> getRegion()
    MapProperty<String,String> getParameters()
    ListProperty<String> getCapabilities()

}

class SamPlugin {

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        SamPluginExtension extension = project.extensions.create('sam', SamPluginExtension)

        extension.region.convention('')
        extension.parameters.convention([:])
        extension.capabilities.convention([])

        project.task('samValidate') {
            doLast {
                String script = 'sam-validate.sh'

                String templateFile = extension.templateFile.get()
                List<String> params = [templateFile]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('samDeploy') {
            doLast {
                String script = 'sam-deploy.sh'

                String templateFile = extension.templateFile.get()
                String stackName = extension.stackName.get()
                String region = extension.region.get()
                Map<String,String> parameters = extension.parameters.get()
                List<String> capabilities = extension.capabilities.get()
                List<String> samParams = []

                parameters.each { param ->
                    samParams << "ParameterKey=${param.key},ParameterValue='${param.value}'"
                }

                Map<String,String> envParams = [
                    PARAMETERS: samParams.join(' '),
                    CAPABILITIES: capabilities.join(' '),
                ]

                if (region) {
                    envParams['AWS_REGION'] = region
                    envParams['AWS_DEFAULT_REGION'] = region
                }

                List<String> params = [templateFile,stackName]

                FileUtil.runWrapperScript(project, plugin, script, params, envParams)
            }
        }

        project.task('samChangeSet') {
            doLast {
                String script = 'sam-change-set.sh'

                String templateFile = extension.templateFile.get()
                String stackName = extension.stackName.get()
                String region = extension.region.get()
                Map<String,String> parameters = extension.parameters.get()
                List<String> capabilities = extension.capabilities.get()
                List<String> samParams = []

                parameters.each { param ->
                    samParams << "ParameterKey=${param.key},ParameterValue='${param.value}'"
                }

                Map<String,String> envParams = [
                    PARAMETERS: samParams.join(' '),
                    CAPABILITIES: capabilities.join(' '),
                ]

                if (region) {
                    envParams['AWS_REGION'] = region
                    envParams['AWS_DEFAULT_REGION'] = region
                }

                List<String> params = [templateFile,stackName]

                FileUtil.runWrapperScript(project, plugin, script, params, envParams)
            }
        }

        project.task('samDelete') {
            doLast {
                String stackName = extension.stackName.get()
                String script = 'sam-delete.sh'

                List<String> params = [stackName]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }
    }

}
