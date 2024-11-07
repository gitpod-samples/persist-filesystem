# persist filesystem

This repository demonstrates how you can configure your Gitpod workspace so that changes to $HOME (for example) or anywhere outside of `/workspace` directory survives from prebuild environments and between workspace reboots.


# Quick Demo

To give you an idea of what this is and how it works, this repository is configured to persist all changes made to $HOME directory.

How to test this:
1. Open this repository on Gitpod (direct link: https://gitpod.io/#https://github.com/gitpod-samples/persist-filesystem)
2. Open a terminal
3. Switch to $HOME: `cd $HOME`
4. Perform any filesystem operation. For instance, create a new file: `touch hello`
5. Stop your workspace: `gp stop`
6. Re-start the same workspace again.
7. Go back to $HOME and see if you can find the file: `cd && ls`

# How it works and what you need to know

We're using two simple scripts, below is a description of their function

### runonce

[runonce](./runonce) reads the bash scripts from `$HOME/.runonce` directory and ensures that they're executed only once per session of a workspace, with the help of atomic locks. `runonce` command is added to `/etc/bash.bashrc` file, which is loaded on the very beginning of a Gitpod workspace startup via one of the init processes, so even if you use a different SHELL, it should be effective.

### create-overlay

[create-overlay](./create-overlay) is a wrapper script for [fuse-overlayfs](https://github.com/containers/fuse-overlayfs). It's only operation is to easily setup a overlayfs mount for your desired directory outside of `/workspace` in a way that they survive Gitpod workspace restarts or prebuild environments. This is done by redirecting all filesystem operations from your mountpoint to a hidden directory inside `/workspace`.

The usage is as follows:

```bash
# To persist $HOME and /etc directory. Usually, only $HOME is enough.
create-overlay $HOME /etc
```

#### Automatic execution of create-overlay

To set it up automatically each time our workspace starts, we can create a [.runonce](#runonce) script from our Dockerfile as shown below:

```dockerfile
# If you want to persist $HOME (for example)
RUN echo 'create-overlay $HOME' > "$HOME/.runonce/1-home_persist"
```

# How to implement this for your existing Gitpod configuration

- Merge the contents of [Dockerfile](./Dockerfile) with your own Dockerfile, you should exclude the `FROM ...` statement at the top though.
- Copy [runonce](./runonce) and [create-overlay](./create-overlay) scripts over to your repository and commit them.
- Configure [automatic execution](#automatic-execution-of-create-overlay) of [create-overlay](#create-overlay) with your desired directories that you want to persist.