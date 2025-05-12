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

{ #category : 'tests - functions' }
TSCImporterVisitorTest >> testFunctionDeclarationWithoutDefinition [

	| sourceCode |
	
	sourceCode := '
	int myFunc();
	'.
	
	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1
]

{ #category : 'tests - functions' }
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

{ #category : 'tests - functions' }
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

{ #category : 'tests - functions' }
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

{ #category : 'tests - local variables' }
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

{ #category : 'tests - local variables' }
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

{ #category : 'tests - local variables' }
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

{ #category : 'tests - local variables' }
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

{ #category : 'tests - local variables' }
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

{ #category : 'tests - parameters' }
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

{ #category : 'tests - parameters' }
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

{ #category : 'tests - parameters' }
TSCImporterVisitorTest >> testParameterName [

	| sourceCode |
	sourceCode := '
	int myFunc(int arg1);
	'.

	importer importFromString: sourceCode.

	self assert: importer model allParameters size equals: 1.
	self assert: importer model allParameters anyOne name equals: 'arg1'
]

{ #category : 'tests - parameters' }
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

{ #category : 'tests - parameters' }
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

{ #category : 'tests - parameters' }
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
TSCImporterVisitorTest >> testParseStringReturnsATSNode [

	| rootNode |
	rootNode := importer parseString: 'int maint(){}'.
	self assert: rootNode class equals: TSNode.
	self assert: rootNode type equals: 'translation_unit'
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testStructFieldName [

	| sourceCode |
	sourceCode := '
	struct Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute ) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'id'
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testStructFieldParent [

	| sourceCode |
	sourceCode := '
	struct Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute) size
		equals: 1.
	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne parentType class
		equals: FamixCStruct.
	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne parentType name
		equals: 'Person'
]

{ #category : 'tests - struct' }
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

{ #category : 'tests - struct' }
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

{ #category : 'tests - struct' }
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

{ #category : 'tests - typedef' }
TSCImporterVisitorTest >> testTypedefForArray [

	| sourceCode |
	sourceCode := '
	typedef int arr[4]; // type definition for an array of size 4
	arr a = { 10, 20, 30, 40 };
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAliasType) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAliasType) anyOne name
		equals: 'arr'
]

{ #category : 'tests - typedef' }
TSCImporterVisitorTest >> testTypedefForPointer [

	| sourceCode |
	sourceCode := '
	typedef int* intPtr; 
	int a = 10;
	intPtr ptr = &a;
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAliasType) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAliasType) anyOne name
		equals: 'intPtr'
]

{ #category : 'tests - typedef' }
TSCImporterVisitorTest >> testTypedefForStruct [

	| sourceCode |
	sourceCode := '
	typedef struct Person {
    int id;
	} Person;
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAliasType) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAliasType) anyOne name
		equals: 'Person'.
	self
		assert: (importer model allWithType: FamixCStruct) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCStruct) anyOne name
		equals: 'Person'
]

{ #category : 'tests - typedef' }
TSCImporterVisitorTest >> testTypedefLongLong [

	| sourceCode |
	sourceCode := '
	typedef long long ll;
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAliasType) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAliasType) anyOne name
		equals: 'll'
]

{ #category : 'tests - typedef' }
TSCImporterVisitorTest >> testTypedefName [

	| sourceCode |
	sourceCode := '
	typedef int Integer;
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAliasType) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAliasType) anyOne name
		equals: 'Integer'
]

{ #category : 'tests - typedef' }
TSCImporterVisitorTest >> testTypedefSourceAnchor [

	| sourceCode |
	"              0                  20"
	"              |                  |"
	sourceCode := 'typedef int Integer;'.

	importer importFromString: sourceCode.

	self
		assert:
			(importer model allWithType: FamixCAliasType) anyOne sourceAnchor
				startPos
		equals: 0.
	self
		assert:
		(importer model allWithType: FamixCAliasType) anyOne sourceAnchor
			endPos
		equals: 20
]
