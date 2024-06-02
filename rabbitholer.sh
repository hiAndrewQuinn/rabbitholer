#!/bin/bash

set -euo pipefail

FORCE=false

# Function to display help message
show_help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "  --force           Delete existing forks and recreate them from scratch"
	echo "  --help            Show this help message and exit"
}

# Parse command line options
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	--force)
		FORCE=true
		shift # past argument
		;;
	--help)
		show_help
		exit 0
		;;
	*)
		shift # past argument
		;;
	esac
done

# Function to check if a command is available
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Check if git is installed
if ! command_exists git; then
	echo "git is not installed."
	exit 1
fi

# Check if gh is installed
if ! command_exists gh; then
	echo "gh is not installed."
	exit 1
fi

# Check if Hugo is installed
if ! command_exists hugo; then
	echo "hugo is not installed."
	exit 1
fi

# Run gh auth status and check for login status
GH_STATUS=$(gh auth status 2>&1)
if echo "$GH_STATUS" | grep -q "Logged in to github.com account"; then
	# Extract the GitHub username
	GH_USER=$(echo "$GH_STATUS" | grep "Logged in to github.com account" | awk '{print $7}' | tr -d '()')
	echo "Hello ${GH_USER}!"
else
	echo "Not logged in to GitHub."
	exit 1
fi

# Function to delete a repository
delete_repo() {
	local REPO=$1
	if gh repo view "${GH_USER}/${REPO}" >/dev/null 2>&1; then
		echo "Deleting your fork of siilikuin/${REPO}..."
		gh repo delete "${GH_USER}/${REPO}" --yes
	fi
}

# Function to check and fork a repository
check_and_fork_repo() {
	local REPO=$1
	local FORK_REPO="https://github.com/${GH_USER}/${REPO}"

	if $FORCE; then
		delete_repo "${REPO}"
	fi

	if gh repo view "${GH_USER}/${REPO}" >/dev/null 2>&1; then
		echo "You already have a fork of siilikuin/${REPO}."
	else
		echo "Forking siilikuin/${REPO} to your account..."
		gh repo fork siilikuin/${REPO} --clone=false
		echo "Fork created: ${FORK_REPO}"
	fi
}

# Check and fork siilikuin/rabbitholer-content
check_and_fork_repo "rabbitholer-content"

# Check and fork siilikuin/rabbitholer
check_and_fork_repo "rabbitholer"

echo "... Waiting 3 seconds, to let Github catch up"
sleep 1 && echo "... 2"
sleep 1 && echo "... 1"
sleep 1 && echo "... back to it!"

# Define the working directory
WORK_DIR="$HOME/rabbitholer-work"

# Clear out the working directory if it exists
if [ -d "$WORK_DIR" ]; then
	echo "Clearing out the working directory..."
	rm -rf "$WORK_DIR"
fi

# Create the working directory
mkdir -p "$WORK_DIR"

echo "Cloning your fork of siilikuin/rabbitholer to $WORK_DIR"
git clone "https://github.com/${GH_USER}/rabbitholer" "$WORK_DIR/rabbitholer"

# Change to the cloned directory
cd "$WORK_DIR/rabbitholer"

# Update the submodule to point to the user's forked rabbitholer-content
git submodule deinit -f content
rm -rf .git/modules/content
git submodule update --init --recursive

# Directly modify the .gitmodules file
sed -i "s|https://github.com/Siilikuin/rabbitholer-content|https://github.com/${GH_USER}/rabbitholer-content|g" .gitmodules

git submodule sync
git submodule update --init --recursive

# Commit the submodule change
git add .gitmodules
git commit -m "Update submodule to use forked rabbitholer-content"

# Push the change to the user's fork
git push origin master

echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

# Create the rabbitholer-pages repository if it doesn't exist
if ! gh repo view "${GH_USER}/rabbitholer-pages" >/dev/null 2>&1; then
	echo "Creating the rabbitholer-pages repository..."
	gh repo create "${GH_USER}/rabbitholer-pages" --public --description "Built Hugo site for rabbitholer" --homepage "https://${GH_USER}.github.io/rabbitholer-pages"
fi

# Build the Hugo site with the correct baseURL
BASE_URL="https://${GH_USER}.github.io/rabbitholer-pages/"
hugo --minify -d "${WORK_DIR}/rabbitholer/public" --baseURL "$BASE_URL"

# Clone the rabbitholer-pages repository into the public directory
cd "${WORK_DIR}/rabbitholer/public"
git init
git remote add origin "https://github.com/${GH_USER}/rabbitholer-pages.git"
git checkout -b gh-pages

# Add and commit the built site
git add .
git commit -m "Deploy Hugo site"

# Push to the gh-pages branch
git push -u origin gh-pages --force

# Configure GitHub Pages if not already configured
PAGES_STATUS=$(gh api "/repos/${GH_USER}/rabbitholer-pages/pages" -H "Accept: application/vnd.github.v3+json" 2>&1 || true)
if echo "$PAGES_STATUS" | grep -q "Not Found"; then
	gh api -X POST "/repos/${GH_USER}/rabbitholer-pages/pages" -f "source[branch]=gh-pages" -f "source[path]=/" || true
else
	echo "GitHub Pages is already enabled."
fi

echo "Your site has been built and deployed to GitHub Pages: https://${GH_USER}.github.io/rabbitholer-pages"

exit 0
