package orchestra

import org.gradle.api.Plugin
import org.gradle.api.Project

class FileUtil {

    static void copyFileFromPlugin(Plugin plugin, String srcPath, String dstPath, String mode = '644') {
        String fileContent = plugin.getClass().getClassLoader().getResource(srcPath).text

        File dstFile = new File(dstPath)
        File dstParentFile = new File(dstFile.getParent())

        dstParentFile.mkdirs()
        dstFile.write(fileContent)
        "chmod ${mode} ${dstPath}".execute()
    }

    static void runWrapperScript(Project project, Plugin plugin, String script, List<String> params = [],
                                 Map<String,String> envParams = null) {

        String source = "scripts/${script}"
        String destination = "${project.buildDir}/${script}"

        if (System.getenv('TEST')) {
            this.copyFileFromPlugin(plugin, "scripts/lib/test.sh", "${project.buildDir}/lib/test.sh", '755')
        }

        this.copyFileFromPlugin(plugin, "scripts/lib/common.sh", "${project.buildDir}/lib/common.sh", '755')
        this.copyFileFromPlugin(plugin, source, destination, '755')

        project.exec {
            commandLine 'bash', '-c', "build/${script} ${params.join(' ')}"

            if (envParams) {
                environment(*:envParams)
            }
        }
    }

}
