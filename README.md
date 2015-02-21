# Huxley Flavor Example - Vanilla
"Hello World" Huxley Example

This repository houses a simple Node server that only replies with "Hello World".  It is meant to be a simple target app to deploy with Huxley.

## Deployment Example

### Step 1 - Create A Cluster
Skip to step 2 if you already have a cluster online.  We use the tool [panda-cluster][1] to build a cluster as our deployment platform.  Make sure the following is in your $HOME directory.

### .panda-cluster.cson
```coffee
aws:
  id: "MyAWSIdentity"
  key: "Password123"
  region: "us-west-1"
```
> **WARNING:** ***NEVER PLACE THIS IN YOUR PROJECT'S REPOSITORY***!!


Now, we use the following command to spin-up the cluster.

```shell
panda-cluster cluster create -n flavor -d pandastrike.com -k CoreOS-Test -p flavor.cluster -o 0.009 -m true
```
The `-d` flag needs a domain that you own and is associated with your AWS account, so in my case, that's pandastrike.com.  This command will take several minutes to complete.

### Step 2 - Clone Vanilla to Your Local Machine
Vanilla is a "hello world" stand-in for code you've written and wish to deploy.

```shell
git clone https://github.com/pandastrike/vanilla vanilla
```

### Step 3 - Install Githook On Hook Server
A githook is an arbitrary script that gets triggered in response to a git command.  Clusters setup by Huxley have hook-severs in place to accept git pushes and deploy your app.  Githooks are not transfered by normal git commands, so we rely on the tool [panda-hook][2].  Target the cluster's hook-server (here it's at port 3000).  panda-hook also sets up a git alias under "hook" that's pointed at your hook-server.

```shell
panda-hook push -c core@flavor.pandastrike.com -n vanilla -s root@flavor.pandastrike.com:3000
```

### Step 4 - Deploy
This is the fun part.  Commit any edits you've made and deploy...  via `git push`  Woohooo!
```shell
git add -A
git commit -m "My awesome edits"
git push hook master
```

It make take a couple minutes for a fresh Docker container to build, but subsequent deploys will go much faster.  You've made your first deploy, Huxley-Style!!


[1]:https://github.com/pandastrike/panda-cluster
[2]:https://github.com/pandastrike/panda-hook
