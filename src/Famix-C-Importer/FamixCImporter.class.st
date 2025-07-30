"
this is the importer (1)
"
Class {
	#name : 'FamixCImporter',
	#superclass : 'FamixTSAbstractImporter',
	#instVars : [
		'fileName'
	],
	#category : 'Famix-C-Importer',
	#package : 'Famix-C-Importer'
}

{ #category : 'importer' }
FamixCImporter >> acceptedExtensions [

	^ #( 'c' 'h' )
]

{ #category : 'accessing' }
FamixCImporter >> fileName [

	^ fileName
]

{ #category : 'accessing' }
FamixCImporter >> fileName: anObject [

	fileName := anObject
]

{ #category : 'api' }
FamixCImporter >> importFileReference: aFileReference [
	"We can have two cases here:
	 1. it's a file: so we parse its content if it's a .c or .h file. We skip other files
	 2. it's a directory: we will visit it's children (might be files or/and directories)
	"

	aFileReference isFile
		ifTrue: [
				| fileEntity |
				(self isCFile: aFileReference) ifFalse: [ ^ self ].

				fileEntity := aFileReference extension = 'c'
					              ifTrue: [
					              visitor newPreprocCompilationUnit: aFileReference ]
					              ifFalse: [
					              visitor newPreprocHeaderFile: aFileReference ].
				
				visitor
					useCurrentEntity: fileEntity
					during: [ self importFile: aFileReference ] ]
		ifFalse: [
				aFileReference pathString ~= visitor model rootFolder ifTrue: [
					visitor newPreprocFolder: aFileReference ].

				aFileReference children do: [ :each |
					self importFileReference: each ].

				^ self ]
]

{ #category : 'importer' }
FamixCImporter >> importFromString: aString [

	| rootNode file |
	file := FileSystem memory / 'testFile.c'.
	file writeStreamDo: [ :s | s nextPutAll: aString ].
	^ self import: file
]

{ #category : 'testing' }
FamixCImporter >> isCFile: aFileReference [

	^ self acceptedExtensions includes: aFileReference extension
]

{ #category : 'accessing' }
FamixCImporter >> model [
	^ visitor model
]

{ #category : 'as yet unclassified' }
FamixCImporter >> treeSitterLanguage [
	"Should return a TreeSitter language such as  TSLanguage python"

	^ TSLanguage cLang 
]

{ #category : 'accessing' }
FamixCImporter >> visitorClass [
	"Return the class of the visitor to use. It should be a subclass of FamixTSAbstractVisitor."

	^ FamixCVisitor 
]
