# Rabbitholer

Because WordPress is just too darn complicated.

## Quickstart

If you're okay doing everything on Github, and using Github Pages, this script is the fastest way to start.

```bash
curl https://raw.githubusercontent.com/Siilikuin/rabbitholer/master/rabbitholer.sh | bash
```

This script does everything locally, except for actually hosting the repos/Pages, and has 3 notable dependencies: [git](https://git-scm.com/), [Hugo](https://gohugo.io/), and [`gh`, the Github CLI](https://cli.github.com/). (If you haven't used it before, you will need to `gh auth login` with it first)

## Slowstart - in a fresh Debian VM

If you have Vagrant and Virtualbox, we can also go through this from scratch using [the tutorial-in-a-box](https://hiandrewquinn.github.io/til-site/posts/the-unreasonable-effectiveness-of-vms-in-hacker-pedagogy/) approach. First get a fresh Debian 12 VM up by running e.g.

```bash
mkdir tutorial/
cd tutorial/

vagrant init debian/bookworm64
vagrant up
vagrant ssh
```

Once you're inside, you'll need to install some dependencies. We'll use the [official Debian repo](https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt) for `gh`.

```bash
# While in the Debian 12 VM - ripped straight from the Github docs.
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh git curl -y
```

Debian, as usual, lags behind in software versions somewhat, so we will need to get the latest Hugo from elsewhere:

```bash
sudo apt update
sudo apt install wget tar
wget https://github.com/gohugoio/hugo/releases/download/v0.126.0/hugo_0.126.0_Linux-64bit.tar.gz
tar -xzf hugo_0.126.0_Linux-64bit.tar.gz
sudo mv hugo /usr/bin/
hugo version
```

Log in to Github with your credentials. (The web browser will fail to open, but you can just paste the key in in your non-VM's browser at the given address.)

```bash
# While in the Debian 12 VM - ripped straight from the Github docs.
gh auth login 
```

If `gh auth status` shows you are logged in, then you are ready to go, my friend. Since we're experimenting, we will save the setup script locally and run it with a couple options.


```bash
curl -o rabbitholer.sh https://raw.githubusercontent.com/Siilikuin/rabbitholer/master/rabbitholer.sh
chmod +x rabbitholer.sh
./rabbitholer.sh --help
```

You will likely get that `*** Please tell me who you are.` message the first time you try to actually run this script. 

Running `rabbitholer.sh --force` will **delete your earlier forks** and set up new ones, so use with caution. If you don't have any content except the example content in your `rabbitholer` repo anyway, though, that shouldn't be an issue!

From here you've got a couple options. The flow is always going to be the same:

1. Add to your `rabbitholer-content` repo,
2. `git submodule --update` your `rabbitholer` repo, and
3. Build and push the new changes to your `rabbitholer-pages` repo, however you wish.

In the near future I will write a separate `rabbitholer-update.sh` script which automates these steps, too. Stay tuned!
