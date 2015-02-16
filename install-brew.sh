#!/bin/sh

# Download and install latest brew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# update brew now that it's installed
brew doctor && brew update
