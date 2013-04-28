#!/bin/bash

EXIT_FAILED=611
EXIT_OK=0
CALLPWD=$PWD

PROJECT_NAME=connman
BUILD_VERSION=
BUILD_RELEASE=1.0
LICENCSE="GPL-2.0"
SUMMARY="Connection Manager"
SOURCE_URL="http://connman.net/"
RPM_GROUP="System/Daemons"
RPM_SOURCE="http://www.kernel.org/pub/linux/network/connman/connman-%{version}.tar.xz"
GIT_DIR="$HOME/Development/sources/connman"
if [ -n "$1" ] ; then
  GIT_DIR="$1"
fi

START_VERSION=1.10 #might be unset. The latest version is taken that way
MULTPLER=10000 #tmp multipler to transform float(version no) to int

GIT_BIN=`which git`
if [ -z $GIT_BIN ] ; then
  echo "install git please"
  exit $EXIT_FAILED
fi

#---------------------------------------------------------------
# Taking latest git version. If higher than previous - continue
#---------------------------------------------------------------
LAST_TAG_FILE="$CALLPWD/lastTag"
LATEST_GIT_TAG_INT=0

echo "Requesting latest git tag..."
cd $GIT_DIR
git_tag_orig=`$GIT_BIN describe --abbrev=0`
cd $CALLPWD

#searching for the latest git tag
if [ -z $git_tag_orig ] ; then
  echo 'cannot apply command git describe --abbrev=0'
  exit $EXIT_FAILED
fi

BUILD_VERSION=$git_tag_orig
git_tag_int=`echo "$git_tag_orig"' * '$MULTPLER | bc | sed 's,\.0*,,'`

# file does not exist
if [ ! -f $LAST_TAG_FILE ] ; then
    echo "First script call..."
# file exist. Read file content
else
    file_version=`cat $LAST_TAG_FILE`
    file_version_int=`echo "$file_version"' * '$MULTPLER | bc | sed 's,\.0*,,'`
    # just taken tag is greater than existing
    if [ $file_version_int -lt $git_tag_int ] ; then
      BUILD_VERSION=$git_tag_orig
      echo "New tag found. Setting new tag as $BUILD_VERSION..."
    # nothing to do
    else
      echo "no new tag version found"
      exit $EXIT_OK
    fi
fi

#echo -n $BUILD_VERSION > $LAST_TAG_FILE
echo "Building new version $BUILD_VERSION..."
PROJECT_FULL_NAME=${PROJECT_NAME}-${BUILD_VERSION}

#---------------------------------------------------------------
# Creating local environment to run rpmbuild
#---------------------------------------------------------------
SH_RPM_TOP_DIR="$CALLPWD/.rpmTmp/${PROJECT_FULL_NAME}"
rm -rf $SH_RPM_TOP_DIR 2 > /dev/null
mkdir -pv "$SH_RPM_TOP_DIR/BUILD" 2>/dev/null
mkdir -pv "$SH_RPM_TOP_DIR/BUILDROOT" 2>/dev/null
mkdir -pv "$SH_RPM_TOP_DIR/RPMS" 2>/dev/null
mkdir -pv "$SH_RPM_TOP_DIR/SOURCES" 2>/dev/null
mkdir -pv "$SH_RPM_TOP_DIR/SPECS" 2>/dev/null
mkdir -pv "$SH_RPM_TOP_DIR/SRPMS" 2>/dev/null
mkdir -pv "$SH_RPM_TOP_DIR/tmp" 2>/dev/null

#---------------------------------------------------------------
# Placing src to "SOURCES" dir
#---------------------------------------------------------------

#create tmp git dir
tmp_git_dir="/tmp/git_snapshot_${PROJECT_FULL_NAME}_`date | sed 's,[ :\/],_,g'`"
mkdir -p $tmp_git_dir 2>/dev/null
echo "Tmp git dir $tmp_git_dir"
cd $tmp_git_dir

# archive with patches
if [ -n $START_VERSION -a $START_VERSION != $BUILD_VERSION ] ; then
  
  PROJECT_START_FULL_NAME=${PROJECT_NAME}-${START_VERSION}

  cp -rf $GIT_DIR/* $tmp_git_dir 2>/dev/null
  cp -rf $GIT_DIR/.[^.]* $tmp_git_dir 2>/dev/null

  #get the commit start tag refers to
  first_version_commit=`$GIT_BIN rev-list "$START_VERSION" | head -n 1`
  patches_list=`$GIT_BIN tag --contains $first_version_commit`
 
  prev_tag=
  for next_tag in $patches_list ; do
    if [ $prev_tag ] ; then
      echo "generating patch between $prev_tag and $next_tag..."
      patch_file="$SH_RPM_TOP_DIR/SOURCES/$PROJECT_NAME-$next_tag.patch"
      $GIT_BIN diff $prev_tag $next_tag > "$patch_file"
      if [ -e "$patch_file" ] ; then
	echo "patch $patch_file has been successfully created"
      fi
    fi
    prev_tag=$next_tag
  done
  echo "Patches created..."

  echo "Switching git repo to $START_VERSION state..."
  $GIT_BIN stash
  $GIT_BIN checkout $START_VERSION 1>/dev/null 2>/dev/null 
  mkdir ${PROJECT_START_FULL_NAME} 2>/dev/null
  cp -rf $tmp_git_dir/* ${PROJECT_START_FULL_NAME} 2>/dev/null
  #cp -rf $tmp_git_dir/.[^.]* ${PROJECT_START_FULL_NAME} 2>/dev/null
  echo "Creating destination tar archive..."
  tar_file="$SH_RPM_TOP_DIR/SOURCES/${PROJECT_START_FULL_NAME}.tar.xz"
  tar -cJf "$tar_file"  "${PROJECT_START_FULL_NAME}"
  echo "$tar_file has been successfully created"

#pure archive
else
  mkdir -p ${tmp_git_dir}/${PROJECT_FULL_NAME}
  cp -rf $GIT_DIR/* ${tmp_git_dir}/${PROJECT_FULL_NAME} 2>/dev/null
  echo "Creating destination tar archive..."
  tar_file="$SH_RPM_TOP_DIR/SOURCES/${PROJECT_FULL_NAME}.tar.xz"
  tar -cJf "$tar_file"  "${PROJECT_FULL_NAME}"
  echo "$tar_file has been successfully created"
fi

#Cleaning tmp dir
rm -rf $tmp_git_dir 1>/dev/null 2>/dev/null
cd $CALLPWD

#---------------------------------------------------------------
# cp the spec file to SPECS dir
#---------------------------------------------------------------
cp -rf ${PROJECT_NAME}.spec $SH_RPM_TOP_DIR/SPECS
cd $SH_RPM_TOP_DIR/SPECS
 
#change the spec file

#rpmbuild --define "_topdir $SH_RPM_TOP_DIR" -ba ${PROJECT_NAME}.spec

#sed '/^Name:.*/{x;p;x}' ${PROJECT_NAME}.spec | cat | head -3 
#ls -1 *.patch | sed = | sed 'N;s/\n/\t/d

# Replace necessary fields
sed "/^Name:.*/s//Name:\t$PROJECT_NAME/;\
     /^Version:.*/s//Version:\t$BUILD_VERSION/;\
     /^Release:.*/s//Release:\t$BUILD_RELEASE/;\
     /^License:.*/s//License:\t$LICENCSE/;" ${PROJECT_NAME}.spec
 
# Remove all the rest existing tag references
sed "/^Summary:/d;/^Url:/d;/^Group:/d;/^Source:.*/d;/^Patch:.*/d;/%Patch:.*/d" ${PROJECT_NAME}.spec
# Name:		connman
# Version:	1.12
# Release:	1.0
# License:	GPL-2.0
# Summary:	Connection Manager
# Url:		http://connman.net/
# Group:		System/Daemons
# Source:		http://www.kernel.org/pub/linux/network/connman/connman-%{version}.tar.xz
# Patch :		connman-1.13.patch


# patch_replace=`ls -1 *.patch | sed = | sed 's/^/Patch/;N;s/\n/:\t/'`
# echo "$patch_replace"

echo finished





