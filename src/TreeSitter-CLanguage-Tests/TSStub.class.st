"
Stub for the tests that will behave like a real TSNode
"
Class {
	#name : 'TSStub',
	#superclass : 'Object',
	#instVars : [
		'textFromSourceText',
		'collectFieldNameOfNamedChild',
		'type',
		'startByte',
		'endByte'
	],
	#category : 'TreeSitter-CLanguage-Tests',
	#package : 'TreeSitter-CLanguage-Tests'
}

{ #category : 'visiting' }
TSStub >> accept: aVisitor [

	^aVisitor visitNode: self
]

{ #category : 'accessing' }
TSStub >> collectFieldNameOfNamedChild [

	^collectFieldNameOfNamedChild
]

{ #category : 'accessing' }
TSStub >> collectFieldNameOfNamedChild: aCollection [

	collectFieldNameOfNamedChild := Dictionary newFrom: aCollection
]

{ #category : 'accessing' }
TSStub >> endByte [

	^ endByte
]

{ #category : 'accessing' }
TSStub >> endByte: anObject [

	endByte := anObject
]

{ #category : 'accessing' }
TSStub >> setTextFromSourceText: aString [

	textFromSourceText := aString
]

{ #category : 'accessing' }
TSStub >> startByte [

	^ startByte
]

{ #category : 'accessing' }
TSStub >> startByte: anObject [

	startByte := anObject
]

{ #category : 'accessing' }
TSStub >> startEnd: aPoint [

	startByte := aPoint x.
	endByte := aPoint y
]

{ #category : 'accessing' }
TSStub >> textFromSourceText: aString [

	^textFromSourceText
]

{ #category : 'accessing' }
TSStub >> type [

	^ type
]

{ #category : 'accessing' }
TSStub >> type: aSymbol [

	type := aSymbol 
]
