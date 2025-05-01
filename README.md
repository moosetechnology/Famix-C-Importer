# Famix-C importer for Moose

C code importer for the Moose C metamodel, based on Tree-sitter. This importer will create a Famix model representing your C codebase that you can use in Moose for static analysis.

The model is created from the parsed AST by the tree-sitter parser. We use [Pharo-Tree-Sitter](https://github.com/Evref-BL/Pharo-Tree-Sitter) package to parse C code inside Moose.

## Installation
There are 3 steps to install the importer
### 1. Load Famix-Cpp
After opening a Moose image, load the FamixC metamodel in

*Library > Famix > Load additional modules > Load Famix-Cpp*
### 2. Install dependencies
For now you have to install the tree-sitter dependencies first before using this package. But this will change in the future. The dependencies are:
- The shared core library tree-sitters (e.g. libtree-sitter.dylib for mac, .so for linux and .dll for windows)
- The shared parser library of C, built using tree-sitter CLI (tree-sitter-c.dylib)

Copy both files to Pharo lib location. Run this snippet in the Pharo playground to get the folder path:
```Smalltalk
FFIMacLibraryFinder new paths
```
### 3. Install the importer

```Smalltalk
Metacello new
	baseline: 'TreeSitterCLanguage';
	repository: 'github://moosetechnology/TreeSitterCLanguage:master/src';
	load.
```
