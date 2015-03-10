# Huxley Flavor Example - Vanilla
"Hello World" Huxley Example

This repository houses a simple Node server that only replies with "Hello World".  It is meant to be a simple target app to deploy with Huxley.

## Deployment Example

### Step 0 - Setup Your Root Configuration
Huxley consists of two parts.  There is a command-line interface (CLI) where you can enter simple commands.  This CLI targets a Huxley API server, which does the heavy lifting.  The API wraps a number of component libraries and deals with elaborate configuration details, but Huxley retains configuration context so the CLI commands are very simple.  We just need to set an initial configuration and then you're ready to begin.

So, lets set some context! The root configuration for huxley is stored in a dotfile located in your $HOME directory.  It stores some sensitive information, so never store this in your project's repository.

- The `huxley` stanza provides the CLI with an address where it can find a Huxley API server.  If you don't have a running API server, you can spin up your own by following [these instructions][1] or by using ours.  We have one running at `huxley.pandastrike.com`.
- The `aws` stanza contains your AWS credentials.  It is not required, but you will not be able to create clusters without it.
- `public_keys` grants every listed user access to a cluster created by your CLI.  It is not required, but make sure you have
- `spot_price` is a single variable.  It asks AWS to use Spot Instances to build your cluster, which affords you a 90% savings and is ideal for testing.

### ~/.huxley
```yaml
huxley:
  url: "http://huxley.pandastrike.com"    # Specify the API server location

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

spot_price: 0.009

```
> **WARNING:** ***NEVER PLACE THIS IN YOUR PROJECT'S REPOSITORY***!!

### Step 1 - Install Huxley CLI
Install Huxley via npm
```shell
npm install -g huxley-cli
```

This gives you the executable `huxley`, which you will be using for the remaining steps.

### Step 2 - Create A Cluster
The CLI lets you spin up Huxley clusters.

```shell
huxley cluster create [name]
```
If you don't provide a name, a random one will be selected for you.  The command returns immediately with a cluster ID Huxley uses to find it in the future.  However, your cluster will not be fully configured and ready for several minutes.

### Step 3 - Clone Vanilla to Your Local Machine
Vanilla is a "hello world" stand-in for any Node project you've written and wish to deploy.

```shell
git clone https://github.com/pandastrike/vanilla vanilla
```

### Step 4 - Intialize Your Project for Deployment
Initialize your project for Huxley by issuing the following command in the root of your project:
```shell
huxley init
```
***What's this does***
Huxley's deployment model depends on a very simple convention.  We require the directory `launch/` to be placed into the root of your project.  Every service you wish to deploy lives in a sub-directory of `launch`.  Huxley also keeps track of persistent configuration information for you in the manifest file `huxley.yaml`.  `init` places both of these in your project.  Inside `huxley.yaml`, edit `app_name` to match the name of your repository.  

### Step 5 - Install a Project Mixin
Huxley provides mixins, which are templates to deploy your code on a Huxley server.  Vanilla is a "Hello World" NodeJS project, so let's use the mixin `node`.

```shell
huxley mixin node
```

Check out the `launch/` directory to see you have a sub-directory `node/` complete with templates ready to run on a Huxley cluster!  All you need to do is make sure that your project's `package.json` file has a valid `npm start` script and the template will find it.

### Step 6 - Install Githook On Hook Server
A githook is an arbitrary script that gets triggered in response to a git command.  Githooks are not transfered by normal git commands, so we rely on a special Huxley command.  Target the cluster you plan to use.

```shell
huxley remote add [cluster-name]
```

The githook has been installed and you now have a git alias ready, which you can examine with `git remote -v`.


### Step 7 - Deploy
This is the fun part.  Commit any edits you've made and deploy...  via `git push`  Woohooo!
```shell
git add -A
git commit -m "My awesome edits"
git push [cluster-name] [branch-name]
```

Once it detects you pushing an update to the cluster, the githook triggers a cascade of events that result in a deployment of your application.  Note that Huxley affords you great flexibility:

- You can add multiple clusters to your remote.  Imagine adding clusters named `dev` and `production`.  Alter your deployment environment just my altering your push command.
- You can specify any branch of your project.  Have something you need to test in a dev branch, just name it when you push and see it online.

It can take a couple minutes for a fresh Docker container to build, but subsequent deploys go much faster.  Congratulations!!  You've made your first deploy, Huxley-Style!!

### Shutdown
When you want to shutdown a cluster, simply use Huxley.
```shell
huxley cluster delete [cluster-name]
```

Note, it will take a couple minutes for the shutdown to complete.

[1]:https://github.com/pandastrike/huxley
