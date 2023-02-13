package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin
import org.gradle.api.provider.ListProperty

interface CfnPluginExtension {

    ListProperty<Map<String, String>> getTemplates()

}

class CfnPlugin {

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        CfnPluginExtension extension = project.extensions.create('cfn', CfnPluginExtension)

        project.task('cfnLint') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-lint.sh'

                templates.each { template ->
                    List<String> params = [template.filePath]

                    FileUtil.runWrapperScript(project, plugin, script, params)
                }
            }
        }

        project.task('cfnValidate') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-validate.sh'

                templates.each { template ->
                    List<String> params = [template.filePath]

                    FileUtil.runWrapperScript(project, plugin, script, params)
                }
            }
        }

        project.task('cfnDeploy') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-deploy.sh'

                templates.each { template ->
                    List<String> parameters = [] 
                    List<String> capabilities = []

                    template.cfnParams.each { cfnParam ->
                        parameters << "ParameterKey=${cfnParam.key},ParameterValue='${cfnParam.value}'"
                    }

                    template.capabilities.each { capability ->
                        capabilities << capability
                    }

                    Map<String,String> envParams = [
                        PARAMETERS: parameters.join(' '),
                        CAPABILITIES: capabilities.join(' '),
                    ]

                    if (template.region) {
                        envParams['AWS_REGION'] = template.region
                        envParams['AWS_DEFAULT_REGION'] = template.region
                    }

                    List<String> params = [template.filePath,template.stackName]

                    FileUtil.runWrapperScript(project, plugin, script, params, envParams)
                }
            }
        }

        project.task('cfnDelete') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-delete.sh'

                templates.each { template ->
                    List<String> params = [template.stackName]

                    FileUtil.runWrapperScript(project, plugin, script, params)
                }
            }
        }

        project.task('cfnChangeSetCreate') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-change-set-create.sh'

                templates.each { template ->
                    List<String> parameters = []
                    List<String> capabilities = []

                    template.cfnParams.each { cfnParam ->
                        parameters << "ParameterKey=${cfnParam.key},ParameterValue='${cfnParam.value}'"
                    }

                    template.capabilities.each { capability ->
                        capabilities << capability
                    }

                    Map<String,String> envParams = [
                        PARAMETERS: parameters.join(' '),
                        CAPABILITIES: capabilities.join(' '),
                    ]

                    List<String> params = [template.filePath, template.stackName]

                    FileUtil.runWrapperScript(project, plugin, script, params, envParams)
                }
            }
        }

        project.task('cfnChangeSetView') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-change-set-view.sh'

                templates.each { template ->
                    List<String> params = [template.filePath, template.stackName]

                    FileUtil.runWrapperScript(project, plugin, script, params)
                }
            }
        }

        project.task('cfnChangeSetExec') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-change-set-exec.sh'

                templates.each { template ->
                    List<String> params = [template.filePath, template.stackName]

                    FileUtil.runWrapperScript(project, plugin, script, params)
                }
            }
        }

        project.task('cfnChangeSetDelete') {
            doLast {
                List<Map<String,String>> templates = extension.templates.get()
                String script = 'cfn-change-set-delete.sh'

                templates.each { template ->
                    List<String> params = [template.filePath, template.stackName]

                    FileUtil.runWrapperScript(project, plugin, script, params)
                }
            }
        }
    }

}
