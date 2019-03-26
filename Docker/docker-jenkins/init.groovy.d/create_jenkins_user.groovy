#!groovy

import jenkins.model.*
import hudson.security.*
import hudson.model.RestartListener

def instance = Jenkins.getInstance()
def env = System.getenv()

println "--> Creating local user for Jenkins"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def user = null
def pass = null

user = env['JENKINS_USER']
pass = env['JENKINS_PASS']

hudsonRealm.createAccount(user,pass)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()