Class {
	#name : 'FamixCImporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'importer',
		'model'
	],
	#category : 'Famix-C-Importer-Tests',
	#package : 'Famix-C-Importer-Tests'
}

{ #category : 'file management' }
FamixCImporterTest >> createFile: aFilename content: aString [

	| file |
	file := self tempFolder / aFilename.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ].

	^ file
]

{ #category : 'running' }
FamixCImporterTest >> setUp [

	super setUp.

	importer := FamixCImporter new.
]

{ #category : 'running' }
FamixCImporterTest >> tearDown [
	
	self tempFolder deleteAll.
	super tearDown
]

{ #category : 'file management' }
FamixCImporterTest >> tempFolder [
	|path|
	path := FileSystem disk workingDirectory / 'famix-c-importer-temp'.
	path ensureCreateDirectory.
	^ path
]

{ #category : 'importer' }
FamixCImporterTest >> testFromProjectPreprocInclude [

	| localIncludes headerFile |
	model := importer import: '/Users/toky/code-examples-to-parse/module/'.

	localIncludes := (model allWithType: FamixCPreprocInclude) select: [ :each | each isLocal ].
	headerFile := (model allWithType: FamixCPreprocHeaderFile) first.

	self assert: localIncludes size equals: 1.
	self assert: localIncludes first includedBy name equals: 'main.c'.
	self assert: localIncludes first included name equals: 'module.h'.
	self assert: headerFile inclusion first class equals: FamixCPreprocInclude
]

{ #category : 'importer' }
FamixCImporterTest >> testImportFromCFile [

	| tempCFile |
	tempCFile := self
		             createFile: 'temp.c'
		             content: 'int main(){return 0;}'.
	model := importer importFromFile: tempCFile.

	self assert: model isMooseModel
]

{ #category : 'importer' }
FamixCImporterTest >> testImportFromFolder [

	| headerFiles cFiles |
	self skip.
	model := importer import: '/Users/toky/code-examples-to-parse/module'.

	headerFiles := model allWithType: FamixCPreprocHeaderFile.
	cFiles := model allWithType: FamixCPreprocCompilationUnit.
	self assert: model name equals: 'module' halt.
	self
		assert: model rootFolder
		equals: '/Users/toky/code-examples-to-parse/module'.
	self assert: headerFiles size equals: 1.
	self assert: cFiles size equals: 2
]

{ #category : 'importer' }
FamixCImporterTest >> testImportFromHeaderFile [

	| tempHeaderFile |
	tempHeaderFile := self createFile: 'temp.h' content: 'int func();'.
	model := importer importFromFile: tempHeaderFile.

	self assert: model isMooseModel
]

{ #category : 'importer' }
FamixCImporterTest >> testImportFromString [

	model := importer importFromString: 'int maint()'.
	self assert: model isMooseModel
]
