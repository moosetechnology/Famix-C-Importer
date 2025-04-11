"
Stub for the tests that will behave like a real TSNode
"
Class {
	#name : 'TSStub',
	#superclass : 'Object',
	#instVars : [
		'textFromSourceText',
		'collectFieldNameOfNamedChild',
		'type'
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
TSStub >> setTextFromSourceText: aString [

	textFromSourceText := aString
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
