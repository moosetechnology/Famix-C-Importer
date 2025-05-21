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

{ #category : 'tests - accesses' }
TSCImporterVisitorTest >> entityNamed: aName in: aCollection [

	^ aCollection detect: [ :each | each name = aName ] ifNone: [ nil ]
]

{ #category : 'running' }
TSCImporterVisitorTest >> setUp [

	super setUp.

	importer := TSCImporterVisitor new fileName: '/test/file/name'
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testAnonymousEnumWithStruct [

	| sourceCode |
	sourceCode := '
	struct Task {
    	enum {
        TODO,
        IN_PROGRESS,
        DONE
    	} state;
	};
	'.

	importer importFromString: sourceCode.
	
	self assert: importer model allEnums anyOne name equals: ''.
	self assert: (importer model allWithType: FamixCAttribute) anyOne declaredType class equals: FamixCEnum.
	self assert: (importer model allWithType: FamixCAttribute) anyOne declaredType enumValues size equals: 3
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testAnonymousEnumWithTypedef [

	| sourceCode |
	sourceCode := '
	typedef enum {
    	LOW,
    	MEDIUM
	} Priority;
	'.

	importer importFromString: sourceCode.
	self
		assert: (importer model allWithType: FamixCAliasType) anyOne name
		equals: 'Priority'.
	self
		assert:
		(importer model allWithType: FamixCAliasType) anyOne aliasedType
			class
		equals: FamixCEnum.

	self assert: importer model allEnums size equals: 1.
	self assert: importer model allEnums anyOne name equals: ''.

	self assert: importer model allEnumValues size equals: 2
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testAnonymousEnumWithVariable [

	| sourceCode |
	sourceCode := '
	int func(){
		enum {
    		OPTION_A,
    		OPTION_B
		} option;
	}
	'.

	importer importFromString: sourceCode.
	
	self assert: importer model allEnums anyOne name equals: ''.
	self assert: importer model allLocalVariables anyOne name equals: 'option'.
	self assert: importer model allLocalVariables anyOne declaredType class equals: FamixCEnum.
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testAnonymousStructAsFieldType [

	| sourceCode structEntities unionEntities attributeEntities |
	sourceCode := '
	union WithNestedStruct {
    	struct {
        	int a; //WithNestedStruct.bar.a to access a
    	} bar;
	};
	'.

	importer importFromString: sourceCode.

	structEntities := importer model allWithType: FamixCStruct.
	unionEntities := importer model allWithType: FamixCUnion.
	attributeEntities := importer model allWithType: FamixCAttribute.

	self assert: attributeEntities size equals: 2. "2 attributes: WithNestedStruct.bar and .a"
	self
		assert: unionEntities anyOne attributes anyOne name
		equals: 'bar'.
	self
		assert: unionEntities anyOne attributes anyOne declaredType class
		equals: FamixCStruct.
	self
		assert:
			(attributeEntities detect: [ :each | each name = 'bar' ])
				declaredType attributes anyOne name
		equals: 'a' "assert bar.a exists"
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testAnonymousStructDeclaration [

	| sourceCode structEntities attributeEntities |
	sourceCode := '
	int main() { 
		struct {
			int a;
		} aVariable;
	}
	'.

	importer importFromString: sourceCode.

	structEntities := importer model allWithType: FamixCStruct.
	attributeEntities := importer model allWithType: FamixCAttribute.
	
	self assert: structEntities size equals: 1.
	self assert: structEntities anyOne name equals: ''.
	self assert: attributeEntities size equals: 1.
	self assert: attributeEntities anyOne name equals: 'a'.
	self assert: importer model allLocalVariables anyOne name equals: 'aVariable'
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testAnonymousUnionAsFieldType [

	| sourceCode structEntities unionEntities attributeEntities |
	sourceCode := '
	struct WithNestedStruct {
    	union {
        	int a; //WithNestedStruct.bar.a to access a
    	} bar;
	};
	'.

	importer importFromString: sourceCode.

	structEntities := importer model allWithType: FamixCStruct.
	unionEntities := importer model allWithType: FamixCStruct.
	attributeEntities := importer model allWithType: FamixCAttribute.
	
	self assert: attributeEntities size equals: 2. "2 attributes: WithNestedStruct.bar and .a"
	self assert: structEntities anyOne attributes anyOne name equals: 'bar'.
	self
		assert: structEntities anyOne attributes anyOne declaredType class
		equals: FamixCUnion.
	self
		assert:
			(attributeEntities detect: [ :each | each name = 'bar' ])
				declaredType attributes anyOne name
		equals: 'a' "assert bar.a exists"
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testAnonymousUnionDeclaration [

	| sourceCode unionEntities attributeEntities |
	sourceCode := '
	int main() { 
		union {
			int a;
		} aVariable;
	}
	'.

	importer importFromString: sourceCode.

	unionEntities := importer model allWithType: FamixCUnion.
	attributeEntities := importer model allWithType: FamixCAttribute.
	
	self assert: unionEntities size equals: 1.
	self assert: unionEntities anyOne name equals: ''.
	self assert: attributeEntities size equals: 1.
	self assert: attributeEntities anyOne name equals: 'a'.
	self assert: importer model allLocalVariables anyOne name equals: 'aVariable'
]

{ #category : 'tests - comments' }
TSCImporterVisitorTest >> testCommentMultipleLine [

	| sourceCode |
	sourceCode := '
	/* 
	a multiple line comment
	*/
	'.

	importer importFromString: sourceCode.

	self assert: importer model allComments size equals: 1.
]

{ #category : 'tests - comments' }
TSCImporterVisitorTest >> testCommentSingleLine [

	| sourceCode |
	sourceCode := '
	// a comment
	'.

	importer importFromString: sourceCode.

	self assert: importer model allComments size equals: 1.
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

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testEnumName [

	| sourceCode |
	sourceCode := '
	enum Color {
    	RED,
    	GREEN,
    	BLUE
	}
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allEnums ) size
		equals: 1.
	self
		assert: (importer model allEnums ) anyOne name
		equals: 'Color'
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testEnumSourceAnchor [

	| sourceCode |
	sourceCode := '
	enum Color {
    	RED,
    	GREEN,
    	BLUE
	}
	'.

	importer importFromString: sourceCode.

	self
		assert: importer model allEnums anyOne sourceAnchor startPos
		equals: 2.
	self
		assert: importer model allEnums anyOne sourceAnchor endPos
		equals: 49
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testEnumValues [

	| sourceCode enumValues |
	sourceCode := '
	enum Color {
    	RED,
    	GREEN = 2
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allEnums anyOne name equals: 'Color'.

	enumValues := importer model allEnums anyOne enumValues.
	self assert: enumValues size equals: 2.
	self assert: enumValues anyOne parentEnum name equals: 'Color'.

	self assert: (enumValues anySatisfy: [ :each | each name = 'RED' ]).
	self assert: (enumValues anySatisfy: [ :each | each name = 'GREEN' ])
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testEnumValuesSourceAnchor [

	| sourceCode |
	sourceCode := '
	enum Color {
    	RED
	}
	'.

	importer importFromString: sourceCode.

	self
		assert: importer model allEnumValues anyOne sourceAnchor startPos
		equals: 20.
	self
		assert: importer model allEnumValues anyOne sourceAnchor endPos
		equals: 23
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testEnumWithTypedef [

	| sourceCode |
	sourceCode := '
	typedef enum Priority {
    	LOW,
    	MEDIUM
	} Priority;
	'.

	importer importFromString: sourceCode.
	self
		assert: (importer model allWithType: FamixCAliasType) anyOne name
		equals: 'Priority'.
	self
		assert:
		(importer model allWithType: FamixCAliasType) anyOne aliasedType
			class
		equals: FamixCEnum.

	self assert: importer model allEnums anyOne name equals: 'Priority'.

	self assert: importer model allEnumValues size equals: 2
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

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testFunctionDefinitionReturnType [

	| sourceCode |
	
	sourceCode := '
	void func(){
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: (importer model allFunctions anyOne attributeAt: #declaredType
				 ifAbsent: [ nil ]) equals: 'void'
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

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testFunctionPrototypeAndDefinitionReturnType [

	| sourceCode |
	
	sourceCode := '
	void func();
	void func(){}
	'.

	importer importFromString: sourceCode.

	self assert: (importer model allFunctions anyOne attributeAt: #declaredType
				 ifAbsent: [ nil ]) equals: 'void'
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testFunctionPrototypeReturnType [

	| sourceCode |
	
	sourceCode := '
	void func();
	'.

	importer importFromString: sourceCode.

	self assert: (importer model allFunctions anyOne attributeAt: #declaredType
				 ifAbsent: [ nil ]) equals: 'void'
]

{ #category : 'tests - accesses' }
TSCImporterVisitorTest >> testLocalVariableAccess [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a;
		a = 3; 
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allAccesses size equals: 1.
	self assert: importer model allAccesses anyOne accessor isFunction.
	self assert: importer model allAccesses anyOne accessor name equals: 'parentFunction'.
	self assert: importer model allAccesses anyOne variable name equals: 'a'.
]

{ #category : 'tests - accesses' }
TSCImporterVisitorTest >> testLocalVariableAccessMultipleFunction [

	| sourceCode |
	sourceCode := '
	int parentFunction1(){
		int a1;
		a1 = 3; 
		return 0;
	}
	int parentFunction2(){
		int a2;
		a2 = 3; 
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allAccesses size equals: 2.
	self
		assert:
			(self entityNamed: 'a2' in: importer model allLocalVariables)
				accessors first name
		equals: 'parentFunction2'
]

{ #category : 'tests - local variables' }
TSCImporterVisitorTest >> testLocalVariableArray [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		char name[50] = "Alice";
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'name'
]

{ #category : 'tests - local variables' }
TSCImporterVisitorTest >> testLocalVariableArrayVariableLength [

	| sourceCode |
	sourceCode := '
	void useVLA(int size) {
    	int vla[size];
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'vla'
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
TSCImporterVisitorTest >> testLocalVariablePointer [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		char *message = "Hello";
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'message'
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

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testLocalVariableType [

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
		assert: (importer model allLocalVariables anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ])
		equals: 'int'
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testLocalVariableTypeAnonymousStruct [

	| sourceCode |
	sourceCode := '
	
	int parentFunction(){
		struct { int id; } aLocalVar;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: (importer model allLocalVariables anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ]) class
		equals: FamixCStruct.
	self
		assert: (importer model allLocalVariables anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ]) name
		equals: ''
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testLocalVariableTypeStruct [

	| sourceCode |
	sourceCode := '
	struct Person { int id; };
	int parentFunction(){
		struct Person aLocalVar;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: (importer model allLocalVariables anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ]) class
		equals: FamixCStruct.
	self
		assert: (importer model allLocalVariables anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ]) name
		equals: 'Person'
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testLocalVariableTypeTypedef [

	| sourceCode |
	sourceCode := '
	typedef int Integer;
	int parentFunction(){
		Integer aLocalVar;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 1.
	self
		assert: (importer model allLocalVariables anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ])
		equals: 'Integer'
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

{ #category : 'tests - local variables' }
TSCImporterVisitorTest >> testNestedLocalVariable [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int levl0;
		{
			int lvl1;
			{
				int lvl2; 
			}
		}
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 3.
	self assert:
		importer model allLocalVariables anyOne parentBehaviouralEntity
			isFunction.
	self
		assert:
		importer model allLocalVariables anyOne parentBehaviouralEntity name
		equals: 'parentFunction'
]

{ #category : 'tests - local variables' }
TSCImporterVisitorTest >> testOneLineMultipleDeclaration [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a, b;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 2.

	self assert:
		(importer model allLocalVariables anySatisfy: [ :var |
			 var name = 'a' ]).
	self assert:
		(importer model allLocalVariables anySatisfy: [ :var |
			 var name = 'b' ]).
	self
		assert:
		importer model allLocalVariables anyOne parentBehaviouralEntity name
		equals: 'parentFunction'
]

{ #category : 'tests - local variables' }
TSCImporterVisitorTest >> testOneLineMultipleDeclarationAndInitialization [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a = 0, b = 1;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 2.

	self assert:
		(importer model allLocalVariables anySatisfy: [ :var |
			 var name = 'a' ]).
	self assert:
		(importer model allLocalVariables anySatisfy: [ :var |
			 var name = 'b' ]).
	self
		assert:
		importer model allLocalVariables anyOne parentBehaviouralEntity name
		equals: 'parentFunction'
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testOneLineMultipleDeclarationType [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a, b;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 2.

	self
		assert:
			((importer model allLocalVariables detect: [ :var | var name = 'a' ])
				 attributeAt: #declaredType
				 ifAbsent: [ nil ])
		equals: 'int'. 
	self
		assert:
			((importer model allLocalVariables detect: [ :var | var name = 'b' ])
				 attributeAt: #declaredType
				 ifAbsent: [ nil ])
		equals: 'int'
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
TSCImporterVisitorTest >> testSkipStructTypeFieldAsStructEntity [

	| sourceCode structEntities |
	sourceCode := '
	struct Inner {
    	int a;
	};
	struct WithNestedStruct {
    	struct Inner foo; // Inner should not be considered as a new struct entity 
	};
	'.
	
	importer importFromString: sourceCode.
	structEntities := importer model allWithType: FamixCStruct.
	self
		assert: structEntities size
		equals: 2.
	self assert: (structEntities count: [ :each | each name = 'Inner' ]) equals: 1.
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testSkipUnionTypeFieldAsUnionEntity [

	| sourceCode unionEntities |
	sourceCode := '
	union Inner {
    	int a;
	};
	union WithNestedUnion {
    	union Inner foo; // Inner should not be considered as a new union entity 
	};
	'.
	
	importer importFromString: sourceCode.
	unionEntities := importer model allWithType: FamixCUnion.
	self
		assert: unionEntities size
		equals: 2.
	self assert: (unionEntities count: [ :each | each name = 'Inner' ]) equals: 1.
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testStructFieldAnonymousStruct [

	| sourceCode |
	sourceCode := '
	struct WithAnonymousStruct{
		struct { 
			struct { 
				int a; // fields a is promoted to most non anonymous outer struct
			 };
		}; 
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCStruct) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCStruct) anyOne name
		equals: 'WithAnonymousStruct'.
	self
		assert: (importer model allWithType: FamixCAttribute) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'a'.
	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne parentType name
		equals: 'WithAnonymousStruct'
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testStructFieldArray [

	| sourceCode |
	sourceCode := '
	struct Person{
		char name[50];
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute ) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'name'
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
TSCImporterVisitorTest >> testStructFieldPointer [

	| sourceCode |
	sourceCode := '
	struct Person{
		int *ptr;
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute ) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'ptr'
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testStructFieldStruct [

	| sourceCode |
	sourceCode := '
	struct Inner {
    	int a;
	};
	struct Person{
		struct Inner inner;
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute) size
		equals: 2.
	self
		assert:
			(importer model detect: [ :each | each name = 'Person' ])
				attributes anyOne name
		equals: 'inner'
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testStructFieldType [

	| sourceCode |
	sourceCode := '
	struct Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert: ((importer model allWithType: FamixCAttribute) anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ])
		equals: 'int'
]

{ #category : 'tests - struct' }
TSCImporterVisitorTest >> testStructMultipleFieldInOneLine [

	| sourceCode attributes |
	sourceCode := '
	struct Person{
		int a, b;
		};
	'.

	importer importFromString: sourceCode.

	attributes := importer model allWithType: FamixCAttribute.
	
	self assert: attributes size equals: 2.
	self assert: (attributes anySatisfy: [ :each | each name = 'a' ]).
	self assert: (attributes anySatisfy: [ :each | each name = 'b' ])
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testStructMultipleFieldInOneLineType [

	| sourceCode |
	sourceCode := '
	struct Person{int a, b;};
	'.

	importer importFromString: sourceCode.

	self
		assert:
			(((importer model allWithType: FamixCAttribute) detect: [ :each |
				  each name = 'b' ]) attributeAt: #declaredType ifAbsent: [ nil ])
		equals: 'int'
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
TSCImporterVisitorTest >> testTypedefForAnonymousStruct [

	| sourceCode |
	sourceCode := '
	typedef struct {
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
		assert:
		(importer model allWithType: FamixCAliasType) anyOne aliasedType class
		equals: FamixCStruct.
	self
		assert: (importer model allWithType: FamixCStruct) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCStruct) anyOne name
		equals: ''
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

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionFieldAnonymousUnion [

	| sourceCode |
	sourceCode := '
	union WithAnonymousUnion{
		union { 
			union { 
				int a; // fields a is promoted to most non anonymous outer union
			 };
		}; 
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCUnion) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCUnion) anyOne name
		equals: 'WithAnonymousUnion'.
	self
		assert: (importer model allWithType: FamixCAttribute) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'a'.
	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne parentType name
		equals: 'WithAnonymousUnion'
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionFieldArray [

	| sourceCode |
	sourceCode := '
	union Person{
		char name[50];
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute ) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'name'
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionFieldName [

	| sourceCode |
	sourceCode := '
	union Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute ) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'id'
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionFieldParent [

	| sourceCode |
	sourceCode := '
	union Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne parentType class
		equals: FamixCUnion.
	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne parentType name
		equals: 'Person'
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionFieldPointer [

	| sourceCode |
	sourceCode := '
	union Person{
		int *ptr;
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute ) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCAttribute) anyOne name
		equals: 'ptr'
]

{ #category : 'tests - type' }
TSCImporterVisitorTest >> testUnionFieldType [

	| sourceCode |
	sourceCode := '
	union Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert: ((importer model allWithType: FamixCAttribute) anyOne
				 attributeAt: #declaredType
				 ifAbsent: [ nil ])
		equals: 'int'
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionFieldUnion [

	| sourceCode |
	sourceCode := '
	union Inner {
    	int a;
	};
	union Person{
		union Inner inner;
	};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCAttribute) size
		equals: 2.
	self
		assert:
			(importer model detect: [ :each | each name = 'Person' ])
				attributes anyOne name
		equals: 'inner'
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionMultipleFieldInOneLine [

	| sourceCode attributes |
	sourceCode := '
	union Person{
		int a, b;
		};
	'.

	importer importFromString: sourceCode.

	attributes := importer model allWithType: FamixCAttribute.
	
	self assert: attributes size equals: 2.
	self assert: (attributes anySatisfy: [ :each | each name = 'a' ]).
	self assert: (attributes anySatisfy: [ :each | each name = 'b' ])
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionName [

	| sourceCode |
	sourceCode := '
	union Person{int id};
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCUnion) size
		equals: 1.
	self
		assert: (importer model allWithType: FamixCUnion) anyOne name
		equals: 'Person'
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionSourceAnchor [

	| sourceCode |
	sourceCode := 'union Person{int id};'.

	importer importFromString: sourceCode.

	self
		assert:
			(importer model allWithType: FamixCUnion) anyOne sourceAnchor
				startPos
		equals: 0.
	self
		assert:
		(importer model allWithType: FamixCUnion) anyOne sourceAnchor
			endPos
		equals: 20
]

{ #category : 'tests - union' }
TSCImporterVisitorTest >> testUnionTypeVarExcludedFromModel [

	| sourceCode |
	sourceCode := '
	union Person{int id};
	union Person p1; //should not create a union entity inside the model
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allWithType: FamixCUnion) size
		equals: 1
]

{ #category : 'tests - enum' }
TSCImporterVisitorTest >> testUsingEnum [

	| sourceCode |
	sourceCode := '
	typedef enum priority {
    	LOW,
    	MEDIUM
	} priority;
	
	int main(){
		enum priority p1;
		priority p2;
	}
	
	'.

	importer importFromString: sourceCode.
	
	self
		assert: (importer model allEnums ) size
		equals: 1.
	self
		assert: (importer model allEnums ) anyOne name
		equals: 'priority'
]
