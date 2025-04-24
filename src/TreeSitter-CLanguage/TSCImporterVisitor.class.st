Class {
	#name : 'TSCImporterVisitor',
	#superclass : 'TSCLanguageVisitor',
	#instVars : [
		'model',
		'context',
		'sourceCode',
		'fileName',
		'functionRegistry'
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

{ #category : 'visiting' }
TSCImporterVisitor >> extractFunctionNameFromDeclarator: aTSNodeDeclarator [

	| identifier |
	identifier := aTSNodeDeclarator nodeChildByFieldName: 'declarator'.
	^ identifier textFromSourceText: sourceCode
]

{ #category : 'visiting' }
TSCImporterVisitor >> extractSourceAnchor: aTSNode [

	^ FamixCIndexedFileAnchor new
		              startPos: aTSNode startByte;
		              endPos: aTSNode endByte;
		              fileName: fileName.
]

{ #category : 'accessing' }
TSCImporterVisitor >> fileName [

	^ fileName
]

{ #category : 'accessing' }
TSCImporterVisitor >> fileName: anObject [

	fileName := anObject
]

{ #category : 'initialization' }
TSCImporterVisitor >> initialize [ 
	super initialize.
	context := Stack new. 
	model := FamixCModel new.
	functionRegistry := OrderedDictionary new.
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

	| fnName fnEntity |
	fnName := self extractFunctionNameFromDeclarator: aTSNode.
	(functionRegistry includesKey: fnName)
		ifTrue: [ fnEntity := functionRegistry at: fnName ]
		ifFalse: [
			fnEntity := FamixCFunction new.
			fnEntity name: fnName.
			functionRegistry at: fnName put: fnEntity.
			model add: fnEntity ].
	context push: fnEntity.
	
	self visitKey: 'parameters' inDictionnary: fields.
	
	context pop

]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFunctionDefinition: aTSNode withFields: fields [
	"type declarator body"

	| fnName fnEntity declaratorNode |
	declaratorNode := aTSNode nodeChildByFieldName: 'declarator'.
	fnName := self extractFunctionNameFromDeclarator: declaratorNode.

	(functionRegistry includesKey: fnName)
		ifTrue: [ fnEntity := functionRegistry at: fnName ]
		ifFalse: [
			fnEntity := FamixCFunction new.
			fnEntity name: fnName.
			functionRegistry at: fnName put: fnEntity.
			model add: fnEntity ].
	context push: fnEntity.

	super visitCFunctionDefinition: aTSNode withFields: fields.

	context pop
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCIdentifier: aTSNode withFields: fields [
	"no fields"

	| fileAnchor |
	context isNotEmpty ifTrue: [
		fileAnchor := FamixCIndexedFileAnchor new.
		fileAnchor startPos: aTSNode startByte.
		fileAnchor endPos: aTSNode endByte.
		context top sourceAnchor: fileAnchor 
		].

	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCParameterDeclaration: aTSNode withFields: fields [
	"type declarator"

	| paramEntity |
	
	paramEntity := model newParameter.
	paramEntity parentBehaviouralEntity: context top.
	paramEntity name: (self visitKey: 'declarator' inDictionnary: fields).
	
	self visitKey: 'type' inDictionnary: fields.
	
	 ^ paramEntity
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCParameterList: aTSNode withFields: fields [
	"<unnamedChild>"

	"(fields at: '<unnamedChild>') is a TSNode instance if there is only one parameter"

	"otherwise it will be an orederedCollection"

	"before visiting all parameters, we need to check if they have already been added to the model from their function prototype"

	| firstKey parentFunctionEntity |
	fields isEmpty ifTrue: [ ^ self ].

	parentFunctionEntity := context top.
	parentFunctionEntity parameters isNotEmpty ifTrue: [ "parameters already in the model"
		^ self ].

	firstKey := fields keys first.
	(fields at: firstKey) isCollection
		ifTrue: [
			(fields at: firstKey) do: [ :eachParameterDeclaration |
				self
					visitCParameterDeclaration: eachParameterDeclaration
					withFields: eachParameterDeclaration collectFieldNameOfNamedChild ] ]
		ifFalse: [ super visitCParameterList: aTSNode withFields: fields ]
		
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCStructSpecifier: aTSNode withFields: fields [
	"name body"

	| inDeclaration |
	inDeclaration := aTSNode parent type = 'declaration'.

	inDeclaration
		ifTrue: [ self visitKey: 'name' inDictionnary: fields ]
		ifFalse: [ "inside a struct definition"
			context push: model newStruct.
			context top name: (self visitKey: 'name' inDictionnary: fields) ].


	self visitKey: 'body' inDictionnary: fields.
	inDeclaration ifFalse: [ context pop ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCTypeDefinition: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'declarator' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCTypeIdentifier: aTSNode withFields: fields [
	"no fields"

	| fileAnchor |
	context isNotEmpty ifTrue: [
		fileAnchor := FamixCIndexedFileAnchor new.
		fileAnchor startPos: aTSNode startByte.
		fileAnchor endPos: aTSNode endByte.
		context top sourceAnchor: fileAnchor 
		].
	^ aTSNode textFromSourceText: sourceCode
]
