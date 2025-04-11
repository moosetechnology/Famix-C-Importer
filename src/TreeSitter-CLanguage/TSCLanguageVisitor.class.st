Class {
	#name : 'TSCLanguageVisitor',
	#superclass : 'TSVisitor',
	#category : 'TreeSitter-CLanguage',
	#package : 'TreeSitter-CLanguage'
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
		
	self class
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
TSCLanguageVisitor >> visitCArgumentList: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
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
TSCLanguageVisitor >> visitCComment: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCCompoundStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
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
TSCLanguageVisitor >> visitCExpressionStatement: aTSNode withFields: fields [
 ^ {
       self visitKey: '<unnamedChild>' inDictionnary: fields.
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
TSCLanguageVisitor >> visitCIdentifier: aTSNode withFields: fields [
 ^ {
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
TSCLanguageVisitor >> visitCNumberLiteral: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCParameterList: aTSNode withFields: fields [
 ^ {
   }

]

{ #category : 'visiting' }
TSCLanguageVisitor >> visitCPreprocInclude: aTSNode withFields: fields [
 ^ {
       self visitKey: 'path' inDictionnary: fields.
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
