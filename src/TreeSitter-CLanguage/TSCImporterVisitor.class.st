Class {
	#name : 'TSCImporterVisitor',
	#superclass : 'TSCLanguageVisitor',
	#instVars : [
		'parser',
		'model',
		'context',
		'sourceCode',
		'fileName',
		'inDeclaration'
	],
	#category : 'TreeSitter-CLanguage',
	#package : 'TreeSitter-CLanguage'
}

{ #category : 'importer' }
TSCImporterVisitor >> acceptedExtensions [

	^ #( 'c' 'h' )
]

{ #category : 'accessing' }
TSCImporterVisitor >> context [

	^ context
]

{ #category : 'accessing' }
TSCImporterVisitor >> context: anObject [

	context := anObject
]

{ #category : 'private-entity-creation' }
TSCImporterVisitor >> createDereferencedInvocation: aTSNode [

	^ model add: (FamixCDereferencedInvocation new
			 signature: (aTSNode textFromSourceText: sourceCode);
			 sender: context top)
]

{ #category : 'accessing' }
TSCImporterVisitor >> createReadAccessIfVariableTo: aVariableName from: aTSNode [

	(context isNotEmpty and: [ context top isFunction ]) ifTrue: [
			aVariableName isString ifTrue: [
				^ self createReadAccessTo: aVariableName from: aTSNode ] ].
	^ nil
]

{ #category : 'private-entity-creation' }
TSCImporterVisitor >> createReadAccessTo: variableName from: aTSNode [

	^ model newAccess
		  variable: (self lookupVariable: variableName in: context top);
		  accessor: context top;
		  isWrite: false;
		  sourceAnchor: (self extractSourceAnchor: aTSNode);
		  yourself
]

{ #category : 'private-entity-creation' }
TSCImporterVisitor >> createWriteAccessTo: variable from: anAssignmentNode [

	^ model newAccess
		  variable: variable;
		  accessor: self currentEntity;
		  isWrite: true;
		  sourceAnchor: (self extractSourceAnchor: anAssignmentNode);
		  yourself
]

{ #category : 'accessing' }
TSCImporterVisitor >> currentEntity [

	^ context top
]

{ #category : 'accessing' }
TSCImporterVisitor >> detect: aFamixCEntity name: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ nil ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> ensureAsOrderedCollection: anObject [

	^ anObject class = OrderedCollection
		  ifTrue: [ anObject ]
		  ifFalse: [
				  OrderedCollection new
					  add: anObject;
					  yourself ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> ensureEntityExist: aFamixCEntity name: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ model add: (aFamixCEntity new name: aString) ]
]

{ #category : 'accessing' }
TSCImporterVisitor >> entityNamed: aName in: aCollection [

	^ aCollection detect: [ :each | each name = aName ] ifNone: [ nil ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> extractSourceAnchor: aTSNode [

	^ FamixCIndexedFileAnchor new
		  startPos: aTSNode startByte;
		  endPos: aTSNode endByte;
		  fileName: fileName;
		  mooseModel: model
]

{ #category : 'accessing' }
TSCImporterVisitor >> fileName [

	^ fileName
]

{ #category : 'accessing' }
TSCImporterVisitor >> fileName: anObject [

	fileName := anObject
]

{ #category : 'accessing' }
TSCImporterVisitor >> import: aFileReference [

	aFileReference exists ifFalse: [
		self error: aFileReference fullName , ' does not exist' ].

	aFileReference isFile
		ifTrue: [ self importFromFile: aFileReference ]
		ifFalse: [ self importFromFolder: aFileReference ].

	^ model
]

{ #category : 'importer' }
TSCImporterVisitor >> importFromFile: aFileReference [
	"check if it's a .c or .h file"

	(self acceptedExtensions includes: aFileReference extensions first)
		ifTrue: [
				fileName := aFileReference basename.
				model
					rootFolder: aFileReference parent;
					name: fileName.

				sourceCode := aFileReference contents.

				(self parseString: sourceCode) accept: self.

				^ model ]
		ifFalse: [ self error: 'only .c and .h are accepted' ]
]

{ #category : 'importer' }
TSCImporterVisitor >> importFromFolder: aFileReference [ 
	self shouldBeImplemented.
]

{ #category : 'importer' }
TSCImporterVisitor >> importFromString: aString [

	| rootNode |
	rootNode := self parseString: aString.
	sourceCode := aString.
	fileName := '** Not a file - Imported from a string **'.

	rootNode accept: self.
	
	^ model
]

{ #category : 'accessing' }
TSCImporterVisitor >> inFunctionContext [

	^ context isNotEmpty and: [ context top isFunction ]
]

{ #category : 'initialization' }
TSCImporterVisitor >> initialize [

	super initialize.

	parser := TSParser new.
	parser language: TSLanguage cLang.

	context := Stack new.
	model := FamixCModel new.
	inDeclaration := false.
]

{ #category : 'accessing' }
TSCImporterVisitor >> lookupVariable: aName in: aFamixCFunction [

	^ self entityNamed: aName in: aFamixCFunction localVariables
]

{ #category : 'accessing' }
TSCImporterVisitor >> model [

	^ model
]

{ #category : 'accessing' }
TSCImporterVisitor >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
TSCImporterVisitor >> newEntityTypingFor: aFamixCTypeEntity [

	^ model newEntityTyping
		  declaredType: aFamixCTypeEntity;
		  yourself
]

{ #category : 'parsing' }
TSCImporterVisitor >> parseString: aString [
	"return the source code AST"

	^ (parser parseString: aString) rootNode
]

{ #category : 'accessing' }
TSCImporterVisitor >> sourceCode: anObject [

	sourceCode := anObject
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCArgumentList: aTSNode withFields: fields [
	"<unnamedChild>"

	| argumentList |
	argumentList := self ensureAsOrderedCollection:
		                (self
			                 visitKey: '<unnamedChild>'
			                 inDictionnary: fields).
	argumentList do: [ :eachArgument |
		self createReadAccessIfVariableTo: eachArgument from: aTSNode ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCArrayDeclarator: aTSNode withFields: fields [
	"declarator size"

	self visitKey: 'size' inDictionnary: fields.
	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCAssignmentExpression: aTSNode withFields: fields [
	"left right"

	| left right |
	left := self visitKey: 'left' inDictionnary: fields.
	self inFunctionContext ifTrue: [
			| variable |
			variable := self lookupVariable: left in: context top.
			self createWriteAccessTo: variable from: aTSNode ].


	right := self visitKey: 'right' inDictionnary: fields.
	self createReadAccessIfVariableTo: right from: aTSNode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCBinaryExpression: aTSNode withFields: fields [
	"left right"

	| left right |
	
	left := self visitKey: 'left' inDictionnary: fields.
	self createReadAccessIfVariableTo: left from: aTSNode.

	right := self visitKey: 'right' inDictionnary: fields.
	self createReadAccessIfVariableTo: right from: aTSNode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCCallExpression: aTSNode withFields: fields [
	"function arguments"

	self createDereferencedInvocation: aTSNode.

	^ super visitCCallExpression: aTSNode withFields: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCComment: aTSNode withFields: fields [
	"no fields"

	^ model add:
		  (FamixCComment new sourceAnchor:
			   (self extractSourceAnchor: aTSNode))
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCDeclaration: aTSNode withFields: fields [
	"type declarator"

	inDeclaration := true.
	self flag:
		'TODO: Refactor this to consider global variable once there is FamixCGlobalVariable in the metamodel'.
	"check if it is a declaration inside a function, for local variable"
	(context isNotEmpty and: [ context top isFunction ])
		ifTrue: [
				| identifiersName |
				identifiersName := self ensureAsOrderedCollection:
					                   (self
						                    visitKey: 'declarator'
						                    inDictionnary: fields).

				identifiersName do: [ :eachIdentifierName |
						| localVarEntity |
						localVarEntity := FamixCLocalVariable new
							                  name: eachIdentifierName;
							                  sourceAnchor:
								                  (self extractSourceAnchor: aTSNode);
							                  parentBehaviouralEntity: context top.
						model add: localVarEntity.
						context push: localVarEntity.
						localVarEntity
							attributeAt: #declaredType
							put: (self visitKey: 'type' inDictionnary: fields).
						context pop ] ]
		ifFalse: [
				| entity |
				entity := self visitKey: 'declarator' inDictionnary: fields.
				entity class = FamixCFunction
					ifTrue: [
							entity
								attributeAt: #declaredType
								put: (self visitKey: 'type' inDictionnary: fields) ]
					ifFalse: [ self visitKey: 'type' inDictionnary: fields ] ].



	inDeclaration := false
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCERROR: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCEnumSpecifier: aTSNode withFields: fields [
	"name body"

	| enumEntity enumName enumAsAttributeType |
	enumName := ''.
	(fields includesKey: 'name') ifTrue: [
		enumName := self visitKey: 'name' inDictionnary: fields ].


	(fields includesKey: 'body')
		ifTrue: [
				enumEntity := FamixCEnum new
					              name: enumName;
					              sourceAnchor: (self extractSourceAnchor: aTSNode).
				model add: enumEntity.

				"parent type resolution"
				(context isNotEmpty and: [ context top class = FamixCAliasType ])
					ifTrue: [ context top aliasedType: enumEntity ].

				enumAsAttributeType := context isNotEmpty and: [
					                       context top class = FamixCAttribute ].
				enumAsAttributeType | inDeclaration ifTrue: [
					context top typing: (self newEntityTypingFor: enumEntity) ].

				context push: enumEntity.
				self visitKey: 'body' inDictionnary: fields.
				context pop ]
		ifFalse: [
				enumEntity := self detect: FamixCEnum name: enumName.
				enumEntity ifNotNil: [
					context top typing: (self newEntityTypingFor: enumEntity) ] ].


	^ enumEntity
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCEnumerator: aTSNode withFields: fields [
	"tokony hisy value eto fa tsy name ihany"

	| enumValueEntity |
	enumValueEntity := FamixCEnumValue new
		                   name:
			                   (self visitKey: 'name' inDictionnary: fields);
		                   sourceAnchor: (self extractSourceAnchor: aTSNode);
		                   parentEnum: context top;
		                   yourself.
	model add: enumValueEntity.
	^ enumValueEntity
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFieldDeclaration: aTSNode withFields: fields [
	"type declarator"

	| fieldDelcarationEntity |
	(fields includesKey: 'declarator')
		ifTrue: [
				| fieldsName |
				fieldsName := self ensureAsOrderedCollection:
					              (self visitKey: 'declarator' inDictionnary: fields).

				fieldsName do: [ :eachName |
						fieldDelcarationEntity := model newAttribute
							                          name: eachName;
							                          sourceAnchor:
								                          (self extractSourceAnchor: aTSNode);
							                          parentType: context top.

						context push: fieldDelcarationEntity.
						fieldDelcarationEntity
							attributeAt: #declaredType
							put: (self visitKey: 'type' inDictionnary: fields).
						context pop ] ]
		ifFalse: [ "this field declaration node is an anonymous struct and doesn't have field_identifier"
			self visitKey: 'type' inDictionnary: fields ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFieldExpression: aTSNode withFields: fields [

	self visitKey: 'field' inDictionnary: fields.
	^ self visitKey: 'argument' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFieldIdentifier: aTSNode withFields: fields [
	"no fields"

	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFunctionDeclarator: aTSNode withFields: fields [
	"declarator parameters"

	| fnName fnEntity |
	fnName := self visitKey: 'declarator' inDictionnary: fields.

	fnEntity := self ensureEntityExist: FamixCFunction name: fnName.
	fnEntity sourceAnchor: (self extractSourceAnchor: aTSNode).

	context push: fnEntity.

	self visitKey: 'parameters' inDictionnary: fields.

	^ context pop
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCFunctionDefinition: aTSNode withFields: fields [
	"type declarator body"

	| fnEntity |
	"get the created function entity after visiting the declarator"
	fnEntity := self visitKey: 'declarator' inDictionnary: fields.

	fnEntity sourceAnchor: (self extractSourceAnchor: aTSNode).

	context push: fnEntity.
	fnEntity
		attributeAt: #declaredType
		put: (self visitKey: 'type' inDictionnary: fields).
	self visitKey: 'body' inDictionnary: fields.

	context pop
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCIdentifier: aTSNode withFields: fields [
	"no fields"

	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCInitDeclarator: aTSNode withFields: fields [
	"declarator value"

	self visitKey: 'value' inDictionnary: fields.
	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCParameterDeclaration: aTSNode withFields: fields [
	"type declarator"

	| paramEntity |
	paramEntity := model newParameter.
	paramEntity
		parentBehaviouralEntity: context top;
		name: (self visitKey: 'declarator' inDictionnary: fields);
		sourceAnchor: (self extractSourceAnchor: aTSNode).

	self visitKey: 'type' inDictionnary: fields.

	^ paramEntity
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCParameterList: aTSNode withFields: fields [
	"<unnamedChild>"

	"(fields at: '<unnamedChild>') is a TSNode instance if there is only one parameter"

	"otherwise it will be an orederedCollection"

	"before visiting all parameters, we need to check if they have already been added to the model from their function prototype"

	fields isEmpty ifTrue: [ ^ self ].

	context top parameters isNotEmpty ifTrue: [ "parameters already in the model"
		^ self ].

	(self ensureAsOrderedCollection: (fields at: fields keys first)) do: [
			:eachParamDeclaration |
			self
				visitCParameterDeclaration: eachParamDeclaration
				withFields: eachParamDeclaration collectFieldNameOfNamedChild ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCParenthesizedExpression: aTSNode withFields: fields [
	"<unnamedChild>"

	| expression |
	expression := self visitKey: '<unnamedChild>' inDictionnary: fields.
	self createReadAccessIfVariableTo: expression from: aTSNode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCPointerDeclarator: aTSNode withFields: fields [

	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCPointerExpression: aTSNode withFields: fields [
	"argument"

	^ self visitKey: 'argument' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCPrimitiveType: aTSNode withFields: fields [

	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCReturnStatement: aTSNode withFields: fields [
	"<unnamedChild>"

	| returnedExpr |
	returnedExpr := self
		                 visitKey: '<unnamedChild>'
		                 inDictionnary: fields.

	self createReadAccessIfVariableTo: returnedExpr from: aTSNode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCStructSpecifier: aTSNode withFields: fields [
	"name body"

	^ self
		  visitCStructuredType: aTSNode
		  withFields: fields
		  type: FamixCStruct
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCStructuredType: aTSNode withFields: fields type: aFamixCStructuredTypeClass [
	"name body"

	| structuredTypeEntity structuredTypeName isAnonymous asAttributeType asTypedefType |
	isAnonymous := (fields includesKey: 'name') not.
	asAttributeType := context isNotEmpty and: [
		                   context top class = FamixCAttribute ].
	asTypedefType := context isNotEmpty and: [
		                 context top class = FamixCAliasType ].



	isAnonymous & asAttributeType not & inDeclaration not
	& asTypedefType not ifTrue: [ "skip entity creation for this case: 
			```
			struct foo { 
				struct {
					int a; // here, a is promoted to outer structure or union
				}
			};
			```
			"
		self visitKey: 'body' inDictionnary: fields.
		^ nil ].

	structuredTypeName := ''.
	isAnonymous ifFalse: [
		structuredTypeName := self visitKey: 'name' inDictionnary: fields ].

	(fields includesKey: 'body')
		ifTrue: [
			structuredTypeEntity := aFamixCStructuredTypeClass new.
			
			structuredTypeEntity
				name: structuredTypeName;
				sourceAnchor: (self extractSourceAnchor: aTSNode).
			model add: structuredTypeEntity.

			inDeclaration | asAttributeType ifTrue: [
				context top typing: (self newEntityTypingFor: structuredTypeEntity) ].

			asTypedefType ifTrue: [
				context top aliasedType: structuredTypeEntity ].

			context push: structuredTypeEntity.
			self visitKey: 'body' inDictionnary: fields.
			context pop ]
		ifFalse: [ "no need to create an entity here"
			structuredTypeEntity := self
				                        detect: aFamixCStructuredTypeClass
				                        name: structuredTypeName ].
	^ structuredTypeEntity
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCSubscriptExpression: aTSNode withFields: fields [

	self visitKey: 'index' inDictionnary: fields.
	^ self visitKey: 'argument' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCTypeDefinition: aTSNode withFields: fields [
	"type declarator"

	| typedefEntity |
	typedefEntity := model newAliasType
		                 name:
			                 (self visitKey: 'declarator' inDictionnary: fields);
		                 sourceAnchor: (self extractSourceAnchor: aTSNode).

	context push: typedefEntity.
	self visitKey: 'type' inDictionnary: fields.
	context pop
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCTypeIdentifier: aTSNode withFields: fields [
	"no fields"

	context isNotEmpty ifTrue: [
		context top sourceAnchor: (self extractSourceAnchor: aTSNode) ].
	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCUnionSpecifier: aTSNode withFields: fields [
	"name body"

	^ self
		  visitCStructuredType: aTSNode
		  withFields: fields
		  type: FamixCUnion
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCUpdateExpression: aTSNode withFields: fields [

	| varName |
	varName := self visitKey: 'argument' inDictionnary: fields.
	
	(context isNotEmpty and: [ context top isFunction ]) ifTrue: [
		| variable |
		variable := self lookupVariable: varName in: context top.
		self createWriteAccessTo: variable from: aTSNode ].
	
	^ varName
]
