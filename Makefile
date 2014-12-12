
SASS2SCSS_VERSION := $(shell git describe --abbrev=4 --dirty --always --tags)

lib_objs = vendor/sourcemap.cpp/json/json.o \
		   vendor/sourcemap.cpp/src/row.o \
		   vendor/sourcemap.cpp/src/index.o \
		   vendor/sourcemap.cpp/src/entry.o \
		   vendor/sourcemap.cpp/src/mapping.o \
		   vendor/sourcemap.cpp/src/position.o \
		   vendor/sourcemap.cpp/src/format/v3.o \
		   vendor/sourcemap.cpp/src/sourcemap.o \
		   vendor/libb64-1.2/src/cencode.o

ifeq ($(OS),Windows_NT)
	MV ?= move
	CP ?= copy /Y
	RM ?= del /Q /F
	EXESUFFIX ?= .exe
	SUFFIX ?= 2>NULL
else
	MV ?= mv -f
	CP ?= cp -f
	RM ?= rm -rf
	EXESUFFIX ?=
	SUFFIX ?=
endif

CXX = g++
CXXFLAGS = -Wall -fopenmp -O2 -DSASS2SCSS_VERSION="\"$(SASS2SCSS_VERSION)\"" \
	-Ivendor/sourcemap.cpp/src -Ivendor/sourcemap.cpp/json -Ivendor/libb64-1.2/include

all: sass2scss

b64:
	$(MAKE) CXX=$(CXX) -C vendor/libb64-1.2/src

sourcemap:
	$(MAKE) CXX=$(CXX) -C vendor/sourcemap.cpp tool

sass2scss.o: sass2scss.cpp
	$(CXX) $(CXXFLAGS) -c sass2scss.cpp

sass2scss: sourcemap b64 sass2scss.o
	$(CXX) $(CXXFLAGS) -o sass2scss -I. tool/sass2scss.cpp sass2scss.o $(lib_objs)

clean:
	$(RM) sass2scss$(EXESUFFIX) $(SUFFIX)
	$(MAKE) -C vendor/libb64-1.2 clean
	$(MAKE) -C vendor/sourcemap.cpp clean
