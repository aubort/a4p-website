#!/bin/bash

# By default, we do not promote the deployed version. 
#This would allow all traffic to be routed to the new version. 
promote="--no-promote"

# Default version is empty, which means gcloud util will assign a new 
# version automatically
version= 

# Build Drafts flag. By default empty, so that drafts are not included
build_drafts=

# gcloud deploy command
command="gcloud preview app deploy"

################################################################################
# Display the help section 
################################################################################
display_help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -v, --version              Set the App Version in the appengine console. If no version is given, App Engine will automatically create a random version"
    echo "                              Usage: --version=staging"
    echo "   --promote                  By default the script does not promote new deployment. To route traffic to the newly deployed version add the --promote flag"
    echo "                              A version can also be promoted after deployment via the App Engine console (https://console.cloud.google.com/appengine)"
    echo "   --buildDrafts              Tells Hugo to build drafts. Default is false. "
    echo
    echo "   --list-versions            Lists all versions of the app that are currently deployed"
    echo
    exit 1
}

################################################################################
# List all versions of the app deployed
################################################################################
list_versions() {
    gcloud app versions list
    exit 1
}

# Parse script arguments 
for i in "$@"
do
case $i in
    -v=*|--version=*)
    version="--version=${i#*=}"
    ;;
    --promote)
    promote="--promote"
    ;;
    --buildDrafts)
    build_drafts="--buildDrafts"
    ;;
    --list-versions)
    list_versions
    ;;
    --help)
    display_help
    ;;
    *)
    ;;
esac
done

echo -e "\033[0;32mDeploying updates to Google App Engine...\033[0m"

# Build the project.
hugo $build_drafts

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

# Build the command line with the arguments 
command="$command $version $promote"

# Run the deployment command
eval $command