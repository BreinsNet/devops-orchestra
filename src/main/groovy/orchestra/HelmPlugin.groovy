package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin
import org.gradle.api.provider.Property
import org.gradle.api.provider.MapProperty
import org.gradle.api.provider.ListProperty

interface HelmPluginExtension {

    Property<String> getChartName()
    Property<String> getNamespace()
    Property<String> getTimeout()
    ListProperty<String> getValuesList()
    MapProperty<String,String> getSetKeyValues()

}

class HelmPlugin {

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        HelmPluginExtension extension = project.extensions.create('helm', HelmPluginExtension)

        extension.valuesList.convention([])
        extension.setKeyValues.convention([:])
        extension.timeout.convention('')

        project.task('helmUninstall') {
            doLast {
                String chartName = extension.chartName.get()
                String namespace = extension.namespace.get()

                String script = 'helm-uninstall.sh'
                List<String> params = [chartName, namespace]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('helmInstall') {
            doLast {
                String chartName = extension.chartName.get()
                String namespace = extension.namespace.get()
                String timeout = extension.timeout.get()
                String valuesList = extension.valuesList.get().join('|')
                String setKeyValues = extension.setKeyValues.get().collect { key, value ->
                   (key + '=' + value).replace(',', '\\,')
                }.join('|')

                String script = 'helm-install.sh'
                List<String> params = [chartName, namespace]
                Map<String,String> envParams = [
                    VALUES_LIST: valuesList,
                    SET_LIST: setKeyValues,
                    TIMEOUT: timeout,
                ]

                FileUtil.runWrapperScript(project, plugin, script, params, envParams)
            }
        }

        project.task('helmDiff') {
            doLast {
                String chartName = extension.chartName.get()
                String namespace = extension.namespace.get()
                String valuesList = extension.valuesList.get().join('|')
                String setKeyValues = extension.setKeyValues.get().collect { key, value ->
                   (key + '=' + value).replace(',', '\\,')
                }.join('|')

                String script = 'helm-diff.sh'
                List<String> params = [chartName, namespace]
                Map<String,String> envParams = [
                    VALUES_LIST: valuesList,
                    SET_LIST: setKeyValues,
                ]

                FileUtil.runWrapperScript(project, plugin, script, params, envParams)
            }
        }

        project.task('helmTest') {
            doLast {
                String chartName = extension.chartName.get()
                String namespace = extension.namespace.get()

                String script = 'helm-test.sh'
                List<String> params = [chartName, namespace]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('helmLint') {
            doLast {
                String script = 'helm-lint.sh'

                FileUtil.runWrapperScript(project, plugin, script)
            }
        }
    }

}
