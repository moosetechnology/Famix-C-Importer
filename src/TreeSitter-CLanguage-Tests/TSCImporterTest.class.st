Class {
	#name : 'TSCImporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'importer',
		'model'
	],
	#category : 'TreeSitter-CLanguage-Tests',
	#package : 'TreeSitter-CLanguage-Tests'
}

{ #category : 'as yet unclassified' }
TSCImporterTest >> createFile: aFilename content: aString [

	| file |
	
	file := FileSystem disk workingDirectory / aFilename.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ].
	
	^ file
]

{ #category : 'primitives - path' }
TSCImporterTest >> deleteFile: aFileReference [

	aFileReference exists ifTrue: [ aFileReference delete ]
]

{ #category : 'running' }
TSCImporterTest >> setUp [

	super setUp.

	importer := TSCImporterVisitor new
]

{ #category : 'importer' }
TSCImporterTest >> testImportFromCFile [

	| tempCFile |
	
	tempCFile := self
		             createFile: 'temp.c'
		             content: 'int main(){return 0;}'.
	model := importer importFromFile: tempCFile.
	
	self assert: model isMooseModel.
	
	self deleteFile: tempCFile
]

{ #category : 'importer' }
TSCImporterTest >> testImportFromHeaderFile [

	| tempHeaderFile |
	
	tempHeaderFile := self createFile: 'temp.h' content: 'int func();'.
	model := importer importFromFile: tempHeaderFile.

	self assert: model isMooseModel.

	self deleteFile: tempHeaderFile
]

{ #category : 'importer' }
TSCImporterTest >> testImportFromString [

	model := importer importFromString: 'int maint()'.
	self assert: model isMooseModel
]
