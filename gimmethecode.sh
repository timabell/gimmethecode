#!/bin/bash -e

#		 gimmethecode.sh, A quick script for grabbing a range of git repos from a server.
#    Copyright (C) 2009 Tim Abell <code@timwise.co.uk>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


#you probably want to get your preshared keys working first,
#unless you *really* like typing your password!

#note that where there are submodules, you might get them twice,
#but hey, who cares? you can just leave this running and delete
#what you don't want.

usage()
{
	echo "usage:"
	echo "$0 git-server output-folder"
}

function updateSubmodules()
{
	#recurse submodules and update/init
	modulelist=`$GIT submodule | awk '{print $2;}'`
	if [ "$modulelist" != "" ]
	then
		echo "updating/initializing submodules of `pwd`"
		$GIT submodule update --init
		#uses get submodule name from submodule list output
		for submodule in $modulelist 
		do
			( # subshell to keep current path
				cd "$submodule"
				updateSubmodules
			)
		done
	fi
}

##########

GITSERV=$1
TARGET=$2
GIT="/usr/bin/git"

if [ "$TARGET" == "" ]
then
	echo "target folder missing"
	usage
	exit 1
fi

if [ "$GITSERV" == "" ]
then
	echo "server argument missing"
	usage
	exit 1
fi

#get list of git repos from server
echo "getting repo list from server \"$GITSERV\" via ssh..."
repos=`/usr/bin/ssh $GITSERV 'find /var/git/ -type d -iname "*.git"' | sort`
#count repos
repoqty=`echo "$repos" | wc -l`
for repo in $repos ; do
	echo $repo
done
echo "$repoqty repos found. cloning / updating..."
echo

#create/goto output folder
if [ ! -d "$TARGET" ]
then
	echo "creating output folder $TARGET"
	mkdir -p $TARGET
fi
cd $TARGET

#process each repo
for repo in $repos ; do
	repopath=${repo##/var/git/}  #remove /var/git from front of $repo
	reponame="$repopath" #repo.git foldername, used to keep git extension
	subfolder=${repopath%/*}  #remove git folder name to get local folder path
	if [ "$repopath" == "$subfolder" ] #nothing found
	then
		subfolder=""
	else
		reponame=${repopath##*/}
	fi
	if [[ "$subfolder" != "" && ! -d "$TARGET/$subfolder" ]]
	then
		echo "creating output folder $TARGET/$subfolder"
		mkdir -p "$TARGET/$subfolder"
	fi
	#use subshell to ensure return to current path
	(
		cd "$TARGET/$subfolder"
		if [ -d "$reponame" ] #already exists, run fetch instead
		then
			echo "fetching for exising clone $repopath"
			cd "$reponame"
			$GIT fetch
			cd ..
		else
			echo "cloning $repopath"
			$GIT clone $GITSERV:$repo $reponame
		fi
		#init/update submodules
		cd "$reponame"
		#--recursive becomes available in git 1.6.5. do it manually for now
		#$GIT submodule --recursive update --init
		updateSubmodules
	)
done
echo "finished."


