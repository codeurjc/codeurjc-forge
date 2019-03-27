#!groovy

import jenkins.model.*
import hudson.security.*
import hudson.model.*

def instance = Jenkins.getInstance()
def env = System.getenv()

println "--> Creating local admin for Jenkins"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def user = null
def pass = null

user_admin = env['JENKINS_ADMIN_USER']
pass = env['JENKINS_ADMIN_PASS']

hudsonRealm.createAccount(user_admin, pass)
instance.setSecurityRealm(hudsonRealm)

println "--> Creating local user for Jenkins"

user_dev = env['JENKINS_DEV_USER']
pass = env['JENKINS_DEV_PASS']

hudsonRealm.createAccount(user_dev, pass)
instance.setSecurityRealm(hudsonRealm)

def strategy = new GlobalMatrixAuthorizationStrategy()
	strategy.add(Jenkins.ADMINISTER, user_admin)
    strategy.add(Jenkins.READ, user_dev)
    strategy.add(Item.DISCOVER, user_dev)
    strategy.add(Item.READ, user_dev)
    strategy.add(Item.BUILD, user_dev)
    strategy.add(Item.CONFIGURE, user_dev)
    strategy.add(Item.CREATE, user_dev)
    strategy.add(Item.WORKSPACE, user_dev)
    strategy.add(Item.DELETE, user_dev)

instance.setAuthorizationStrategy(strategy)

instance.save()

