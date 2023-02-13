package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin
import org.gradle.api.provider.Property

interface AnsiblePluginExtension {

    Property<String> getPath()
    Property<String> getPlaybook()
    Property<String> getInventory()
    Property<String> getHost()
    Property<Boolean> getDiff()

}

class AnsiblePlugin {

    static void importTasks(Project project, Plugin plugin, String dockerImageAndTag) {
        AnsiblePluginExtension extension = project.extensions.create('ansible', AnsiblePluginExtension)

        extension.diff.convention(false)

        project.task('ansiblePlaybook') {
            doLast {
                String path = extension.path.get()
                String playbook = extension.playbook.get()
                String inventory = extension.inventory.get()
                String host = extension.host.get()
                Boolean diff = extension.diff.get().toString()

                String script = 'ansible-playbook.sh'
                List<String> params = [playbook, inventory, host, path, diff]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }

        project.task('ansibleCheck') {
            doLast {
                String path = extension.path.get()
                String playbook = extension.playbook.get()
                String inventory = extension.inventory.get()
                String host = extension.host.get()
                Boolean diff = extension.diff.get().toString()

                String script = 'ansible-check.sh'
                List<String> params = [playbook, inventory, host, path, diff]

                FileUtil.runWrapperScript(project, plugin, script, params)
            }
        }
    }

}

