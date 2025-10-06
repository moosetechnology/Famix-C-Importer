"
this is the visitor (2)
"
Class {
	#name : 'FamixCVisitor',
	#superclass : 'FamixTSAbstractVisitor',
	#instVars : [
		'context',
		'inDeclaration'
	],
	#category : 'Famix-C-Importer',
	#package : 'Famix-C-Importer'
}

{ #category : 'as yet unclassified' }
FamixCVisitor class >> cPrimitiveTypes [

	^ #(
		'_Bool'
		'_Complex'
		'char'
		'double'
		'double _Complex'
		'float'
		'float _Complex'
		'int'
		'long'
		'long double'
		'long double _Complex'
		'long int'
		'long long'
		'long long int'
		'short'
		'short int'
		'signed'
		'signed char'
		'signed int'
		'signed long'
		'signed long int'
		'signed long long'
		'signed long long int'
		'signed short'
		'signed short int'
		'unsigned'
		'unsigned char'
		'unsigned int'
		'unsigned long'
		'unsigned long int'
		'unsigned long long'
		'unsigned long long int'
		'unsigned short'
		'unsigned short int'
		'void'
	)
]

{ #category : 'as yet unclassified' }
FamixCVisitor class >> notPrimitiveTypes [
	"tree-sitter considers these as primitive types but they are not in reality.
	They may be typedef defined in the standard library or compiler specific
	"
	self flag: 'TODO'. "to be completed"
	^ #( 
		'uint8_t' 
		'uint16_t' 
		'uint32_t' 
		'uint64_t' 
		'intptr_t' 
		'uintptr_t'
		)
]

{ #category : 'as yet unclassified' }
FamixCVisitor >> allHeaderFiles [

	^ model allWithType: FamixCHeaderFile
]

{ #category : 'as yet unclassified' }
FamixCVisitor >> assignTypeTo: aFamixCTypedEntity with: aStringOrType [
	"this is only used on the first walk of the AST"

	aStringOrType isString
		ifTrue: [
				self
					resolve: ((SRIdentifierWithNode identifier: aStringOrType)
							 expectedKind: FamixCType;
							 notFoundReplacementEntity: [ :unresolved |
									 (model newTypeNamed: aStringOrType)
										 isStub: true;
										 yourself ];
							 yourself)
					foundAction: [ :type :currentEntity | aFamixCTypedEntity typing: (self newEntityTypingFor: type) ] ]
		ifFalse: [ "sometimes when the type of the entity is an anonymous structural entity like struct or union so we need to directly assign it to the entity. Moreover this type is only used there.
			e.g:
			```
					struct Person{ 
						char name[];
						struct { // this
							int streetNo;
							char city[];
						 } address;
					 };
			```
				
			"
			aFamixCTypedEntity typing: (self newEntityTypingFor: aStringOrType) ]
]

{ #category : 'private' }
FamixCVisitor >> checkIfPrimitiveType: aString [

	^ (self primitiveTypeParts includesAll: (Character space split: aString))
		  ifTrue: [ self ensurePrimitiveTypeExist: aString ]
		  ifFalse: [ aString ]
]

{ #category : 'accessing' }
FamixCVisitor >> context [

	^ context
]

{ #category : 'accessing' }
FamixCVisitor >> context: anObject [

	context := anObject
]

{ #category : 'private-entity-creation' }
FamixCVisitor >> createDereferencedInvocation: aTSNode [

	| invocation |
	invocation := FamixCDereferencedInvocation new
		              signature: aTSNode sourceText;
		              sender: self currentEntity.

	self setSourceAnchor: invocation from: aTSNode.

	model add: invocation.

	self
		resolve: ((SRIdentifierResolvable identifier: aTSNode _function sourceText)
				 expectedKind: FamixCFunction;
				 notFoundReplacementEntity: [ :unresolved |self createStubFunctionFrom: aTSNode _function sourceText];
				 yourself)
		foundAction: [ :function :currentEntity | invocation addCandidate: function ].

	^ invocation
]

{ #category : 'accessing' }
FamixCVisitor >> createReadAccessIfVariableTo: aVariableName from: aTSNode [

	 aVariableName isString ifTrue: [
		^ self createReadAccessTo: aVariableName from: aTSNode ].
	^ nil
]

{ #category : 'private-entity-creation' }
FamixCVisitor >> createReadAccessTo: variableName from: aTSNode [

	| access |
	access := model newAccess
		          accessor: self currentEntity;
		          isWrite: false;
		          in: [ :access | self setSourceAnchor: access from: aTSNode ];
		          yourself.
		
	self resolveAccessOf: variableName foundAction: [ :variable :currentEntity | access variable: variable ].

	^ access
]

{ #category : 'accessing' }
FamixCVisitor >> createStubFunctionFrom: aString [

	^ (model newFunctionNamed: aString)
		  isStub: true;
		  yourself
]

{ #category : 'private' }
FamixCVisitor >> createStubHeaderFileFrom: aPath [

	^ (model newHeaderFileNamed: aPath)
		  isStub: true;
		  yourself
]

{ #category : 'private-entity-creation' }
FamixCVisitor >> createWriteAccessTo: variableName from: anAssignmentNode [

	| access |
	access := model newAccess
		          accessor: self currentEntity;
		          isWrite: true;
		          in: [ :access | self setSourceAnchor: access from: anAssignmentNode ];
		          yourself.
		
	self resolveAccessOf: variableName foundAction: [ :variable :currentEntity | access variable: variable ].

	^ access
]

{ #category : 'accessing' }
FamixCVisitor >> detect: aFamixCEntity name: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ nil ]
]

{ #category : 'visiting' }
FamixCVisitor >> ensureAsOrderedCollection: anObject [

	^ anObject class = OrderedCollection
		  ifTrue: [ anObject ]
		  ifFalse: [
				  OrderedCollection new
					  add: anObject;
					  yourself ]
]

{ #category : 'visiting' }
FamixCVisitor >> ensureEntityExist: aFamixCEntity name: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ model add: (aFamixCEntity new name: aString) ]
]

{ #category : 'as yet unclassified' }
FamixCVisitor >> ensurePrimitiveTypeExist: aString [

	^ self ensureEntityExist: FamixCPrimitiveType name: aString
]

{ #category : 'private' }
FamixCVisitor >> ensureStubHeaderFileFrom: aPath [

	self flag: #todo. "Manage paths"
	^ (model allWithType: FamixCHeaderFile) detect: [ :header | header isStub and: [ header name = aPath ] ] ifNone: [ self createStubHeaderFileFrom: aPath ]
]

{ #category : 'accessing' }
FamixCVisitor >> entityNamed: aName in: aCollection [

	^ aCollection detect: [ :each | each name = aName ] ifNone: [ nil ]
]

{ #category : 'accessing' }
FamixCVisitor >> inFunctionContext [

	self withCurrentEntityDo: [ :entity |
		^ entity class = FamixCFunction ].
	^ false
]

{ #category : 'initialization' }
FamixCVisitor >> initialize [

	super initialize.

	inDeclaration := false
]

{ #category : 'accessing' }
FamixCVisitor >> isLocalLib: aTSNode [

	^ aTSNode type ~= 'system_lib_string'
]

{ #category : 'accessing' }
FamixCVisitor >> isPrimitiveType: aString [

	aString isString ifFalse: [ ^ false ].
	
	self class cPrimitiveTypes
		detect: [ :type | type = aString ]
		ifFound: [ ^ true ]
		ifNone: [ ^ false ]
]

{ #category : 'accessing' }
FamixCVisitor >> isReadAccess: aTSNode [

	(aTSNode isInField: #arguments ofParentOfType: #call_expression) ifTrue: [ ^ true ].


	aTSNode parentsDo: [ :parentNode |
			parentNode type = #call_expression ifTrue: [ ^ false ].

			(#( binary_expression argument_list parenthesized_expression return_statement ) includes: parentNode type) ifTrue: [
				^ parentNode includesChild: aTSNode ].

			"only true if the identifier is on right side of an assignement otherWise it is a write access"
			parentNode type = 'assignment_expression' ifTrue: [
				(parentNode _right = aTSNode or: [ parentNode _right includesChild: aTSNode ]) ifTrue: [ ^ true ] ].

			parentNode type = 'init_declarator' ifTrue: [ parentNode _value = aTSNode ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : 'accessing' }
FamixCVisitor >> model [

	^ model
]

{ #category : 'accessing' }
FamixCVisitor >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
FamixCVisitor >> modelClass [

	^ FamixCModel
]

{ #category : 'accessing' }
FamixCVisitor >> newEntityTypingFor: aFamixCTypeEntity [

	^ model newEntityTyping
		  declaredType: aFamixCTypeEntity;
		  yourself
]

{ #category : 'accessing' }
FamixCVisitor >> newNamedVariable: aString isLocal: aBoolean [

	^ aBoolean
		  ifTrue: [ (model newLocalVariableNamed: aString) parentBehaviouralEntity: self currentEntity ]
		  ifFalse: [ (model newGlobalVariableNamed: aString) parentScope: self currentEntity ]
]

{ #category : 'instance creation' }
FamixCVisitor >> newPreprocCompilationUnit: aFileReference [

	^ self newPreprocFile: FamixCCompilationUnit with: aFileReference
]

{ #category : 'accessing' }
FamixCVisitor >> newPreprocFile: aClass with: aFileReference [

	^ model add: (aClass new name: (self relativePath: aFileReference))
]

{ #category : 'instance creation' }
FamixCVisitor >> newPreprocHeaderFile: aFileReference [

	^ model newHeaderFileNamed: aFileReference basename
]

{ #category : 'initialization' }
FamixCVisitor >> primitiveTypeParts [

	^ { 'bool'. 'char'. 'signed'. 'unsigned'. 'short'. 'int'. 'long'. 'float'. 'double' }
]

{ #category : 'accessing' }
FamixCVisitor >> relativePath: aFileReference [

	^ (aFileReference relativeTo: model rootFolder asFileReference)
		  pathString
]

{ #category : 'as yet unclassified' }
FamixCVisitor >> resolveAccessOf: identifier foundAction: aBlockClosure [
self
		resolve: ((SRIdentifierResolvable identifier: identifier )
				 expectedKind: {
						 FamixCLocalVariable.
							FamixCParameter.
						 FamixCGlobalVariable };
				 notFoundReplacementEntity: [ :unresolved :currentEntity | "we will look among the global variables or create a stub if not found"
						 | globalVar |
						 model allGlobalVariables
							 detect: [ :each | each name = unresolved identifier ]
							 ifFound: [ :found | globalVar := found ]
							 ifNone: [ 1 halt "create globalVar stub" ].
						 globalVar ];
				 yourself)
		foundAction: aBlockClosure.
]

{ #category : 'visiting' }
FamixCVisitor >> visitArgumentList: aTSNode [
	"<unnamedChild>"

	self visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitArrayDeclarator: aTSNode [
	"declarator size"

	| arrName |
	
	self visit: aTSNode _size.
	arrName := self visit: aTSNode _declarator.
	
	arrName isString
		ifTrue: [ ^ arrName ]
		ifFalse: [ ^ arrName first ]
]

{ #category : 'visiting' }
FamixCVisitor >> visitAssignmentExpression: aTSNode [
	"left right"

	| left |
	
	left := self visit: aTSNode _left.
	self createWriteAccessTo: left from: aTSNode.
	
	self visit: aTSNode _right
]

{ #category : 'visiting' }
FamixCVisitor >> visitBinaryExpression: aTSNode [
	"left right"

	self visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitCallExpression: aTSNode [
	"function arguments"

	| invocation fnName |
	invocation := self createDereferencedInvocation: aTSNode.
	fnName := self visit: aTSNode _function.
	invocation attributeAt: #name put: fnName.
	self visit: aTSNode _arguments
]

{ #category : 'private - transcript cleaning' }
FamixCVisitor >> visitCompoundStatement: aTSNode [

	^ self visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitDeclaration: aTSNode [
	"type declarator"

	| declaratorVisitResult |
	inDeclaration := true.

	declaratorVisitResult := self visit: aTSNode _declarator.

	declaratorVisitResult class = FamixCFunction
		ifTrue: [
		self useCurrentEntity: declaratorVisitResult during: [ self assignTypeTo: declaratorVisitResult with: (self visit: aTSNode _type) ] ]
		ifFalse: [
				| identifiers |
				identifiers := self ensureAsOrderedCollection: declaratorVisitResult.

				identifiers do: [ :eachIdentifier |
						| varEntity |
						varEntity := self newNamedVariable: eachIdentifier isLocal: self currentEntity isFunction.

						self setSourceAnchor: varEntity from: aTSNode.
						self assignTypeTo: varEntity with: (self visit: aTSNode _type) ] ].





	inDeclaration := false
]

{ #category : 'visiting' }
FamixCVisitor >> visitEnumSpecifier: aTSNode [
	"name body"

	| enumEntity enumName enumAsAttributeType |
	enumName := ''.
	aTSNode _name ifNotNil: [ enumName := aTSNode _name sourceText ].


	aTSNode _body
		ifNotNil: [
				enumEntity := FamixCEnum new name: enumName.
				self setSourceAnchor: enumEntity from: aTSNode.
				model add: enumEntity.

				"parent type resolution"
				(self hasCurrentEntity and: [
					 self currentEntity class = FamixCAliasType ]) ifTrue: [
					self currentEntity aliasedType: enumEntity ].

				enumAsAttributeType := self hasCurrentEntity and: [
					                       self currentEntity isAttribute ].
				enumAsAttributeType | inDeclaration ifTrue: [
					self assignTypeTo: self currentEntity with: enumEntity ].
				self
					useCurrentEntity: enumEntity
					during: [ self visit: aTSNode _body ] ]
		ifNil: [
				enumEntity := self detect: FamixCEnum name: enumName.
				enumEntity ifNotNil: [
					self assignTypeTo: self currentEntity with: enumEntity ] ].


	^ enumEntity
]

{ #category : 'visiting' }
FamixCVisitor >> visitEnumerator: aTSNode [
	"tokony hisy value eto fa tsy name ihany"

	| enumValueEntity |
	enumValueEntity := (model newEnumValueNamed:
			                    (self visit: aTSNode _name))
		                   parentEnum: self currentEntity;
		                   yourself.
	self setSourceAnchor: enumValueEntity from: aTSNode.

	^ enumValueEntity
]

{ #category : 'private - transcript cleaning' }
FamixCVisitor >> visitExpressionStatement: aTSNode [

	^ super visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitFieldDeclaration: aTSNode [
	"type declarator"

	| fieldDelcarationEntity type |
	aTSNode _declarator
		ifNotNil: [
				| fieldsName |
				fieldsName := self ensureAsOrderedCollection: (self visit: aTSNode _declarator). "this might return a FamixCFunction"

				fieldsName do: [ :eachName |
						eachName isString ifTrue: [
								self flag: 'skip function as attribute'.
								"for now I skip the field which is a function declartor,
							they can be represented as an association between the structure 
							and the function but the current meta-model does not support this as far as I know
							"

								fieldDelcarationEntity := model newAttribute
									                          name: eachName;
									                          parentType: self currentEntity.

								self setSourceAnchor: fieldDelcarationEntity from: aTSNode.
								type := self visit: aTSNode _type.
								self assignTypeTo: fieldDelcarationEntity with: type ] ] ]
		ifNil: [ "this field declaration node is an anonymous struct and doesn't have field_identifier" self visit: aTSNode _type ]
]

{ #category : 'private - transcript cleaning' }
FamixCVisitor >> visitFieldDeclarationList: aTSNode [

	^ super visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitFieldExpression: aTSNode [
	"field argument"

	^ self visit: aTSNode _argument
]

{ #category : 'visiting' }
FamixCVisitor >> visitFieldIdentifier: aTSNode [ 
	"no fields"

	^ aTSNode sourceText 
]

{ #category : 'visiting' }
FamixCVisitor >> visitFunctionDeclarator: aTSNode [
	"declarator parameters"

	| fnName fnEntity |
	fnName := aTSNode _declarator sourceText.
	fnEntity := self ensureEntityExist: FamixCFunction name: fnName.
	fnEntity functionOwner: self currentEntity.
	self setSourceAnchor: fnEntity from: aTSNode.

	^ self useCurrentEntity: fnEntity during: [ self visit: aTSNode _parameters ]
]

{ #category : 'visiting' }
FamixCVisitor >> visitFunctionDefinition: aTSNode [
	"type declarator body"

	| fnEntity type |
	type := self visit: aTSNode _type.

	"get the created function entity after visiting the declarator"
	fnEntity := self visit: aTSNode _declarator.

	self setSourceAnchor: fnEntity from: aTSNode.

	self assignTypeTo: fnEntity with: type.

	^ self
		  useCurrentEntity: fnEntity
		  during: [ self visit: aTSNode _body ]
]

{ #category : 'visiting' }
FamixCVisitor >> visitIdentifier: aTSNode [
	"no fields"

	(self isReadAccess: aTSNode) ifTrue: [ self createReadAccessTo: aTSNode sourceText from: aTSNode ].
	^ aTSNode sourceText
]

{ #category : 'visiting' }
FamixCVisitor >> visitInitDeclarator: aTSNode [
	"declarator value"

	self visit: aTSNode _value.
	^ self visit: aTSNode _declarator
]

{ #category : 'private - transcript cleaning' }
FamixCVisitor >> visitNumberLiteral: aTSNode [

	^ super visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitParameterDeclaration: aTSNode [
	"type declarator"

	| paramEntity type |
	aTSNode _type sourceText = 'void' ifTrue: [ ^ self ].
	
	type := self visit: aTSNode _type.
	paramEntity := model newParameterNamed: aTSNode _declarator sourceText.
	paramEntity parentBehaviouralEntity: self currentEntity.

	self setSourceAnchor: paramEntity from: aTSNode.

	self assignTypeTo: paramEntity with: type.

	^ paramEntity
]

{ #category : 'visiting' }
FamixCVisitor >> visitParameterList: aTSNode [
	"<unnamedChild>"

	"(fields at: '<unnamedChild>') is a TSNode instance if there is only one parameter"

	"otherwise it will be an orederedCollection"

	"before visiting all parameters, we need to check if they have already been added to the model from their function prototype"

	self currentEntity parameters ifNotEmpty: [ "parameters already in the model"
		^ self ].

	^ aTSNode collectNamedChild collect: [ :node | self visit: node ]
]

{ #category : 'visiting' }
FamixCVisitor >> visitParenthesizedDeclarator: aTSNode [

	^ self visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitParenthesizedExpression: aTSNode [
	"<unnamedChild>"

	self visitChildren: aTSNode.
]

{ #category : 'visiting' }
FamixCVisitor >> visitPointerDeclarator: aTSNode [

	^ self visit: aTSNode _declarator
]

{ #category : 'visiting' }
FamixCVisitor >> visitPointerExpression: aTSNode [

	^ self visitChildren: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitPreprocInclude: aTSNode [

	| includeEntity path isLocal |
	isLocal := self isLocalLib: aTSNode _path.
	includeEntity := FamixCInclude new
		                 isLocal: isLocal;
		                 includedBy: self currentEntity.

	self flag: #todo. "In case we have a non local import we could directly create and set the stub header file to not resolve something we know is a stub"
	
	self
		resolve: ((FamixCIncludesResolvable path: (self visit: aTSNode _path))
				 notFoundReplacementEntity: [ :unresolved :currentEntity | self ensureStubHeaderFileFrom: unresolved path ];
				 yourself)
		foundAction: [ :entity :currentEntity | includeEntity included: entity ].

	self setSourceAnchor: includeEntity from: aTSNode.
	model add: includeEntity.
	
	^ includeEntity
]

{ #category : 'visiting' }
FamixCVisitor >> visitPrimitiveType: aTSNode [

	self class notPrimitiveTypes 
		detect: [ :each | each = aTSNode sourceText ]
		ifFound: [ ^ aTSNode sourceText ]
		ifNone: [ ^ self ensurePrimitiveTypeExist: aTSNode sourceText ]
]

{ #category : 'private - transcript cleaning' }
FamixCVisitor >> visitReturnStatement: aTSNode [
	"<unnamedChild>"

	^ self visitChildren: aTSNode.
]

{ #category : 'visiting' }
FamixCVisitor >> visitSizedTypeSpecifier: aNode [

	^ self checkIfPrimitiveType: aNode sourceText
]

{ #category : 'visiting' }
FamixCVisitor >> visitStringLiteral: aTSNode [

	| literal |
	literal := ''.
	aTSNode collectNamedChild do: [ :each | literal := literal , each sourceText ].
	
	^ literal
]

{ #category : 'visiting' }
FamixCVisitor >> visitStructSpecifier: aTSNode [
	"name body"

	^ self visitStructuredType: aTSNode type: FamixCStruct
]

{ #category : 'visiting' }
FamixCVisitor >> visitStructuredType: aTSNode type: aFamixCStructuredTypeClass [
	"name body"

	| structuredTypeEntity structuredTypeName isAnonymous asAttributeType asTypedefType |
	isAnonymous := aTSNode _name isNil.

	asAttributeType := false.
	asTypedefType := false.

	self withCurrentEntityDo: [ :entity |
			asAttributeType := entity class inheritsFrom: FamixCStructuredType . "either a struct or union"
			asTypedefType := entity class = FamixCAliasType ].

	(isAnonymous and: [ asAttributeType not and: [ inDeclaration not and: [ asTypedefType not ] ] ]) ifTrue: [ "skip entity creation for this case: 
			 ```
			struct foo { 
				struct {
					int a; // here, a is promoted to outer structure or union
				}
			};
			```
			"
			self visit: aTSNode _body.
			^ nil ].

	structuredTypeName := ''.
	isAnonymous ifFalse: [ structuredTypeName := aTSNode _name sourceText ].

	aTSNode _body
		ifNotNil: [
				structuredTypeEntity := aFamixCStructuredTypeClass named: structuredTypeName.

				self setSourceAnchor: structuredTypeEntity from: aTSNode.
				
				structuredTypeEntity typeContainer: self currentEntity.

				model add: structuredTypeEntity.

				(inDeclaration or: [ asAttributeType ]) ifTrue: [ "self assignTypeTo: self currentEntity with: structuredTypeEntity" ].

				self useCurrentEntity: structuredTypeEntity during: [ self visit: aTSNode _body ].
				
				^ structuredTypeEntity ]
		ifNil: [ ^ structuredTypeName ]
]

{ #category : 'visiting' }
FamixCVisitor >> visitSubscriptExpression: aTSNode [
	"index argument"

	^ self visit: aTSNode _argument
]

{ #category : 'visiting' }
FamixCVisitor >> visitSystemLibString: aNode [

	^ aNode sourceText
]

{ #category : 'private - transcript cleaning' }
FamixCVisitor >> visitTranslationUnit: aTSNode [

	self setSourceAnchor: self currentEntity from: aTSNode.
	super visitChildren: aTSNode.
	FamixCCommentVisitor visitor: self importCommentsOf: aTSNode
]

{ #category : 'visiting' }
FamixCVisitor >> visitTypeDefinition: aTSNode [
	"type declarator"

	| aliasedType typeIdentifiers typedefEntities |
	
	typeIdentifiers := self ensureAsOrderedCollection: aTSNode _declarator. "this may be a collection in the case of a multiple names for one typedef"
	
	typedefEntities := typeIdentifiers collect: [ :each |
			| typedefEntity |
			typedefEntity := model newAliasType 
											name: (self visit: each); 
											typeContainer: self currentEntity.

			self setSourceAnchor: typedefEntity from: aTSNode.
			typedefEntity ].

	self useCurrentEntity: typedefEntities first during: [
			aliasedType := self visit: aTSNode _type.

			aliasedType isString
				ifTrue: [
						aliasedType := self visit: aTSNode _type.
						self
							resolve: ((SRIdentifierResolvable identifier: aliasedType)
									 expectedKind: FamixCType;
									 notFoundReplacementEntity: [ :unresolved :currentEntity | 1 halt ];
									 yourself)
							foundAction: [ :type :currentEntity | typedefEntities do: [ :each | each aliasedType: type ] ] ]
				ifFalse: [ typedefEntities do: [ :each | each aliasedType: aliasedType ] ] ]
]

{ #category : 'visiting' }
FamixCVisitor >> visitTypeIdentifier: aTSNode [ 
	"no fields"
	^ aTSNode sourceText 
]

{ #category : 'visiting' }
FamixCVisitor >> visitUnionSpecifier: aTSNode [
	"name body"

	^ self visitStructuredType: aTSNode type: FamixCUnion
]

{ #category : 'visiting' }
FamixCVisitor >> visitUpdateExpression: aTSNode [ 

	| varName |
	varName := self visit: aTSNode _argument.

	self inFunctionContext ifTrue: [
		self createWriteAccessTo: varName from: aTSNode ].

	^ varName
]
