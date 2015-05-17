# Huxley Flavor Example - Vanilla
### "Hello World" Huxley Example

This repository houses a simple Node server that only replies with "Hello World".  It is meant to be a simple target app that you can deploy with Huxley.

# Deployment Example

## Step 0 - Setup Your Root Configuration
Place this into a dotfile located in your $HOME directory.  
### //  ~/.huxley
> **WARNING:** ***NEVER PLACE THIS IN YOUR PROJECT'S REPOSITORY***!!

```yaml
huxley:
  url: "https://huxley.pandastrike.com"    # Specify the API server location

aws:
  id: MyAWSIdentity
  key: Password123
  region: us-west-1
  availability_zone: us-west-1c
  key_name: My-AWS-Key            # SSH key associated with your AWS account.

public_keys:
  - List of public SSH keys
  - One key per line
  - Grants cluster access to listed users
```

> **WARNING:** ***NEVER PLACE THIS IN YOUR PROJECT'S REPOSITORY***!!

Huxley retains configuration context for you, so the CLI commands are very simple.  However, Huxley does need this root configuration file to get you started.

- The `huxley` stanza provides the CLI with an address where it can find a Huxley API server.  If you don't have a running API server, you can spin up your own by following [these instructions][1] or by using ours.  PandaStrike provides an API server for you to target at `https://huxley.pandastrike.com`.  Please note the use of HTTPS.  Connections on port 80 will be rejected.
- The `aws` stanza contains your AWS credentials.  You will not be able to use Huxley without it.
- `public_keys` grants every listed user access to a cluster created by your CLI.  It is not required, but you will only be able to access the final cluster if you have the private key that is associated with your AWS account.



## Step 1 - Install Huxley CLI
```shell
$ npm install -g huxley-cli
```

This global installation gives you the executable `huxley`, which you will be using for the remaining steps.

## Step 2 - Create a Huxley Profile
```
$ huxley profile create panda
*****profile "panda" created. Secret token stored.
```
Creating a profile allows Huxley to track the resources that belong to you.  If you look back at your Huxley dotfile, you'll notice a sub-section has been added to the `huxley` stanza, listing your ID.  Feel free to name your profile whatever is convenient.  Huxley will rely on the token for uniqueness.  

## Step 3 - Create A Cluster
Skip this step if you already have a cluster online.
```
$ huxley cluster create fearless-panda
This utility will walk you through configuring a Huxley cluster.
It pulls from your local config or tries to guess sane defaults.

See https://github.com/pandastrike/huxley/wiki for definitive documentation

Press ^C at any time to quit.
> Cluster Size [3-12]: (3)
> EC2 Instance Type: (m1.medium)
> Instance Virtualizaiton Type: (pv)
> AWS Region: (us-west-1)
> Availability Zone: (us-west-1c)
> Default SSH Key: (CoreOS-Test)
> CoreOS Channel: (stable)
> Spot Bid [or 0 for on-demand]: (0) 0.009
> Public Domain: pandastrike.com
> Descriptive Tag: (huxley)

Cluster creation In Progress.
Name: fearless-panda
Cluster ID: U-QM9gCcF7OjTbQttGegcQ
```

The CLI lets you spin up a whole cluster with a simple command.  If you don't provide a name, a random one will be selected for you.  Huxley prompts you for several configuration details, but it tries to provide sane defaults.  Pressing "Enter" will accept the default value.  See the wiki for more details on these settings, but for now let's just focus on:
- **Spot Bid:** This asks AWS to use Spot Instances to build your cluster, which can yield up to a 90% savings.  Spot Instances are ideal for testing.
- **Public domain:** This is a publicly available domain that you own and have associated with your AWS account.  Clusters will be placed at sub-domains of this root.
- **Descriptive Tag:** This is a tag that appears in AWS to help identify your deployment.  

Afterwards, the command returns immediately with a cluster ID that Huxley uses to find it in the future.  However, it will take time to fully configure your cluster.

```
$ huxley cluster describe fearless-panda
status: starting
name: fearless-panda
domain: pandastrike.com
type: m1.medium
region: us-west-1
availability_zone: us-west-1c
deployments:
remotes:
```
Let's take a look at the cluster we've just created.  `cluster describe` provides detailed information about the cluster's status.  You can see it's still spinning up. Let's look at how we can automate formation monitoring.

## Step 4 - Monitor Long-Running Commands
```
$ huxley pending ls
Request [cluster create fearless-panda] has status [creating] -- 32482178a
```

```
$ huxley pending wait
Done.
```  
The cluster is still being formed, therefore the command that created it has a *pending* state.  Huxley tracks long-running commands to help you manage them.

`pending ls` gives you a list of the long-running commands that are pending.  You could keep using `ls` to see if the command is finished, but cluster creation takes between 10 and 15 minutes.

Fortunately, you can ask Huxley to tell you when your cluster is ready with `pending wait`.  The CLI will block until all pending commands have completed.  Once that happens it prints `Done.` and exits.  Time to go get coffee.

## Step 5 - Clone Vanilla to Your Local Machine
```shell
$ git clone https://github.com/pandastrike/vanilla vanilla
```
Vanilla is a *Hello World* stand-in for any Node project you've written and wish to deploy.



## Step 6 - Intialize Your Project for Deployment
```shell
$ cd vanilla
$ huxley init
Huxley deployment initialized.
```
Huxley's deployment model depends on a very simple convention.  We require the directory `launch/` to be placed into the root of your project.  Every service you wish to deploy lives in a sub-directory of `launch`.  Huxley also keeps track of persistent configuration information for you in the manifest file `huxley.yaml`.  `init` places both of these in your project.

## Step 7 - Install a Project Mixin
```shell
$ huxley mixin add node
What is the mixin name? (vanilla)
What external port on the container is exposed? 3030
What internal port in the container maps to the above? (80) 8080
What is the mixin start command? (npm start)

Added a "node" mixin named "vanilla" to your repository.
```
Huxley provides [mixins][mixins], which are launch descriptions for a component of your app.  Vanilla is a Node.js project, so we selected the `node` mixin.

This will again prompt you for configuration information:
- **Name:** We are using a Node type mixin, but you can name it whatever you like.  It defaults to the name of your repository.
- **Ports:** Huxley launches your app inside a Linux container.  When it asks for the external port, it's asking for the port the outside world can use to reach your app.  The internal port is whatever that maps to inside the container. For Huxley clusters
 - External Ports exposed to the public Internet are 3002 to 3999, inclusive.
 - External Ports exposed to only the cluster are 2002 to 2999, inclusive.
- **Start Command:** This is the command used to start the service.  Since this is a Node project, it defaults to `npm start`.

Check out the `launch/` directory to see you have a sub-directory named after the service name you chose.  The sub-directory is complete with templates ready to run on a Huxley cluster.  All you need to do is make sure that your project's `package.json` file has a valid `npm start` script and the template will find it.

## Step 8 - Install Githook On Hook Server
```shell
$ huxley remote add fearless-panda
Githook installed on cluster fearless-panda
ID: mdnkiosMd1GPR8bC7pnlBg
```

A githook is an arbitrary script that gets triggered in response to a git command.  Githooks are not transferred by normal git commands, so we rely on a special Huxley command and target the cluster of interest.  It will about 15 seconds for this command to return, but for now it is a blocking command.

Additionally, Huxley sets up a git alias for your cluster, which you can examine with `git remote -v`.


## Step 9 - Deploy
```shell
$ git add -A
$ git commit -m "My awesome edits"
$ git push fearless-panda master
```
```
$ huxley pending ls
Request [git push fearless-panda master] has status [starting] -- 9a84fdb75
```  
```
$ huxley pending wait
Done.
```
This is the fun part.  You are able to deploy with nothing more than `git push`  Woohooo!

The first time you push, you will be asked to authorize the connection.  This is normal, but you have to type "yes", otherwise the connection will be denied.

Once it detects you pushing an update to the cluster, the githook triggers a cascade of events that result in a deployment of your application.  Depending on your application, deployment may take several minutes, but the `git push` returns quickly.  As it processes your deployment, the cluster also registers the `git push` with the Huxley API server as a pending command you can track.  The cluster monitors the mixins you've specified, and when they are ready it will resolve this pending command.

This feature gives you the power to optionally block on your deployment with `huxley pending wait`.  As soon as it returns `Done.`, your application is ready.  Visit `http://[service name].[cluster name].[public domain]:[external port]` to see `Hello World.`  For example, ours would be "http://vanilla.fearless-panda.pandastrike.com:3030"

Congratulations!!  You've made your first deploy, Huxley-Style!!


### Deployment Notes:
Huxley affords you great flexibility...
- You can add multiple clusters to your remote.  Imagine adding clusters named `dev` and `production`.  Alter your deployment environment just by altering your push command.
- You can specify any branch of your project.  Have something to test in a development branch? Just name it when you push and see it online.


## Privileged Data
**huxley.yaml**
```yaml
app_name: vanilla
files:
  - src/secrets.txt
  - env/dev
```
**.gitignore**
```
*.log
node_modules/
secrets.txt
env/dev
```
**src/secrets.txt**
```
This is a secret.
```
#### evn/dev
**secret-a.txt**
```
This is a secret in a secret directory.
```
**secret-b.txt**
```
This is a secret in a secret directory with the above secret.
```
#### The New src/server.coffee
```coffee
#===============================================================================
# Vanilla Example - Node Server
#===============================================================================
# This is a simple "hello world" Node server, but now we access secret data."
{join} = require "path"
{readFileSync} = require "fs"
http = require "http"

vanilla = (request, response) ->
  response.writeHead(200)
  response.write("Hello World.\n")
  response.write readFileSync join __dirname, "./secrets.txt"
  response.write readFileSync join __dirname, "../env/dev/secret-a.txt"
  response.write readFileSync join __dirname, "../env/dev/secret-b.txt"
  response.end()

# Launch Server
http.createServer(vanilla).listen 8080, () ->
  console.log "\nVanilla is online."
```


Huxley primarily uses git to deploy your project.  However, there are some things that you don't want to store in your repo, (eg API keys, massive dictionary, etc).  Huxley offers you a way to include this in your deployment.

By placing references to the files and/or directories that you wish to include in the `files` field of `huxley.yaml`, Huxley will make sure they make it into the deployment.  References work just like `gitignore` references do.  You may recursively include all files within a directory by naming it in the `files` field.

In our example, `secrets.txt` and the directory `env/prod` are gitignored *and* mentioned to Huxley.  Huxley transports these files to the cluster when it sets up a remote, but the command is identical.

Run this:
```
$ huxley remote add fearless-panda
```
Then commit the changes to the server code.  `.gitignore` will protect the files from being included.


Now, when you deploy, you'll see data that was deployed without being a part of your git repo.

## Shutdown
```shell
$ huxley cluster delete fearless-panda
Cluster deletion In Progress.
```
```
$ huxley pending ls
Request [cluster delete fearless-panda] has status [creating] -- 35482279a
```

Huxley can delete your cluster resources too.  The command returns quickly, but note that it will take a couple minutes for the shutdown to complete.  Once again, Huxley has you covered.  Deletion shows up as a pending command that you can block on with `pending wait`.  Not only does this command terminate cluster instances, it cleans up the private hosted zone established for the cluster, eg. `fearless-panda.cluster`.

[1]:https://github.com/pandastrike/huxley
[mixins]:https://github.com/pandastrike/huxley/wiki/Huxley-Mixins
