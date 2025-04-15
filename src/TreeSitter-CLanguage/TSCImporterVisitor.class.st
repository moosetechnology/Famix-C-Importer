Class {
	#name : 'TSCImporterVisitor',
	#superclass : 'TSCLanguageVisitor',
	#instVars : [
		'model',
		'context',
		'sourceCode'
	],
	#category : 'TreeSitter-CLanguage',
	#package : 'TreeSitter-CLanguage'
}

{ #category : 'accessing' }
TSCImporterVisitor >> context [

	^ context
]

{ #category : 'accessing' }
TSCImporterVisitor >> context: anObject [

	context := anObject
]

{ #category : 'initialization' }
TSCImporterVisitor >> initialize [ 
	super initialize.
	context := Stack new. 
	model := FamixCModel new.
]

{ #category : 'accessing' }
TSCImporterVisitor >> model [

	^ model
]

{ #category : 'accessing' }
TSCImporterVisitor >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
TSCImporterVisitor >> sourceCode: anObject [

	sourceCode := anObject
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFunctionDeclarator: aTSNode withFields: fields [
	"declarator parameters"
	context isNotEmpty ifTrue: [
		(context top class = FamixCFunction) ifTrue: [
			context top name:
				(self visitKey: 'declarator' inDictionnary: fields) ] ].

	self visitKey: 'parameters' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFunctionDefinition: aTSNode withFields: fields [
	"type declarator body"

	context push: model newFunction.

	super visitCFunctionDefinition: aTSNode withFields: fields.

	context pop
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCIdentifier: aTSNode withFields: fields [
	"no fields"

	^aTSNode textFromSourceText: sourceCode
]
