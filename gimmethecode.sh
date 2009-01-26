#!/bin/bash

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

GITSERV=$1
GIT="/usr/bin/git"
TARGET="the-code"

if [ -d ./$TARGET ]; then
	echo "target folder $TARGET already exists"
	exit 1
fi


#get list of git repos from server
echo "getting repo list from server \"$GITSERV\" via ssh..."
repos=`/usr/bin/ssh $GITSERV 'find /var/git/ -type d -iname "*.git"'`
#count repos
repoqty=`echo "$repos" | wc -l`
for repo in $repos ; do
	echo $repo
done
echo "$repoqty repos found:"

echo "creating output folder $TARGET"
mkdir $TARGET
cd $TARGET
echo 'cloning repos and submodules...'
#for each repo
for repo in $repos ; do
	echo "cloning $repo"
	repopath=${repo##/var/git/}  #remove /var/git from front of $repo
	echo "repopath $repopath"
	subfolder=${repopath%/*}  #remove git folder name to get local folder path
	echo "subfolder $subfolder"
	
	#$GIT clone $GITSER:$repo 
done

#clone

#look for submodules
#for each submodule
#initialize and update
