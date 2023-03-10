/*
 * This Groovy source file was generated by the Gradle 'init' task.
 */
package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin
import org.gradle.api.provider.Property

interface GitPluginExtension {

    Property<String> getPath()

}

class GitPlugin {

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        GitPluginExtension extension = project.extensions.create('git', GitPluginExtension)

        extension.path.convention('./')

        project.task('gitClean') {
            doLast {
                String script = 'git-clean.sh'
                List<String> params = [extension.path.get()]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }
    }

}
