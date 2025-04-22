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
		context top class = FamixCFunction ifTrue: [
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

	| fileAnchor |
	fileAnchor := FamixCIndexedFileAnchor new.
	fileAnchor startPos: aTSNode startByte.
	fileAnchor endPos: aTSNode endByte.
	context top sourceAnchor: fileAnchor.
	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCParameterDeclaration: aTSNode withFields: fields [
	"type declarator"

	context push: model newParameter.
	context top name: (self visitKey: 'declarator' inDictionnary: fields).
	self visitKey: 'type' inDictionnary: fields.

	context pop
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCParameterList: aTSNode withFields: fields [
	"fields is a TSNode instance if there is only one parameter"

	"otherwise it will be an orederedCollection"

	| firstKey |
	fields isEmpty ifTrue: [ ^ {  } ].
	firstKey := fields keys first.
	(fields at: firstKey) isCollection
		ifTrue: [
			(fields at: firstKey) do: [ :eachParameterDeclaration |
				self
					visitCParameterDeclaration: eachParameterDeclaration
					withFields: eachParameterDeclaration collectFieldNameOfNamedChild ] ]
		ifFalse: [ super visitCParameterList: aTSNode withFields: fields ]
]
