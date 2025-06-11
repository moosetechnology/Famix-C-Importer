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

{ #category : 'as yet unclassified' }
FamixCImporterTest >> createFile: aFilename content: aString [

	| file |
	
	file := FileSystem disk workingDirectory / aFilename.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ].
	
	^ file
]

{ #category : 'running' }
FamixCImporterTest >> setUp [

	super setUp.

	importer := FamixCImporter new
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
