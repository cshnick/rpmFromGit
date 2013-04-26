#!/bin/bash

source metaspec

EXIT_FAILED=611
EXIT_OK=0
PROJECT_NAME=connman

LAST_TAG_FILE="$PWD/lastTag"
LATEST_GIT_TAG_INT=0
BUILD_VERSION=
START_VERSION=1.12
CALLPWD=$PWD
MULTPLER=10000

GIT_BIN=`which git`
if [ -z $GIT_BIN ] ; then
  echo "install git please"
  exit $EXIT_FAILED
fi

GIT_DIR="$HOME/Development/sources/connman"

#---------------------------------------------------------------
# Taking latest git version. If higher than previous - continue
#---------------------------------------------------------------
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
  first_version_commit=`git rev-list "$START_VERSION" | head -n 1`
  patches_list=`git tag --contains $first_version_commit`
 
  prev_tag=
  for next_tag in $patches_list ; do
    if [ $prev_tag ] ; then
      echo "generating patch between $prev_tag and $next_tag..."
      patch_file="$SH_RPM_TOP_DIR/SOURCES/$PROJECT_NAME-$next_tag.patch"
      git diff $prev_tag $next_tag > "$patch_file"
      if [ -e "$patch_file" ] ; then
	echo "patch $patch_file has been successfully created"
      fi
    fi
    prev_tag=$next_tag
  done
  echo "Patches created..."

  echo "Switching git repo to $START_VERSION state..."
  git stash
  git checkout $START_VERSION 1>/dev/null 2>/dev/null 

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

#rpmbuild --define "_topdir $SH_RPM_TOP_DIR" -ba ${PROJECT_NAME}.spec

sed 's,#==#Name,'"Name $PROJECT_NAME"',' ${PROJECT_NAME}.spec | cat


echo finished





