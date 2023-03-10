/*
 * This Groovy source file was generated by the Gradle 'init' task.
 */
package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin

class GroovyPlugin {

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        project.task('groovyLint') {
            doLast {
                String script = 'groovy-lint.sh'

                FileUtil.runWrapperScript(project, plugin, script)
            }
        }
    }

}
