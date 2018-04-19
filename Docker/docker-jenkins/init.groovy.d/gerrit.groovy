import hudson.model.*;
import jenkins.model.*;
import com.sonyericsson.hudson.plugins.gerrit.trigger.PluginImpl;
import com.sonyericsson.hudson.plugins.gerrit.trigger.GerritServer;
import com.sonyericsson.hudson.plugins.gerrit.trigger.config.Config;
import net.sf.json.JSONObject;

def env = System.getenv()
// Variables
def gerrit_host_name = env['GERRIT_HOST_NAME']
def gerrit_front_end_url = env['GERRIT_FRONT_END_URL']
def gerrit_ssh_port = env['GERRIT_SSH_PORT'] ?: "29418"
gerrit_ssh_port = gerrit_ssh_port.toInteger()
def gerrit_username = env['GERRIT_USERNAME'] ?: "jenkins"
def gerrit_email = env['GERRIT_EMAIL'] ?: ""
def gerrit_ssh_key_file = env['GERRIT_SSH_KEY_FILE'] ?: "/var/jenkins_home/.ssh/id_rsa"
def gerrit_ssh_key_password = env['GERRIT_SSH_KEY_PASSWORD'] ?: null
def gerrit_initial_admin_user = env['GERRIT_INITIAL_ADMIN_USER'] ?: "gerrit"
def gerrit_initial_admin_password = env['GERRIT_INITIAL_ADMIN_PASSWORD'] ?: "gerrit"

def gerritVerifiedCmdBuildSuccessful = 'gerrit review <CHANGE>,<PATCHSET> --message \'"Build Successful <GERRIT_NAME>"\' --verified <VERIFIED> '
def gerritVerifiedCmdBuildUnstable = 'gerrit review <CHANGE>,<PATCHSET> --message \'"Build Unstable <GERRIT_NAME>"\' --verified <VERIFIED> '
def gerritVerifiedCmdBuildFailed = 'gerrit review <CHANGE>,<PATCHSET> --message \'"Build Failure <GERRIT_NAME>"\' --verified <VERIFIED> '
def gerritVerifiedCmdBuildStarted = 'gerrit review <CHANGE>,<PATCHSET> --message \'"Build Started <BUILDURL> <STARTED_STATS>"\' --verified <VERIFIED> '
def gerritVerifiedCmdBuildNotBuilt = 'gerrit review <CHANGE>,<PATCHSET> --message \'"Build not built <GERRIT_NAME>"\' --verified <VERIFIED> '

// Constants
def instance = Jenkins.getInstance()

Thread.start {
    sleep 10000

    // Gerrit
    println "--> Configuring Gerrit"

    def gerrit_trigger_plugin = PluginImpl.getInstance()

    def gerrit_server = new GerritServer("Gerrit")

    def gerrit_servers = gerrit_trigger_plugin.getServerNames()
    def gerrit_server_exists = false
    gerrit_servers.each {
        server_name = (String) it
        if ( server_name == gerrit_server.getName() ) {
            gerrit_server_exists = true
            println("Found existing installation: " + server_name)
        }
    }

    if (!gerrit_server_exists) {
        def gerrit_server_config = new Config()

        JSONObject o = new JSONObject()

        // server config
        o.put("gerritHostName", gerrit_host_name)
        o.put("gerritFrontEndUrl", gerrit_front_end_url)
        o.put("gerritSshPort", gerrit_ssh_port)
        o.put("gerritUserName", gerrit_username)
        o.put("gerritAuthKeyFile", gerrit_ssh_key_file)
        o.put("gerritAuthKeyFilePassword", gerrit_ssh_key_password)

        // Commands to gerrit
        o.put("gerritVerifiedCmdBuildStarted", gerritVerifiedCmdBuildStarted)
        o.put("gerritVerifiedCmdBuildFailed", gerritVerifiedCmdBuildFailed)
        o.put("gerritVerifiedCmdBuildSuccessful", gerritVerifiedCmdBuildSuccessful)
        o.put("gerritVerifiedCmdBuildUnstable", gerritVerifiedCmdBuildUnstable)
        o.put("gerritVerifiedCmdBuildNotBuilt", gerritVerifiedCmdBuildNotBuilt)
        
        // Numeric codes for reviews and verified
        o.put("gerritBuildStartedVerifiedValue", 0)
        o.put("gerritBuildSuccessfulVerifiedValue", 1)
        o.put("gerritBuildFailedVerifiedValue", -1)
        o.put("gerritBuildUnstableVerifiedValue", -1)
        o.put("gerritBuildNotBuiltVerifiedValue", 0)
        o.put("gerritBuildStartedCodeReviewValue", 0)
        o.put("gerritBuildSuccessfulCodeReviewValue", 1)
        o.put("gerritBuildFailedCodeReviewValue", -1)
        o.put("gerritBuildUnstableCodeReviewValue", -1)
        o.put("gerritBuildNotBuiltCodeReviewValue", 0)

        gerrit_server_config.setValues(o)

        gerrit_server.setConfig(gerrit_server_config)
        gerrit_trigger_plugin.addServer(gerrit_server)
        gerrit_trigger_plugin.save()
        gerrit_server.start()
        gerrit_server.startConnection()
    }

    // Save the state
    instance.save()
}
