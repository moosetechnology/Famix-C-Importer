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

	| sourceCode |
	
	sourceCode := '
	int myFunc();
	'.
	
	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionDefinitionAndDeclarationAddedTwoTimes [

	| sourceCode |
	sourceCode := '
	int func();
	int func(){
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne name equals: 'func'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionDefinitionWithoutDeclaration [

	| sourceCode |
	
	sourceCode := '
	int func(){
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne name equals: 'func'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionIdentifierStartEndPosition [

	| sourceCode |
	sourceCode := 'void func(){}'. "this function starts at index 0 and ends at 13"

	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne sourceAnchor isNotNil.
	self
		assert: importer model allFunctions anyOne sourceAnchor startPos
		equals: 0.
	self
		assert: importer model allFunctions anyOne sourceAnchor endPos
		equals: 13
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableName [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int aLocalVar;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'aLocalVar'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableParentFunction [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int aLocalVar;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self assert:
		importer model allLocalVariables first parentBehaviouralEntity
			isFunction.
	self
		assert:
		importer model allLocalVariables first parentBehaviouralEntity name
		equals: 'parentFunction'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableSkipFileScopeVariable [

	| sourceCode |
	sourceCode := '
	int aFileScopeVar;
	int parentFunction(){
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 0
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableSourceAnchor [
	
	| sourceCode |
	sourceCode := '
	int fn(){
		int aLocalVar; //this local variable declaration starts at index 14 and ends at 28
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables first sourceAnchor startPos equals: 14.
	self assert: importer model allLocalVariables first sourceAnchor endPos equals: 28.
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testLocalVariableWithInitDeclarator [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int aLocalVar = 10;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'aLocalVar'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParamSourceAnchor [

	| sourceCode |
	sourceCode := 'int func(int param1);'. "the parameter declaration starts at 9 and ends at 19"

	importer importFromString: sourceCode.

	self
		assert: importer model allParameters anyOne sourceAnchor startPos
		equals: 9.
	self
		assert: importer model allParameters anyOne sourceAnchor endPos
		equals: 19
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterAddedTwoTimesWithFunctionDeclarationAndDefinition [
	"parameters that are declared in function prototype and in definition should not be added two times in the model"

	| sourceCode paramNames |
	sourceCode := '
	int myFunc(int arg1, int arg2);
	int myFunc(int arg1, int arg2){
		int aLocalVar;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	paramNames := importer model allParameters asCollection collect: [
		              :each | each name ].

	self assert: importer model allParameters size equals: 2.
	self assert: (paramNames includes: 'arg1').
	self assert: (paramNames includes: 'arg2')
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterName [

	| sourceCode |
	sourceCode := '
	int myFunc(int arg1);
	'.

	importer importFromString: sourceCode.

	self assert: importer model allParameters size equals: 1.
	self assert: importer model allParameters anyOne name equals: 'arg1'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterNameWithFunction [

	| sourceCode paramNames |
	sourceCode := '
	int myFunc(int arg1, int arg2);
	'.

	importer importFromString: sourceCode.

	paramNames := importer model allParameters asCollection collect: [
		              :each | each name ].

	self assert: importer model allParameters size equals: 2.
	self assert: (paramNames includes: 'arg1').
	self assert: (paramNames includes: 'arg2')
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterParentFunction [

	| sourceCode |
	sourceCode := '
	int myFunc(int arg1, int arg2);
	'.

	importer importFromString: sourceCode.
	importer model allParameters do: [ :param |
		self assert: param parentBehaviouralEntity isFunction.
		self assert: param parentBehaviouralEntity name equals: 'myFunc' ]
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParametersWithTheSameNameButInDifferentFunction [

	| sourceCode paramNames |
	sourceCode := '
	int myFunc1(int arg1, int arg2);
	int myFunc2(int arg1, int arg2);
	'.

	importer importFromString: sourceCode.

	paramNames := importer model allParameters collect: [ :each |
		              each name ].

	self assert: importer model allParameters size equals: 4.
	self assert: (paramNames count: [ :each | each = 'arg1' ]) equals: 2.
	self assert: (paramNames count: [ :each | each = 'arg2' ]) equals: 2
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructName [

	| sourceCode |
	sourceCode := '
	struct Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCStruct) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCStruct) anyOne name
		equals: 'Person'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructSourceAnchor [

	| sourceCode |
	sourceCode := 'struct Person{int id};'.

	importer importFromString: sourceCode.

	self
		assert:
			(importer model allWithType: FamixCStruct) anyOne sourceAnchor
				startPos
		equals: 0.
	self
		assert:
		(importer model allWithType: FamixCStruct) anyOne sourceAnchor
			endPos
		equals: 21
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testStructTypeVarExcludedFromModel [

	| sourceCode |
	sourceCode := '
	struct Person{int id};
	struct Person p1; //should not create a struct entity inside the model
	'.

	importer importFromString: sourceCode.

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
