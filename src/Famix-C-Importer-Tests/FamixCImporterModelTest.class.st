"
A TSCImporterVisitorTest is a test class for testing the behavior of TSCImporterVisitor
"
Class {
	#name : 'FamixCImporterModelTest',
	#superclass : 'TestCase',
	#instVars : [
		'importer'
	],
	#category : 'Famix-C-Importer-Tests',
	#package : 'Famix-C-Importer-Tests'
}

{ #category : 'asserting' }
FamixCImporterModelTest >> assertProperty: aSymbol of: aFamixCEntity equals: anObject [

	self
		assert: (aFamixCEntity attributeAt: aSymbol ifAbsent: [ nil ])
		equals: anObject
]

{ #category : 'asserting' }
FamixCImporterModelTest >> assertPropertyClass: aSymbol of: aFamixCEntity equals: aFamixCClass [

	self
		assert: (aFamixCEntity attributeAt: aSymbol ifAbsent: [ nil ]) class
		equals: aFamixCClass
]

{ #category : 'tests' }
FamixCImporterModelTest >> entityNamed: aName in: aCollection [

	^ aCollection detect: [ :each | each name = aName ] ifNone: [ nil ]
]

{ #category : 'running' }
FamixCImporterModelTest >> setUp [

	super setUp.

	importer := FamixCImporterVisitor new fileName: '/test/file/name'
]

{ #category : 'tests - enum' }
FamixCImporterModelTest >> testAnonymousEnumWithStruct [

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
FamixCImporterModelTest >> testAnonymousEnumWithTypedef [

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
FamixCImporterModelTest >> testAnonymousEnumWithVariable [

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
	self
		assert: importer model allLocalVariables anyOne name
		equals: 'option'.
	self
		assert: importer model allLocalVariables anyOne declaredType
		equals: importer model allEnums anyOne
]

{ #category : 'tests - union' }
FamixCImporterModelTest >> testAnonymousStructAsFieldType [

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
FamixCImporterModelTest >> testAnonymousStructDeclaration [

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
	self assert: importer model allLocalVariables anyOne name equals: 'aVariable'.
	self assert: importer model allLocalVariables anyOne declaredType class equals: FamixCStruct
]

{ #category : 'tests - struct' }
FamixCImporterModelTest >> testAnonymousUnionAsFieldType [

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
FamixCImporterModelTest >> testAnonymousUnionDeclaration [

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

{ #category : 'tests - typedef' }
FamixCImporterModelTest >> testChainedTypedefPrimitive [

	| sourceCode aliases |
	sourceCode := '
	typedef int Integer1;
	typedef Integer1 Integer2;
	'.

	importer importFromString: sourceCode.

	aliases := importer model allWithType: FamixCAliasType.

	self assert: aliases size equals: 2.
	self assert: aliases first name equals: 'Integer1'.
	self assert: aliases first aliasedType name equals: 'int'.
	self assert: aliases second name equals: 'Integer2'.
	self assert: aliases second aliasedType name equals: 'Integer1'
]

{ #category : 'tests - comments' }
FamixCImporterModelTest >> testCommentMultipleLine [

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
FamixCImporterModelTest >> testCommentSingleLine [

	| sourceCode |
	sourceCode := '
	// a comment
	'.

	importer importFromString: sourceCode.

	self assert: importer model allComments size equals: 1.
]

{ #category : 'tests' }
FamixCImporterModelTest >> testEnsureEntityExistForExistingEntity [

	importer model newFunctionNamed: 'aFunction'.

	self assert:
		(importer ensureEntityExist: FamixCFunction name: 'aFunction')
			isFunction.
	self
		assert:
		(importer ensureEntityExist: FamixCFunction name: 'aFunction') name
		equals: 'aFunction'
]

{ #category : 'tests' }
FamixCImporterModelTest >> testEnsureEntityExistForNonExistingEntity [

	self assert:
		(importer ensureEntityExist: FamixCFunction name: 'aFunction')
			isFunction.
	self
		assert:
		(importer ensureEntityExist: FamixCFunction name: 'aFunction') name
		equals: 'aFunction'
]

{ #category : 'tests - enum' }
FamixCImporterModelTest >> testEnumName [

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
FamixCImporterModelTest >> testEnumSourceAnchor [

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
		equals: 3.
	self
		assert: importer model allEnums anyOne sourceAnchor endPos
		equals: 49
]

{ #category : 'tests - enum' }
FamixCImporterModelTest >> testEnumValues [

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
FamixCImporterModelTest >> testEnumValuesSourceAnchor [

	| sourceCode |
	sourceCode := '
	enum Color {
    	RED
	}
	'.

	importer importFromString: sourceCode.

	self
		assert: importer model allEnumValues anyOne sourceAnchor startPos
		equals: 21.
	self
		assert: importer model allEnumValues anyOne sourceAnchor endPos
		equals: 23
]

{ #category : 'tests - enum' }
FamixCImporterModelTest >> testEnumWithTypedef [

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
FamixCImporterModelTest >> testFunctionDeclarationWithoutDefinition [

	| sourceCode |
	
	sourceCode := '
	int myFunc();
	'.
	
	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1
]

{ #category : 'tests - functions' }
FamixCImporterModelTest >> testFunctionDefinitionAndDeclarationAddedTwoTimes [

	| sourceCode |
	sourceCode := '
	int func();
	int func(){
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne name equals: 'func'.
	self assert: importer model allFunctions anyOne declaredType name equals: 'int'
]

{ #category : 'tests - type' }
FamixCImporterModelTest >> testFunctionDefinitionReturnType [

	| sourceCode |
	sourceCode := '
	void func(){
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert:
		importer model allFunctions anyOne declaredType isPrimitiveType.
	self
		assert: importer model allFunctions anyOne declaredType name
		equals: 'void'
]

{ #category : 'tests - functions' }
FamixCImporterModelTest >> testFunctionDefinitionWithoutDeclaration [

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
FamixCImporterModelTest >> testFunctionIdentifierStartEndPosition [

	| sourceCode |
	sourceCode := 'void func(){}'. "this function starts at index 0 and ends at 13"

	importer importFromString: sourceCode.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne sourceAnchor isNotNil.
	self
		assert: importer model allFunctions anyOne sourceAnchor startPos
		equals: 1.
	self
		assert: importer model allFunctions anyOne sourceAnchor endPos
		equals: 13
]

{ #category : 'tests - invocations' }
FamixCImporterModelTest >> testFunctionInvocationResolution [

	| sourceCode invocation |
	sourceCode := '
	void func();
	int main(){
		func();
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	invocation := (importer model allWithType:
		               FamixCDereferencedInvocation) anyOne.

	self assert: invocation candidates first class equals: FamixCFunction 
]

{ #category : 'tests - invocations' }
FamixCImporterModelTest >> testFunctionInvocationSignature [

	| sourceCode invocation |
	sourceCode := '
	void func();
	int main(){
		func();
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	invocation := (importer model allWithType:
		               FamixCDereferencedInvocation) anyOne.

	self assert: invocation signature equals: 'func()'
]

{ #category : 'tests - invocations' }
FamixCImporterModelTest >> testFunctionOutgoingInvocations [

	| sourceCode invocation |
	sourceCode := '
	void func();
	int main(){
		func();
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	invocation := (self
		               entityNamed: 'main'
		               in: importer model allFunctions) outgoingInvocations
		              anyOne.
	
	self assert: invocation signature equals: 'func()'
]

{ #category : 'tests - type' }
FamixCImporterModelTest >> testFunctionPrototypeAndDefinitionReturnType [

	| sourceCode |
	sourceCode := '
	void func();
	void func(){}
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allFunctions allSatisfy: [ :each |
	each declaredType name = 'void' ])
]

{ #category : 'tests - type' }
FamixCImporterModelTest >> testFunctionPrototypeReturnType [

	| sourceCode |
	sourceCode := '
	void func();
	'.

	importer importFromString: sourceCode.
	
	self
		assert: importer model allFunctions anyOne declaredType name
		equals: 'void'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableAccessMultipleFunction [

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
FamixCImporterModelTest >> testLocalVariableArray [

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
FamixCImporterModelTest >> testLocalVariableArrayVariableLength [

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
FamixCImporterModelTest >> testLocalVariableName [

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
FamixCImporterModelTest >> testLocalVariableParentFunction [

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
FamixCImporterModelTest >> testLocalVariablePointer [

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

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableReadAccessInArgumentList [

	| sourceCode readAccesses |
	sourceCode := '
	void fn(int param1, int param2){};
	void parentFunction(){
	   int a = 1;
	   int b = 2;
		fn(a, b);
	}
	'.

	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 2.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert:
		(readAccesses anySatisfy: [ :access | access variable name = 'a' ]).
	self assert:
		(readAccesses anySatisfy: [ :access | access variable name = 'b' ])
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableReadAccessInAssignmentExpression [

	| sourceCode readAccesses |
	sourceCode := '
	int parentFunction(){
		int a, b;
		a = b;
		return 0;
	}
	'.

	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 1.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: readAccesses anyOne variable name equals: 'b'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableReadAccessInBinaryExpression [

	| sourceCode readAccesses |
	sourceCode := '
	int parentFunction(){
		int a;
		int b = 3 + a + 1; //here
		if(a<1){} //here
		return 0;
	}
	'.

	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 2.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: readAccesses anyOne variable name equals: 'a'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableReadAccessInComplexReturnSttmnt [

	| sourceCode readAccesses |
	sourceCode := '
	void parentFunction(){
	   int a = 1;
		return func1(func2(3 + a + 1, 3)) + 2;
	}
	'.
	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 1.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: readAccesses anyOne variable name equals: 'a'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableReadAccessInReturnSttmnt [

	| sourceCode readAccesses |
	sourceCode := '
	void parentFunction(){
	   int a = 1;
		return a;
	}
	'.

	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 1.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: readAccesses anyOne variable name equals: 'a'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableReadAccessParenthesizedExpression [

	| sourceCode readAccesses |
	sourceCode := '
	int parentFunction(){
		int b = 3;
		if(b){}
	}
	'.

	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 1.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: readAccesses anyOne variable name equals: 'b'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableReadAccessPointer [

	| sourceCode readAccesses |
	sourceCode := '
	int parentFunction(){
		int *a;
		int b;
		a = &b;
		return 0;
	}
	'.

	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 1.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: readAccesses anyOne variable name equals: 'b'
]

{ #category : 'tests - local variables' }
FamixCImporterModelTest >> testLocalVariableSkipFileScopeVariable [

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
FamixCImporterModelTest >> testLocalVariableSourceAnchor [
	
	| sourceCode |
	sourceCode := '
	int fn(){
		int aLocalVar; //this local variable declaration starts at index 14 and ends at 28
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables first sourceAnchor startPos equals: 15.
	self assert: importer model allLocalVariables first sourceAnchor endPos equals: 28.
]

{ #category : 'tests - type' }
FamixCImporterModelTest >> testLocalVariableType [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int aLocalVar;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self
		assert: importer model allLocalVariables anyOne declaredType name
		equals: 'int'
]

{ #category : 'tests - type' }
FamixCImporterModelTest >> testLocalVariableTypeAnonymousStruct [

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
		assert: importer model allLocalVariables anyOne declaredType
		equals: (importer model allWithType: FamixCStruct) anyOne
]

{ #category : 'tests - type' }
FamixCImporterModelTest >> testLocalVariableTypeStruct [

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
		assert: importer model allLocalVariables anyOne declaredType class
		equals: FamixCStruct.
	self
		assert: importer model allLocalVariables anyOne declaredType name
		equals: 'Person'
]

{ #category : 'tests - type' }
FamixCImporterModelTest >> testLocalVariableTypeTypedef [

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
		assert: importer model allLocalVariables anyOne declaredType name
		equals: 'Integer'.
	self flag: 'TODO: test aliased type resolution'
]

{ #category : 'tests - local variables' }
FamixCImporterModelTest >> testLocalVariableWithInitDeclarator [

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

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableWriteAccess [

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
	self assert: importer model allAccesses anyOne isWrite.
	self
		assert: importer model allAccesses anyOne accessor name
		equals: 'parentFunction'.
	self
		assert: importer model allAccesses anyOne variable name
		equals: 'a'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableWriteAccessArray [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a[5];
		a[0] = 3; 
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allAccesses size equals: 1.
	self assert: importer model allAccesses anyOne accessor isFunction.
	self assert: importer model allAccesses anyOne isWrite.
	self
		assert: importer model allAccesses anyOne accessor name
		equals: 'parentFunction'.
	self
		assert: importer model allAccesses anyOne variable name
		equals: 'a'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableWriteAccessField [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		struct Point { int x; int y; };
		struct Point a;
		a.x = 100; 
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allAccesses size equals: 1.
	self assert: importer model allAccesses anyOne isWrite.
	self assert: importer model allAccesses anyOne accessor isFunction.
	self
		assert: importer model allAccesses anyOne accessor name
		equals: 'parentFunction'.
	self
		assert: importer model allAccesses anyOne variable name
		equals: 'a'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableWriteAccessIncrement [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a;
		a++; 
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allAccesses size equals: 1.
	self assert: importer model allAccesses anyOne isWrite.
	self assert: importer model allAccesses anyOne accessor isFunction.
	self
		assert: importer model allAccesses anyOne accessor name
		equals: 'parentFunction'.
	self
		assert: importer model allAccesses anyOne variable name
		equals: 'a'
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableWriteAccessOneLine [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a, b;
		a = b = 3; 
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allAccesses size equals: 2.
	self assert: importer model allAccesses anyOne accessor isFunction.
	self assert: (importer model allAccesses allSatisfy: [ :each | each isWrite ]).
	self
		assert: importer model allAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: (importer model allAccesses anySatisfy: [ :each |
			 each variable name = 'a' ]).
	self assert: (importer model allAccesses anySatisfy: [ :each |
			 each variable name = 'b' ])
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testLocalVariableWriteAccessSourceAnchor [

	| sourceCode |
	sourceCode := '
	int fn(){
		int a;
		a = 3; 
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self
		assert: importer model allAccesses anyOne variable name
		equals: 'a'.
	self assert: importer model allAccesses anyOne isWrite.
	self
		assert: importer model allAccesses anyOne sourceAnchor startPos
		equals: 24.
	self
		assert: importer model allAccesses anyOne sourceAnchor endPos
		equals: 28
]

{ #category : 'tests - local variables' }
FamixCImporterModelTest >> testNestedLocalVariable [

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
FamixCImporterModelTest >> testOneLineMultipleDeclaration [

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
FamixCImporterModelTest >> testOneLineMultipleDeclarationAndInitialization [

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
FamixCImporterModelTest >> testOneLineMultipleDeclarationType [

	| sourceCode |
	sourceCode := '
	int parentFunction(){
		int a, b;
		return 0;
	}
	'.

	importer importFromString: sourceCode.

	self assert: importer model allLocalVariables size equals: 2.

	self assert: (importer model allLocalVariables allSatisfy: [ :each |
			 each declaredType name = 'int' ]).
		
	self assert: (importer model allLocalVariables allSatisfy: [ :each |
			 each declaredType isPrimitiveType ])
]

{ #category : 'tests - parameters' }
FamixCImporterModelTest >> testParamSourceAnchor [

	| sourceCode |
	sourceCode := 'int func(int param1);'. "the parameter declaration starts at 9 and ends at 19"

	importer importFromString: sourceCode.

	self
		assert: importer model allParameters anyOne sourceAnchor startPos
		equals: 10.
	self
		assert: importer model allParameters anyOne sourceAnchor endPos
		equals: 19
]

{ #category : 'tests - parameters' }
FamixCImporterModelTest >> testParameterAddedTwoTimesWithFunctionDeclarationAndDefinition [
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
FamixCImporterModelTest >> testParameterName [

	| sourceCode |
	sourceCode := '
	int myFunc(int arg1);
	'.

	importer importFromString: sourceCode.

	self assert: importer model allParameters size equals: 1.
	self assert: importer model allParameters anyOne name equals: 'arg1'
]

{ #category : 'tests - parameters' }
FamixCImporterModelTest >> testParameterNameWithFunction [

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
FamixCImporterModelTest >> testParameterParentFunction [

	| sourceCode |
	sourceCode := '
	int myFunc(int arg1, int arg2);
	'.

	importer importFromString: sourceCode.
	importer model allParameters do: [ :param |
		self assert: param parentBehaviouralEntity isFunction.
		self assert: param parentBehaviouralEntity name equals: 'myFunc' ]
]

{ #category : 'tests - accesses' }
FamixCImporterModelTest >> testParameterReadAccess [

	| sourceCode readAccesses |
	sourceCode := '
	int parentFunction(int a){
		int b = a + 1;
		return 0;
	}
	'.

	importer importFromString: sourceCode.
	readAccesses := importer model allAccesses select: [ :each |
		                each isRead ].
	self assert: readAccesses size equals: 1.
	self assert: readAccesses anyOne accessor isFunction.
	self
		assert: readAccesses anyOne accessor name
		equals: 'parentFunction'.
	self assert: readAccesses anyOne variable name equals: 'a'
]

{ #category : 'tests - parameters' }
FamixCImporterModelTest >> testParameterType [

	| sourceCode params|
	sourceCode := '
	struct Person { int a };
	typedef struct { int x; int y } Point;
	int myFunc(int arg1, struct Person arg2, Point arg3);
	'.

	importer importFromString: sourceCode.
	params := importer model allParameters.
	
	self assert: params first declaredType name equals: 'int'.
	self assert: params second declaredType name equals: 'Person'.
	self assert: params third declaredType name equals: 'Point'.
]

{ #category : 'tests - parameters' }
FamixCImporterModelTest >> testParametersWithTheSameNameButInDifferentFunction [

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
FamixCImporterModelTest >> testParseStringReturnsATSNode [

	| rootNode |
	rootNode := importer parseString: 'int maint(){}'.
	self assert: rootNode class equals: TSNode.
	self assert: rootNode type equals: 'translation_unit'
]

{ #category : 'tests - functions' }
FamixCImporterModelTest >> testPreprocInclude [

	| sourceCode includes |
	sourceCode := '
	#include <stdio.h>
	#include "functions.h"
	'.

	importer importFromString: sourceCode.
	includes := importer model allWithType: FamixCPreprocInclude.

	self assert: includes size equals: 2.
	self deny: includes first isLocal.
	self assert: includes last isLocal.
	self assertProperty: #path of: includes first equals: '<stdio.h>'.
	
	self assertProperty: #path of: includes second equals: 'functions.h'
]

{ #category : 'tests - primitives' }
FamixCImporterModelTest >> testPrimitiveType [

	| sourceCode |
	sourceCode := '
	struct Point {
    float x;
    float y;
	};
	void main(){
		int a;
		double b;
	}
	'.

	importer importFromString: sourceCode.

	self
		assert: (importer model allPrimitiveTypes ) size
		equals: 4.
]

{ #category : 'tests - struct' }
FamixCImporterModelTest >> testSkipStructTypeFieldAsStructEntity [

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
FamixCImporterModelTest >> testSkipUnionTypeFieldAsUnionEntity [

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
FamixCImporterModelTest >> testStructFieldAnonymousStruct [

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
FamixCImporterModelTest >> testStructFieldArray [

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
FamixCImporterModelTest >> testStructFieldName [

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
FamixCImporterModelTest >> testStructFieldParent [

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
FamixCImporterModelTest >> testStructFieldPointer [

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
FamixCImporterModelTest >> testStructFieldStruct [

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
FamixCImporterModelTest >> testStructFieldType [

	| sourceCode |
	sourceCode := '
	struct Person{int id};
	'.

	importer importFromString: sourceCode.

	self assert:
		(importer model allWithType: FamixCAttribute) anyOne declaredType
			isPrimitiveType.
	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne declaredType
			name
		equals: 'int'
]

{ #category : 'tests - struct' }
FamixCImporterModelTest >> testStructMultipleFieldInOneLine [

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
FamixCImporterModelTest >> testStructMultipleFieldInOneLineType [

	| sourceCode |
	sourceCode := '
	struct Person{int a, b;};
	'.

	importer importFromString: sourceCode.


	self assert:
		((importer model allWithType: FamixCAttribute) allSatisfy: [ :each |
			 each declaredType name = 'int' ])
]

{ #category : 'tests - struct' }
FamixCImporterModelTest >> testStructName [

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
FamixCImporterModelTest >> testStructSourceAnchor [

	| sourceCode |
	sourceCode := 'struct Person{int id};'.

	importer importFromString: sourceCode.

	self
		assert:
			(importer model allWithType: FamixCStruct) anyOne sourceAnchor
				startPos
		equals: 1.
	self
		assert:
		(importer model allWithType: FamixCStruct) anyOne sourceAnchor
			endPos
		equals: 21
]

{ #category : 'tests - struct' }
FamixCImporterModelTest >> testStructTypeVarExcludedFromModel [

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
FamixCImporterModelTest >> testTypedefForAnonymousStruct [

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
FamixCImporterModelTest >> testTypedefForArray [

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
FamixCImporterModelTest >> testTypedefForPointer [

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
FamixCImporterModelTest >> testTypedefForStruct [

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
		equals: 'Person'.
	self
		assert:
		(importer model allWithType: FamixCAliasType) first aliasedType
			class
		equals: FamixCStruct
]

{ #category : 'tests - typedef' }
FamixCImporterModelTest >> testTypedefLongLong [

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
FamixCImporterModelTest >> testTypedefName [

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
FamixCImporterModelTest >> testTypedefResolution [

	| sourceCode |
	sourceCode := '
	typedef int Integer;
	'.

	importer importFromString: sourceCode.
	self
		assert:
		(importer model allWithType: FamixCAliasType) anyOne aliasedType
			class
		equals: FamixCPrimitiveType.
	self
		assert:
		(importer model allWithType: FamixCAliasType) anyOne aliasedType
			name
		equals: 'int'.
	self
		assert: importer model allPrimitiveTypes anyOne typeAliases size
		equals: 1.
	self
		assert:
		importer model allPrimitiveTypes anyOne typeAliases first name
		equals: 'Integer'
]

{ #category : 'tests - typedef' }
FamixCImporterModelTest >> testTypedefResolutionAnonymousStruct [

	| sourceCode |
	sourceCode := '
	typedef struct { int a; int b } myStruct;
	'.

	importer importFromString: sourceCode.
	self
		assert:
		(importer model allWithType: FamixCAliasType) first aliasedType
			class
		equals: FamixCStruct.
	self
		assert:
		(importer model allWithType: FamixCAliasType) first aliasedType
			name
		equals: ''.
	self
		assert: (importer model allWithType: FamixCStruct) first typeAliases size
		equals: 1.
	self
		assert:
		(importer model allWithType: FamixCStruct) first typeAliases first name
		equals: 'myStruct'
]

{ #category : 'tests - typedef' }
FamixCImporterModelTest >> testTypedefSourceAnchor [

	| sourceCode |
	"              0                  20"
	"              |                  |"
	sourceCode := 'typedef int Integer;'.

	importer importFromString: sourceCode.

	self
		assert:
			(importer model allWithType: FamixCAliasType) anyOne sourceAnchor
				startPos
		equals: 1.
	self
		assert:
		(importer model allWithType: FamixCAliasType) anyOne sourceAnchor
			endPos
		equals: 20
]

{ #category : 'tests - union' }
FamixCImporterModelTest >> testUnionFieldAnonymousUnion [

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
FamixCImporterModelTest >> testUnionFieldArray [

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
FamixCImporterModelTest >> testUnionFieldName [

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
FamixCImporterModelTest >> testUnionFieldParent [

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
FamixCImporterModelTest >> testUnionFieldPointer [

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
FamixCImporterModelTest >> testUnionFieldType [

	| sourceCode |
	sourceCode := '
	union Person{int id};
	'.

	importer importFromString: sourceCode.
	self
		assert:
		(importer model allWithType: FamixCAttribute) anyOne declaredType
			name
		equals: 'int'
]

{ #category : 'tests - union' }
FamixCImporterModelTest >> testUnionFieldUnion [

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
FamixCImporterModelTest >> testUnionMultipleFieldInOneLine [

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
FamixCImporterModelTest >> testUnionName [

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
FamixCImporterModelTest >> testUnionSourceAnchor [

	| sourceCode |
	sourceCode := 'union Person{int id};'.

	importer importFromString: sourceCode.

	self
		assert:
			(importer model allWithType: FamixCUnion) anyOne sourceAnchor
				startPos
		equals: 1.
	self
		assert:
		(importer model allWithType: FamixCUnion) anyOne sourceAnchor
			endPos
		equals: 20
]

{ #category : 'tests - union' }
FamixCImporterModelTest >> testUnionTypeVarExcludedFromModel [

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
FamixCImporterModelTest >> testUsingEnum [

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
