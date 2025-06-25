Class {
	#name : 'TSCLanguageVisitor',
	#superclass : 'TSVisitor',
	#category : 'Famix-C-Importer',
	#package : 'Famix-C-Importer'
}

{ #category : 'reflective operations' }
TSCLanguageVisitor >> createVisitMethod: aMessage [
	| fields aTSNode |
	aTSNode := aMessage arguments first.
	fields := aMessage arguments second.
	
	^ String streamContents: [ :code |
			code << 'visitC'.
			($_ split: aTSNode type) do: [ :word | code << word capitalized ].
			
			code << ': aTSNode withFields: fields';cr.
			code << ' ^ {'; cr.
			fields keysDo: [ :key | 
				code 
					<< '       self visitKey: ''';
					<< key;
					<< ''' inDictionnary: fields.';
					cr.
				].
			code << '   }';cr.
			
		]
]

{ #category : 'reflective operations' }
TSCLanguageVisitor >> doesNotUnderstand: aMessage [
	(aMessage selector beginsWith: 'visitC')
		ifFalse: [ super doesNotUnderstand: aMessage ].
		
	TSCLanguageVisitor instanceSide 
		compile: (self createVisitMethod: aMessage )
		classified: #visiting.
		
	self
		perform: aMessage selector
		with: aMessage arguments first
		with: aMessage arguments second
]

{ #category : 'initialization' }
TSCLanguageVisitor >> initialize [ 
	super initialize
]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCAbstractPointerDeclarator: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCArgumentList: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCArrayDeclarator: aTSNode withFields: fields [
 ^ {
       self visitKey: 'declarator' inDictionnary: fields.
       self visitKey: 'size' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCAssignmentExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'left' inDictionnary: fields.
       self visitKey: 'right' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCBinaryExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'left' inDictionnary: fields.
       self visitKey: 'right' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCBreakStatement: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCallExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'function' inDictionnary: fields.
       self visitKey: 'arguments' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCaseStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'value' inDictionnary: fields.
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCastExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'value' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCharLiteral: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCharacter: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCommaExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'left' inDictionnary: fields.
       self visitKey: 'right' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCComment: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCompoundLiteralExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'value' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCompoundStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCConcatenatedString: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCConditionalExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'condition' inDictionnary: fields.
       self visitKey: 'consequence' inDictionnary: fields.
       self visitKey: 'alternative' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCContinueStatement: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCDeclaration: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'declarator' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCDoStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'body' inDictionnary: fields.
       self visitKey: 'condition' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCERROR: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCEnumSpecifier: aTSNode withFields: fields [
 ^ {
       self visitKey: 'name' inDictionnary: fields.
       self visitKey: 'body' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCEnumerator: aTSNode withFields: fields [
 ^ {
       self visitKey: 'name' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCEnumeratorList: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCEscapeSequence: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCExpressionStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFalse: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFieldDeclaration: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'declarator' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFieldDeclarationList: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFieldDesignator: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFieldExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'argument' inDictionnary: fields.
       self visitKey: 'field' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFieldIdentifier: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCForStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'initializer' inDictionnary: fields.
       self visitKey: 'condition' inDictionnary: fields.
       self visitKey: 'update' inDictionnary: fields.
       self visitKey: 'body' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFunctionDeclarator: aTSNode withFields: fields [
 ^ {
       self visitKey: 'declarator' inDictionnary: fields.
       self visitKey: 'parameters' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCFunctionDefinition: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'declarator' inDictionnary: fields.
       self visitKey: 'body' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCGotoStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'label' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCIdentifier: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCIfStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'condition' inDictionnary: fields.
       self visitKey: 'consequence' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCInitDeclarator: aTSNode withFields: fields [
 ^ {
       self visitKey: 'declarator' inDictionnary: fields.
       self visitKey: 'value' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCInitializerList: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCInitializerPair: aTSNode withFields: fields [
 ^ {
       self visitKey: 'designator' inDictionnary: fields.
       self visitKey: 'value' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCLabeledStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'label' inDictionnary: fields.
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCNull: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCNumberLiteral: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCParameterDeclaration: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'declarator' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCParameterList: aTSNode withFields: fields [

 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCParenthesizedDeclarator: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCParenthesizedExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPointerDeclarator: aTSNode withFields: fields [
 ^ {
       self visitKey: 'declarator' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPointerExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'argument' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocArg: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocCall: aTSNode withFields: fields [
 ^ {
       self visitKey: 'directive' inDictionnary: fields.
       self visitKey: 'argument' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocDef: aTSNode withFields: fields [
 ^ {
       self visitKey: 'name' inDictionnary: fields.
       self visitKey: 'value' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocDefined: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocDirective: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocElse: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocFunctionDef: aTSNode withFields: fields [
 ^ {
       self visitKey: 'name' inDictionnary: fields.
       self visitKey: 'parameters' inDictionnary: fields.
       self visitKey: 'value' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocIf: aTSNode withFields: fields [
 ^ {
       self visitKey: 'condition' inDictionnary: fields.
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocIfdef: aTSNode withFields: fields [
 ^ {
       self visitKey: 'name' inDictionnary: fields.
       self visitKey: '<unnamedChild>' inDictionnary: fields.
       self visitKey: 'alternative' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocInclude: aTSNode withFields: fields [
 ^ {
       self visitKey: 'path' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocParams: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPrimitiveType: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCReturnStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCSizedTypeSpecifier: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCSizeofExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCStatementIdentifier: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCStringContent: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCStringLiteral: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCStructSpecifier: aTSNode withFields: fields [
 ^ {
       self visitKey: 'name' inDictionnary: fields.
       self visitKey: 'body' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCSubscriptDesignator: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCSubscriptExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'argument' inDictionnary: fields.
       self visitKey: 'index' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCSwitchStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'condition' inDictionnary: fields.
       self visitKey: 'body' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCSystemLibString: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCTranslationUnit: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCTrue: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCTypeDefinition: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'declarator' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCTypeDescriptor: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: 'declarator' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCTypeIdentifier: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCUnaryExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'argument' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCUnionSpecifier: aTSNode withFields: fields [
 ^ {
       self visitKey: 'name' inDictionnary: fields.
       self visitKey: 'body' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCUpdateExpression: aTSNode withFields: fields [
 ^ {
       self visitKey: 'argument' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCWhileStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: 'condition' inDictionnary: fields.
       self visitKey: 'body' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitKey: aKey inDictionnary: childrenDictionnary [
	| child |
	child := childrenDictionnary at: aKey ifAbsent: [ ^nil ].
	
	^child isCollection 
		ifTrue: [ child collect: [ :c | c accept: self ] ]
		ifFalse: [ child accept: self ]
]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitNode: aTSNode [
	| selector |
	selector := String streamContents: [ :st |
			st << 'visitC'.
			($_ split: aTSNode type) do: [ :word | st << word capitalized ].
			st << ':withFields:'.
		].
	
	^ self 
		perform: selector asSymbol 
		with: aTSNode 
		with: aTSNode collectFieldNameOfNamedChild
]
