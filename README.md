# Rabbitholer

Because WordPress is just too darn complicated.

## Quickstart

If you're okay doing everything on Github, and using Github Pages, this script is the fastest way to start.

```bash
curl https://raw.githubusercontent.com/Siilikuin/rabbitholer/master/rabbitholer.sh | bash
```

This script does everything locally, except for actually hosting the repos/Pages, and has 3 notable dependencies: [git](https://git-scm.com/), [Hugo](https://gohugo.io/), and [`gh`, the Github CLI](https://cli.github.com/). (If you haven't used it before, you will need to `gh auth login` with it first)

## Slowstart - in a fresh Debian VM

If you have Vagrant and Virtualbox, we can also go through this from scratch using [the install-in-a-box](https://hiandrewquinn.github.io/til-site/posts/the-unreasonable-effectiveness-of-vms-in-hacker-pedagogy/) approach. First get a fresh Debian 12 VM up by running e.g.

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
&& sudo apt install gh git hugo curl -y
```
