# Famix-C importer for Moose

[![CI](https://github.com/moosetechnology/Famix-C-Importer/actions/workflows/ci.yml/badge.svg)](https://github.com/moosetechnology/Famix-C-Importer/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/moosetechnology/Famix-C-Importer/badge.svg?branch=ci-coverall)](https://coveralls.io/github/moosetechnology/Famix-C-Importer?branch=ci-coverall) 

C code importer for the Moose C metamodel, based on Tree-sitter. This importer will create a Famix model representing your C codebase that you can use in Moose for static analysis.

The model is created from the parsed AST by the tree-sitter parser. We use [Pharo-Tree-Sitter](https://github.com/Evref-BL/Pharo-Tree-Sitter) package to parse C code inside Moose.

## Installation


```Smalltalk
Metacello new
	baseline: 'FamixCImporter';
	repository: 'github://moosetechnology/Famix-C-Importer:master/src';
	load.
```
## Usage
```Smalltalk
| model |
model := FamixCImporter import: 'path/to/your/c/folder-or/file.c'.
```
