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
TSCImporterVisitorTest >> testFunctionDefinitionName [

	| tsRoot |
	tsRoot := self tsFunction: 'func'.

	tsRoot accept: importer.
	
	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne name equals: 'func'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionEntityDoesNotExistInModel [

	importer model newFunctionNamed: 'aFunction'.

	self deny:
		(importer ensureEntityExist: FamixCFunction value: 'anotherFunction')
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionEntityExistInModel [

	importer model newFunctionNamed: 'aFunction'.

	self assert:
		(importer ensureEntityExist: FamixCFunction value: 'aFunction')
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
TSCImporterVisitorTest >> testParameterEntityDoesNotExistInModel [

	importer model newParameterNamed: 'aParam'.

	self deny:
		(importer ensureEntityExist: FamixCParameter value: 'anotherParam')
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterEntityExistInModel [

	importer model newParameterNamed: 'aParam'.

	self assert:
		(importer ensureEntityExist: FamixCParameter value: 'aParam')
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
TSCImporterVisitorTest >> testStructEntityDoesNotExistInModel [

	importer model newStruct name: 'AStruct'.

	self deny:
		(importer ensureEntityExist: FamixCStruct value: 'AnotherStruct')
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructEntityExistInModel [

	importer model newStruct name: 'Person'.

	self assert:
		(importer ensureEntityExist: FamixCStruct value: 'Person')
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
TSCImporterVisitorTest >> testStructNameAnchor [

	| tsRoot tsStruct tsTypeIdentifier|
	tsStruct := self tsStructSpecifier: 'Person'.
	
	tsTypeIdentifier := tsStruct collectFieldNameOfNamedChild at: 'name'.
	tsTypeIdentifier startEnd: 1 @ 8.
	
	tsRoot := self tsTranslationUnit: tsStruct.
	tsRoot accept: importer.

	self assert: (importer model allWithType: FamixCStruct ) anyOne sourceAnchor startPos equals: 1.
	self assert: (importer model allWithType: FamixCStruct ) anyOne sourceAnchor endPos equals: 8.
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructTypeVarExcludedFromModel [

	| tsRoot tsStruct |
	tsStruct := self tsStructSpecifier: 'Person'.
	tsRoot := self tsDeclaration: 'p1' type: tsStruct.
	tsRoot accept: importer.

	self assert: (importer model allWithType: FamixCStruct ) size equals: 0.
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
TSCImporterVisitorTest >> tsFunction: aString [

	^ TSStub new
		  type: #function_definition;
		  collectFieldNameOfNamedChild:
			  { (#declarator -> (self tsFunctionDeclarator: aString)) }
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
