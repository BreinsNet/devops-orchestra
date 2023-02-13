package orchestra

import org.gradle.api.Project
import org.gradle.api.Plugin

class UtilFunctions {

    static void importFunctions(Project project, Plugin plugin) {

        project.ext.orderedTasks = {String... dependencyPaths ->
            def dependencies = dependencyPaths.collect { project.tasks.getByPath(it) }

            for (int i = 0; i < dependencies.size() - 1; i++) {
                dependencies[i + 1].mustRunAfter(dependencies[i])
            }

            return dependencies
        }

        project.ext.getVersion = { path = '.' ->
            if (!new File(path).exists()) {
                throw new Exception("The path ${path} doesn't exist")
            }

            def commit = "git log -1 --pretty=format:%h -- ${path}".execute()

            commit.waitFor()

            return commit.text.trim()
        }
    }

}
