Class {
	#name : 'FamixCImporterVisitor',
	#superclass : 'TSCLanguageVisitor',
	#instVars : [
		'parser',
		'model',
		'context',
		'sourceCode',
		'fileName',
		'inDeclaration'
	],
	#category : 'Famix-C-Importer',
	#package : 'Famix-C-Importer'
}

{ #category : 'importer' }
FamixCImporterVisitor >> acceptedExtensions [

	^ #( 'c' 'h' )
]

{ #category : 'as yet unclassified' }
FamixCImporterVisitor >> allHeaderFiles [

	^ model allWithType: FamixCPreprocHeaderFile
]

{ #category : 'accessing' }
FamixCImporterVisitor >> context [

	^ context
]

{ #category : 'accessing' }
FamixCImporterVisitor >> context: anObject [

	context := anObject
]

{ #category : 'private-entity-creation' }
FamixCImporterVisitor >> createDereferencedInvocation: aTSNode [

	| invocation |
	invocation := FamixCDereferencedInvocation new
		              signature: (aTSNode textFromSourceText: sourceCode);
		              sender: context top;
		              sourceAnchor: (self extractSourceAnchor: aTSNode).
		              
	model add: invocation.
	^ invocation
]

{ #category : 'accessing' }
FamixCImporterVisitor >> createReadAccessIfVariableTo: aVariableName from: aTSNode [

	(context isNotEmpty and: [ context top isFunction ]) ifTrue: [
			aVariableName isString ifTrue: [
				^ self createReadAccessTo: aVariableName from: aTSNode ] ].
	^ nil
]

{ #category : 'private-entity-creation' }
FamixCImporterVisitor >> createReadAccessTo: variableName from: aTSNode [

	^ model newAccess
		  variable: (self lookupVariable: variableName in: context top);
		  accessor: context top;
		  isWrite: false;
		  sourceAnchor: (self extractSourceAnchor: aTSNode);
		  yourself
]

{ #category : 'private-entity-creation' }
FamixCImporterVisitor >> createWriteAccessTo: variable from: anAssignmentNode [

	^ model newAccess
		  variable: variable;
		  accessor: self currentEntity;
		  isWrite: true;
		  sourceAnchor: (self extractSourceAnchor: anAssignmentNode);
		  yourself
]

{ #category : 'accessing' }
FamixCImporterVisitor >> currentEntity [

	^ context top
]

{ #category : 'accessing' }
FamixCImporterVisitor >> detect: aFamixCEntity name: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ nil ]
]

{ #category : 'visiting' }
FamixCImporterVisitor >> ensureAsOrderedCollection: anObject [

	^ anObject class = OrderedCollection
		  ifTrue: [ anObject ]
		  ifFalse: [
				  OrderedCollection new
					  add: anObject;
					  yourself ]
]

{ #category : 'visiting' }
FamixCImporterVisitor >> ensureEntityExist: aFamixCEntity name: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ model add: (aFamixCEntity new name: aString) ]
]

{ #category : 'accessing' }
FamixCImporterVisitor >> entityNamed: aName in: aCollection [

	^ aCollection detect: [ :each | each name = aName ] ifNone: [ nil ]
]

{ #category : 'visiting' }
FamixCImporterVisitor >> extractSourceAnchor: aTSNode [

	^ FamixCIndexedFileAnchor new
		  startPos: aTSNode startByte + 1;
		  endPos: aTSNode endByte;
		  fileName: fileName;
		  mooseModel: model
]

{ #category : 'accessing' }
FamixCImporterVisitor >> fileName [

	^ fileName
]

{ #category : 'accessing' }
FamixCImporterVisitor >> fileName: anObject [

	fileName := anObject
]

{ #category : 'accessing' }
FamixCImporterVisitor >> import: aFileName [

	| fileReference |
	fileReference := aFileName asFileReference.

	fileReference exists ifFalse: [
		self error: fileReference fullName , ' does not exist' ].

	model
		name: fileReference basename;
		rootFolder: (fileReference isFile
				 ifTrue: [ fileReference parent ]
				 ifFalse: [ aFileName ]).

	self importFileReference: fileReference.
	(FamixCResolver on: model ) resolve.

	^ model
]

{ #category : 'api' }
FamixCImporterVisitor >> importFileReference: aFileReference [
	"We can have two cases here:
	 1. it's a file: so we parse its content if it's a .c or .h file. We skip other files
	 2. it's a directory: we will visit it's children (might be files or/and directories)
	"

	aFileReference isFile
		ifTrue: [
				(self isCFile: aFileReference) ifFalse: [ ^ self ].
				self importFromFile: aFileReference.
				self traceCr: fileName ]
		ifFalse: [
				context push: (self newPreprocFolder: aFileReference).
				aFileReference children do: [ :each |
					self importFileReference: each ].
				context pop.
				^ self ]
]

{ #category : 'importer' }
FamixCImporterVisitor >> importFromFile: aFileReference [

	| fileEntity |
	fileEntity := aFileReference extension = 'c'
		              ifTrue: [
		              self newPreprocCompilationUnit: aFileReference ]
		              ifFalse: [ self newPreprocHeaderFile: aFileReference ].
		
	fileName := self relativePath: aFileReference.

	sourceCode := aFileReference contents.

	context push: fileEntity.
	(self parseString: sourceCode) accept: self.
	context pop.

	^ model
]

{ #category : 'importer' }
FamixCImporterVisitor >> importFromString: aString [

	| rootNode |
	rootNode := self parseString: aString.
	sourceCode := aString.
	fileName := '** Not a file - Imported from a string **'.
	
	context push: (self
			 newPreprocFile: FamixCPreprocCFile
			 with: fileName asFileReference).

	rootNode accept: self.
	context pop.

	^ model
]

{ #category : 'accessing' }
FamixCImporterVisitor >> inFunctionContext [

	^ context isNotEmpty and: [ context top isFunction ]
]

{ #category : 'initialization' }
FamixCImporterVisitor >> initialize [

	super initialize.

	parser := TSParser new.
	parser language: TSLanguage cLang.

	context := Stack new.
	model := FamixCModel new.
	inDeclaration := false.
]

{ #category : 'testing' }
FamixCImporterVisitor >> isCFile: aFileReference [

	^ self acceptedExtensions includes: aFileReference extension
]

{ #category : 'accessing' }
FamixCImporterVisitor >> isLocalLib: aTSNode [

	^ aTSNode type ~= 'system_lib_string'
]

{ #category : 'accessing' }
FamixCImporterVisitor >> lookupVariable: aName in: aFamixCFunction [

	^ self entityNamed: aName in: aFamixCFunction localVariables
]

{ #category : 'accessing' }
FamixCImporterVisitor >> model [

	^ model
]

{ #category : 'accessing' }
FamixCImporterVisitor >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
FamixCImporterVisitor >> newEntityTypingFor: aFamixCTypeEntity [

	^ model newEntityTyping
		  declaredType: aFamixCTypeEntity;
		  yourself
]

{ #category : 'instance creation' }
FamixCImporterVisitor >> newPreprocCompilationUnit: aFileReference [

	^ self
		  newPreprocFile: FamixCPreprocCompilationUnit
		  with: aFileReference
]

{ #category : 'accessing' }
FamixCImporterVisitor >> newPreprocFile: aClass with: aFileReference [

	^ model add: (aClass new name: (self relativePath: aFileReference))
]

{ #category : 'instance creation' }
FamixCImporterVisitor >> newPreprocFolder: aFileReference [

	^ self newPreprocFile: FamixCPreprocFolder with: aFileReference
]

{ #category : 'instance creation' }
FamixCImporterVisitor >> newPreprocHeaderFile: aFileReference [

	^ model add: (FamixCPreprocHeaderFile new name: aFileReference basename)
]

{ #category : 'parsing' }
FamixCImporterVisitor >> parseString: aString [
	"return the source code AST"

	^ (parser parseString: aString) rootNode
]

{ #category : 'accessing' }
FamixCImporterVisitor >> relativePath: aFileReference [

	^ (aFileReference relativeTo: model rootFolder asFileReference)
		  pathString
]

{ #category : 'accessing' }
FamixCImporterVisitor >> sourceCode: anObject [

	sourceCode := anObject
]

{ #category : 'parsing' }
FamixCImporterVisitor >> textFromSourceText: aTSNode [

	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCArgumentList: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCArrayDeclarator: aTSNode withFields: fields [
	"declarator size"

	self visitKey: 'size' inDictionnary: fields.
	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCAssignmentExpression: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCBinaryExpression: aTSNode withFields: fields [
	"left right"

	| left right |
	
	left := self visitKey: 'left' inDictionnary: fields.
	self createReadAccessIfVariableTo: left from: aTSNode.

	right := self visitKey: 'right' inDictionnary: fields.
	self createReadAccessIfVariableTo: right from: aTSNode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCCallExpression: aTSNode withFields: fields [
	"function arguments"

	self createDereferencedInvocation: aTSNode.

	^ super visitCCallExpression: aTSNode withFields: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCComment: aTSNode withFields: fields [
	"no fields"

	^ model add:
		  (FamixCComment new sourceAnchor:
			   (self extractSourceAnchor: aTSNode))
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCDeclaration: aTSNode withFields: fields [
	"type declarator"

	inDeclaration := true.
	self flag:
		'TODO: Refactor this to consider global variable once there is FamixCGlobalVariable in the metamodel'.
	"check if it is a declaration inside a function, for local variable"
	(context isNotEmpty and: [ context top class = FamixCFunction ])
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
FamixCImporterVisitor >> visitCERROR: aTSNode withFields: fields [
 ^ {
       self visitKey: 'type' inDictionnary: fields.
       self visitKey: '<unnamedChild>' inDictionnary: fields.
   }

]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCEnumSpecifier: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCEnumerator: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCFieldDeclaration: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCFieldExpression: aTSNode withFields: fields [

	self visitKey: 'field' inDictionnary: fields.
	^ self visitKey: 'argument' inDictionnary: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCFieldIdentifier: aTSNode withFields: fields [
	"no fields"

	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCFunctionDeclarator: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCFunctionDefinition: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCIdentifier: aTSNode withFields: fields [
	"no fields"

	^ self textFromSourceText: aTSNode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCInitDeclarator: aTSNode withFields: fields [
	"declarator value"

	self visitKey: 'value' inDictionnary: fields.
	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCParameterDeclaration: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCParameterList: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCParenthesizedExpression: aTSNode withFields: fields [
	"<unnamedChild>"

	| expression |
	expression := self visitKey: '<unnamedChild>' inDictionnary: fields.
	self createReadAccessIfVariableTo: expression from: aTSNode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCPointerDeclarator: aTSNode withFields: fields [

	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCPointerExpression: aTSNode withFields: fields [
	"argument"

	^ self visitKey: 'argument' inDictionnary: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCPreprocInclude: aTSNode withFields: fields [

	| includeEntity |
	includeEntity := FamixCPreprocInclude new
		                 attributeAt: #path
		                 put: (self visitKey: 'path' inDictionnary: fields);
		                 isLocal: (self isLocalLib: (fields at: 'path'));
		                 includedBy: context top;
		                 sourceAnchor: (self extractSourceAnchor: aTSNode).


	model add: includeEntity.
	^ includeEntity
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCPrimitiveType: aTSNode withFields: fields [

	^ self textFromSourceText: aTSNode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCReturnStatement: aTSNode withFields: fields [
	"<unnamedChild>"

	| returnedExpr |
	returnedExpr := self
		                 visitKey: '<unnamedChild>'
		                 inDictionnary: fields.

	self createReadAccessIfVariableTo: returnedExpr from: aTSNode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCStringContent: aTSNode withFields: fields [

	^ self textFromSourceText: aTSNode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCStringLiteral: aTSNode withFields: fields [

	^ self visitKey: '<unnamedChild>' inDictionnary: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCStructSpecifier: aTSNode withFields: fields [
	"name body"

	^ self
		  visitCStructuredType: aTSNode
		  withFields: fields
		  type: FamixCStruct
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCStructuredType: aTSNode withFields: fields type: aFamixCStructuredTypeClass [
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
FamixCImporterVisitor >> visitCSubscriptExpression: aTSNode withFields: fields [

	self visitKey: 'index' inDictionnary: fields.
	^ self visitKey: 'argument' inDictionnary: fields
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCSystemLibString: aTSNode withFields: fields [

	^ self textFromSourceText: aTSNode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCTypeDefinition: aTSNode withFields: fields [
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
FamixCImporterVisitor >> visitCTypeIdentifier: aTSNode withFields: fields [
	"no fields"

	^ aTSNode textFromSourceText: sourceCode
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCUnionSpecifier: aTSNode withFields: fields [
	"name body"

	^ self
		  visitCStructuredType: aTSNode
		  withFields: fields
		  type: FamixCUnion
]

{ #category : 'visiting' }
FamixCImporterVisitor >> visitCUpdateExpression: aTSNode withFields: fields [

	| varName |
	varName := self visitKey: 'argument' inDictionnary: fields.
	
	(context isNotEmpty and: [ context top isFunction ]) ifTrue: [
		| variable |
		variable := self lookupVariable: varName in: context top.
		self createWriteAccessTo: variable from: aTSNode ].
	
	^ varName
]
