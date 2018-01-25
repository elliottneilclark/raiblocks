#!/bin/bash

MKFILE=`mktemp`
function finish {
  rm $MKFILE
}
trap finish EXIT
echo "include src.mk

util/build_version.cc:	../.git/modules/rocksdb/HEAD	../.git/modules/rocksdb/index
	@echo \"#include \\\"build_version.h\\\"\" > \$@
	@echo \"const char* rocksdb_build_git_sha = \\\"\$(shell git rev-parse HEAD)\\\";\" >> \$@
	@echo \"const char* rocksdb_build_git_date = \\\"\$(shell date +%F)\\\";\" >> \$@
	@echo \"const char* rocksdb_build_compile_date = __DATE__;\" >>\$@

.PHONY:	all
all:	util/build_version.cc
	@echo \$(LIB_SOURCES)" > $MKFILE

pushd rocksdb 2>/dev/null 1>/dev/null
make --makefile $MKFILE all | xargs -d ' ' -n1 -I{} echo "./rocksdb/{}"
popd rocksdb 2>/dev/null 1>/dev/null
