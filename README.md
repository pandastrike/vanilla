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
$ huxley cluster create [name]
> Please enter a spot price: 0.009
> Please enter the cluster's public domain: acme.com
> Please enter a single descriptive tag: (huxley)

Cluster creation In Progress.
Name: fearless-panda
Cluster ID: U-QM9gCcF7OjTbQttGegcQ
```

The CLI lets you spin up a whole cluster with a simple command.  If you don't provide a name, a random one will be selected for you.  Huxley prompts you for several configuration details:
- `spot_price` is a single variable.  It asks AWS to use Spot Instances to build your cluster, which affords you a 90% savings and is ideal for testing.
- `public_domain` This is a publicly available domain that you own and have associated with your AWS account.  Clusters will be placed at sub-domains of this root.
- `tag`: This is a tag that appears in AWS to help identify your deployment.  

Afterwards, the command returns immediately with a cluster ID Huxley uses to find it in the future.  However, it will take time to fully configure your cluster.

## Step 4 - Monitor Long-Running Commands
```
$ huxley pending ls
Request [cluster create fearless-panda] has status [creating].
```

```
$ huxley pending wait
Done.
```  
`ls` gives you a list of the long-running commands that are pending.  You could keep using `ls` to see if the command is finished, but cluster creation takes between 10 and 15 minutes.

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
Huxley deployment initalized.
```
Huxley's deployment model depends on a very simple convention.  We require the directory `launch/` to be placed into the root of your project.  Every service you wish to deploy lives in a sub-directory of `launch`.  Huxley also keeps track of persistent configuration information for you in the manifest file `huxley.yaml`.  `init` places both of these in your project.

## Step 7 - Install a Project Mixin
```shell
$ huxley mixin add node
What is the mixin name? (vanilla)
On what port is the mixin listening?
What is the application start command? (npm start)
```
Huxley provides [mixins][mixins], which are launch descriptions for a component of your app.  Vanilla is a Node.js project, so we selected the `node` mixin.

This will again prompt you for configuration information:
- `service_name`: We are using a Node type mixin, but you can name it whatever you like.  It defaults to the name of your repository.
- `port`: The port the service responds to.  For Huxley clusters
 - Ports exposed to the public Internet are 3001 to 3999, inclusive. (Hook server is on 3000)
 - Ports exposed to only the cluster are 2001 to 2999, inclusive. (Kick server is on 2000)
- `start_command`: This is the command used to start the service.  Since this is a Node project, it defaults to `npm start`.

Check out the `launch/` directory to see you have a sub-directory named after the service name you chose.  The sub-directory is complete with templates ready to run on a Huxley cluster.  All you need to do is make sure that your project's `package.json` file has a valid `npm start` script and the template will find it.

## Step 8 - Install Githook On Hook Server
```shell
$ huxley remote add fearless-panda
Githook installed on cluster fearless-panda
ID: mdnkiosMd1GPR8bC7pnlBg
```

A githook is an arbitrary script that gets triggered in response to a git command.  Githooks are not transferred by normal git commands, so we rely on a special Huxley command and target the cluster of interest.

Additionally, Huxley sets up a git alias for your cluster, which you can examine with `git remote -v`.


## Step 9 - Deploy
```shell
$ git add -A
$ git commit -m "My awesome edits"
$ git push fearless-panda master
```
This is the fun part.  You are able to deploy with nothing more than `git push`  Woohooo!

Once it detects you pushing an update to the cluster, the githook triggers a cascade of events that result in a deployment of your application.  Note that Huxley affords you great flexibility:
- You can add multiple clusters to your remote.  Imagine adding clusters named `dev` and `production`.  Alter your deployment environment just by altering your push command.
- You can specify any branch of your project.  Have something to test in a development branch? Just name it when you push and see it online.

It can take a couple minutes for a fresh Docker container to build, but subsequent deploys go much faster. Monitoring of pending deployments is imminent.  Also, Make sure you have SSH agent-forwarding enabled to the cluster's domain.  Deployment will fail without forwarding.

Congratulations!!  You've made your first deploy, Huxley-Style!!

## Shutdown
```shell
$ huxley cluster delete fearless-panda
Cluster deletion In Progress.
```
Huxley can delete your cluster resources too.  Note, it will take a couple minutes for the shutdown to complete.

[1]:https://github.com/pandastrike/huxley
[mixins]:https://github.com/pandastrike/huxley/wiki/Huxley-Mixins
