#!/bin/bash

echo -e "\033[0;32mDeploying updates to Github...\033[0m"

# Build the project.
hugo -t hyde

# Till will be fixed https://github.com/spf13/hugo/issues/230
rm -rf public/2014
mv public/blog/* public
rm -rf public/blog

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master
git subtree push --prefix=public git@github.com:dddpaul/blog.git gh-pages
