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

	importer := FamixCImporter new
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
FamixCImporterTest >> testImportFromCFile [

	| tempCFile |
	tempCFile := self
		             createFile: 'temp.c'
		             content: 'int main(){return 0;}'.
	model := importer importFromFile: tempCFile.

	self assert: model isMooseModel
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
