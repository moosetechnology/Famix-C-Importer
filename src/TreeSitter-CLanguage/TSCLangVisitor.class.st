Class {
	#name : 'TSCLangVisitor',
	#superclass : 'TSVisitor',
	#instVars : [
		'nodesCollection'
	],
	#classInstVars : [
		'nodesCollection'
	],
	#category : 'TreeSitter-CLanguage',
	#package : 'TreeSitter-CLanguage'
}

{ #category : 'as yet unclassified' }
TSCLangVisitor >> createCVisitingMethod: aSelector [
	"
		example of a visiting method:
		visitCSystem_lib_string: aTSNode
			^self visitCAbstractNode: aTSNode
	"
	|code|
	code := aSelector, ' aTSNode
	^self visitCAbstractNode: aTSNode'.
	
	self class compile: code classified: #visiting.
]

{ #category : 'reflective operations' }
TSCLangVisitor >> doesNotUnderstand: aMessage [
	(aMessage selector beginsWith: 'visitC') 
		ifFalse: [ 
			super doesNotUnderstand: aMessage 
		 ].
	self createCVisitingMethod: aMessage selector.
	
	self perform: aMessage selector with: aMessage arguments first.
]

{ #category : 'initialization' }
TSCLangVisitor >> initialize [ 
	super initialize.
	nodesCollection := OrderedCollection new.
]

{ #category : 'accessing' }
TSCLangVisitor >> nodesCollection [
	^ nodesCollection
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCAbstractNode: aTSNode [
	('Visiting a ', aTSNode type) traceCr.
	nodesCollection add: aTSNode type.
	^ super visitNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCArgument_list: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCCall_expression: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCComment: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCCompound_statement: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCDeclaration: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCExpression_statement: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCFunction_declarator: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCFunction_definition: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCIdentifier: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCInit_declarator: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCNumber_literal: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCParameter_list: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCPreproc_include: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCPrimitive_type: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCReturn_statement: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCString_content: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCString_literal: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCSystem_lib_string: aTSNode [
	^self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitCTranslation_unit: aTSNode [
	^ self visitCAbstractNode: aTSNode
]

{ #category : 'visiting' }
TSCLangVisitor >> visitNode: aTSNode [
	|selector|
	selector := 'visitC', aTSNode type capitalized, ':'.
	^ self perform: selector asSymbol with: aTSNode 
]
