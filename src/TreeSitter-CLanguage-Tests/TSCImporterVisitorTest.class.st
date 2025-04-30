"
A TSCImporterVisitorTest is a test class for testing the behavior of TSCImporterVisitor
"
Class {
	#name : 'TSCImporterVisitorTest',
	#superclass : 'TestCase',
	#instVars : [
		'importer'
	],
	#category : 'TreeSitter-CLanguage-Tests',
	#package : 'TreeSitter-CLanguage-Tests'
}

{ #category : 'running' }
TSCImporterVisitorTest >> setUp [

	super setUp.

	importer := TSCImporterVisitor new fileName: '/test/file/name'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testEnsureEntityExistForExistingEntity [

	importer model newFunctionNamed: 'aFunction'.

	self assert:
		(importer ensureEntityExist: FamixCFunction value: 'aFunction')
			isFunction.
	self
		assert:
		(importer ensureEntityExist: FamixCFunction value: 'aFunction') name
		equals: 'aFunction'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testEnsureEntityExistForNonExistingEntity [

	self assert:
		(importer ensureEntityExist: FamixCFunction value: 'aFunction')
			isFunction.
	self
		assert:
		(importer ensureEntityExist: FamixCFunction value: 'aFunction') name
		equals: 'aFunction'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionDeclarationWithoutDefinition [

	| tsRoot |
	tsRoot := self tsFunctionDeclarator: 'func'.

	tsRoot accept: importer.

	self assert: importer model allFunctions size equals: 1
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionDefinitionAndDeclarationAddedTwoTimes [

	| tsRoot nodes |
	nodes := OrderedCollection new.
	nodes
		add: (self tsFunctionDeclarator: 'func');
		add: (self tsFunction: 'func').
	tsRoot := self tsTranslationUnit: nodes.

	tsRoot accept: importer.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne name equals: 'func'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionDefinitionWithoutDeclaration [

	| tsRoot |
	tsRoot := self tsFunction: 'func'.

	tsRoot accept: importer.
	
	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne name equals: 'func'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionIdentifierStartEndPosition [

	| tsRoot |
	tsRoot := self tsFunction: 'func'.

	tsRoot startEnd: 1 @ 5.

	tsRoot accept: importer.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne sourceAnchor isNotNil.
	self
		assert: importer model allFunctions anyOne sourceAnchor startPos
		equals: 1.
	self
		assert: importer model allFunctions anyOne sourceAnchor endPos
		equals: 5
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableName [

	| tsDeclaration tsFunction |
	tsDeclaration := self
		                 tsDeclaration: 'aLocalVar'
		                 type: (self tsPrimitiveType: 'int').
	tsFunction := self
		              tsFunction: 'parentFunction'
		              body: (self tsCompoundStatement: tsDeclaration).

	tsFunction accept: importer.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'aLocalVar'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableParentFunction [

	| tsDeclaration tsFunction |
	tsDeclaration := self
		                 tsDeclaration: 'aLocalVar'
		                 type: (self tsPrimitiveType: 'int').
	tsFunction := self
		              tsFunction: 'parentFunction'
		              body: (self tsCompoundStatement: tsDeclaration).

	tsFunction accept: importer.

	self assert: importer model allLocalVariables size equals: 1.
	self assert:
		importer model allLocalVariables first parentBehaviouralEntity isFunction.
	self
		assert:
		importer model allLocalVariables first parentBehaviouralEntity name
		equals: 'parentFunction'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableSkipFileScopeVariable [

	| tsDeclaration tsRoot |
	tsDeclaration := self
		                 tsDeclaration: 'aFileScopeVar'
		                 type: (self tsPrimitiveType: 'int').
	tsRoot := self tsTranslationUnit: tsDeclaration.

	tsRoot accept: importer.

	self assert: importer model allLocalVariables size equals: 0.
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableSourceAnchor [

	| tsDeclaration tsFunction |
	tsDeclaration := self
		                 tsDeclaration: 'aLocalVar'
		                 type: (self tsPrimitiveType: 'int').
	tsDeclaration startEnd: 1 @ 14.
	tsFunction := self
		              tsFunction: 'parentFunction'
		              body: (self tsCompoundStatement: tsDeclaration).

	tsFunction accept: importer.

	self assert: importer model allLocalVariables first sourceAnchor startPos equals: 1.
	self assert: importer model allLocalVariables first sourceAnchor endPos equals: 14.
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableWithInitDeclarator [

	| tsDeclaration tsFunction |
	tsDeclaration := self
		                 tsDeclaration: 'aLocalVar'
		                 type: (self tsPrimitiveType: 'int')
		                 value: (self tsNumberLiteral: 10).
	tsFunction := self tsFunction: 'parentFunction' body: tsDeclaration.

	tsFunction accept: importer.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'aLocalVar'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParamSourceAnchor [

	| tsRoot tsParameter |
	
	tsParameter := (self tsParamater: 'param1') startEnd: 1 @ 7.

	tsRoot := self tsFunctionDeclarator: 'func' parameters: tsParameter.

	tsRoot accept: importer.

	self
		assert: importer model allParameters anyOne sourceAnchor startPos
		equals: 1.
	self
		assert: importer model allParameters anyOne sourceAnchor endPos
		equals: 7
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterAddedTwoTimesWithFunctionDeclarationAndDefinition [

	| tsRoot nodes tsFunctionDefinition tsFunctionDeclarator paramList paramNames |
	paramList := OrderedCollection new.
	paramList
		add: (self tsParamater: 'arg1');
		add: (self tsParamater: 'arg2').
	tsFunctionDeclarator := self
		              tsFunctionDeclarator: 'myFunc'
		              parameters: paramList.
	tsFunctionDefinition := self tsFunction: 'myFunc' parameters: paramList.
	
	nodes := OrderedCollection new.
	nodes add: tsFunctionDeclarator; add: tsFunctionDefinition.
	tsRoot := self tsTranslationUnit: nodes.
	
	tsRoot accept: importer.
	
	paramNames := importer model allParameters asCollection collect: [:each | each name ].
	
	self assert: importer model allParameters size equals: 2.
	self assert: (paramNames includes: 'arg1').
	self assert: (paramNames includes: 'arg2').

]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterName [

	| tsRoot |
	tsRoot := self tsFunctionDeclarator: 'myFunc' parameters: (self tsParamater: 'arg1').
	tsRoot accept: importer.

	self assert: importer model allParameters size equals: 1.
	self assert: importer model allParameters anyOne name equals: 'arg1'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterNameWithFunction [

	| tsFunction paramList paramNames |
	paramList := OrderedCollection new.
	paramList
		add: (self tsParamater: 'arg1');
		add: (self tsParamater: 'arg2').
	tsFunction := self
		              tsFunctionDeclarator: 'myFunc'
		              parameters: paramList.

	tsFunction accept: importer.
	
	paramNames := importer model allParameters asCollection collect: [:each | each name ].
	
	self assert: importer model allParameters size equals: 2.
	self assert: (paramNames includes: 'arg1').
	self assert: (paramNames includes: 'arg2').

]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterParentFunction [

	| tsFunction |
	tsFunction := self tsFunctionDeclarator: 'myFunc' parameters: {
			              (self tsParamater: 'arg1').
			              (self tsParamater: 'arg2') }.

	tsFunction accept: importer.
	importer model allParameters do: [ :param |
		self assert: param parentBehaviouralEntity isFunction.
		self assert: param parentBehaviouralEntity name equals: 'myFunc' ]
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParametersWithTheSameNameButInDifferentFunction [

	| tsRoot nodes paramList paramNames |
	paramList := OrderedCollection new.
	paramList
		add: (self tsParamater: 'arg1');
		add: (self tsParamater: 'arg2').

	nodes := OrderedCollection new.

	nodes
		add: (self tsFunctionDeclarator: 'myFunc1' parameters: paramList);
		add: (self tsFunction: 'myFunc2' parameters: paramList).

	tsRoot := self tsTranslationUnit: nodes.

	tsRoot accept: importer.

	paramNames := importer model allParameters collect: [ :each |
		              each name ].

	self assert: importer model allParameters size equals: 4.
	self assert: (paramNames count: [ :each | each = 'arg1' ]) equals: 2.
	self assert: (paramNames count: [ :each | each = 'arg2' ]) equals: 2
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructName [

	| tsRoot |
	tsRoot := self tsTranslationUnit: (self tsStructSpecifier: 'Person').
	tsRoot accept: importer.

	self assert: (importer model allWithType: FamixCStruct ) size equals: 1.
	self assert: (importer model allWithType: FamixCStruct ) anyOne name equals: 'Person'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructSourceAnchor [

	| tsRoot |
	tsRoot := self tsStructSpecifier: 'Person'.

	tsRoot startEnd: 1 @ 8.

	tsRoot accept: importer.

	self
		assert:
			(importer model allWithType: FamixCStruct) anyOne sourceAnchor
				startPos
		equals: 1.
	self
		assert:
		(importer model allWithType: FamixCStruct) anyOne sourceAnchor
			endPos
		equals: 8
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructTypeVarExcludedFromModel [

	| tsRoot tsStruct tsDeclaration|
	tsStruct := self tsStructSpecifier: 'Person'.
	tsDeclaration := self tsDeclaration: 'p1' type: tsStruct.
	tsRoot := self tsTranslationUnit: { tsStruct . tsDeclaration }.
	tsRoot accept: importer.

	self
		assert: (importer model allWithType: FamixCStruct) size
		equals: 1
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsCompoundStatement: aTSStubOrADictionnary [

	^ TSStub new
		  type: #compound_statement;
		  collectFieldNameOfNamedChild:
			  { ('<unnamedChild>' -> aTSStubOrADictionnary) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsDeclaration: aString type: aTSStub [

	^ TSStub new
		  type: #declaration;
		  collectFieldNameOfNamedChild: {
				  (#declarator -> (self tsIdentifier: aString)).
				  (#type -> aTSStub) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsDeclaration: aString type: aTSStubType value: aTSStubValue [

	^ TSStub new
		  type: #declaration;
		  collectFieldNameOfNamedChild: {
				  (#declarator -> (self tsInitDeclarator: aString value: aTSStubValue)).
				  (#type -> aTSStubType) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunction: aString [

	^ TSStub new
		  type: #function_definition;
		  collectFieldNameOfNamedChild:
			  { (#declarator -> (self tsFunctionDeclarator: aString)) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunction: aString body: aCompoundStatementNode [

	^ TSStub new
		  type: #function_definition;
		  collectFieldNameOfNamedChild: {
				  (#declarator -> (self tsFunctionDeclarator: aString)).
				  (#body -> aCompoundStatementNode) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunction: aString parameters: aTSNodeOrCollection [

	^ TSStub new
		  type: #function_definition;
		  collectFieldNameOfNamedChild:
			  { (#declarator -> (self tsFunctionDeclarator: aString parameters: aTSNodeOrCollection )) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunctionDeclarator: aString [

	^TSStub new
		type: #function_declarator ;
		collectFieldNameOfNamedChild: { #declarator -> (self tsIdentifier: aString) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunctionDeclarator: aString parameters: aTSNodeOrCollection [

	^ TSStub new
		  type: #function_declarator;
		  collectFieldNameOfNamedChild: {
				  (#declarator -> (self tsIdentifier: aString)).
				  (#parameters -> (self tsParamaterList: aTSNodeOrCollection)
				) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsIdentifier: aString [

	^TSStub new
		type: #identifier ;
		setTextFromSourceText: aString
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsInitDeclarator: aString value: aTSNode [

	^ TSStub new
		  type: #init_declarator;
		  collectFieldNameOfNamedChild: {
				  (#declarator -> (self tsIdentifier: aString )).
				  (#value -> aTSNode) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsNumberLiteral: aString [

	^ TSStub new
		  type: #number_literal;
		  setTextFromSourceText: aString
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsParamater: aString [

	^TSStub new
		type: #parameter_declaration ;
		collectFieldNameOfNamedChild: { #declarator -> (self tsIdentifier: aString) }.
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsParamaterList: aTSStubOrADictionnary [

	^TSStub new
		type: #parameter_list ;
		collectFieldNameOfNamedChild: { '<unnamedChild>' -> aTSStubOrADictionnary }.
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsPrimitiveType: aString [

	^ TSStub new
		  type: #primitive_type;
		  setTextFromSourceText: aString
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsStructSpecifier: aString [ 
	^ TSStub new
		type: #struct_specifier;
		collectFieldNameOfNamedChild: { #name -> (self tsTypeIdentifier: aString) }.
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsTranslationUnit: aTSStubOrOrderedCollection [

	^TSStub new
		type: #translation_unit ;
		collectFieldNameOfNamedChild: { '<unnamedChild>' -> aTSStubOrOrderedCollection}.
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsTypeIdentifier: aString [ 
	^TSStub new
		type: #type_identifier ;
		setTextFromSourceText: aString
]
