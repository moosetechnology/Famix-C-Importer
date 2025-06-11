# Famix-C importer for Moose

C code importer for the Moose C metamodel, based on Tree-sitter. This importer will create a Famix model representing your C codebase that you can use in Moose for static analysis.

The model is created from the parsed AST by the tree-sitter parser. We use [Pharo-Tree-Sitter](https://github.com/Evref-BL/Pharo-Tree-Sitter) package to parse C code inside Moose.

## Installation


```Smalltalk
Metacello new
	baseline: 'Famix-C-Importer';
	repository: 'github://moosetechnology/Famix-C-Importer:master/src';
	load.
```
