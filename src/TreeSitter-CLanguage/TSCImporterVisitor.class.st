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

{ #category : 'accessing' }
TSCImporterVisitor >> context [

	^ context
]

{ #category : 'accessing' }
TSCImporterVisitor >> context: anObject [

	context := anObject
]

{ #category : 'as yet unclassified' }
TSCImporterVisitor >> detect: aFamixCEntity name: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ nil ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> ensureEntityExist: aFamixCEntity value: aString [

	^ (model allWithType: aFamixCEntity)
		  detect: [ :each | each name = aString ]
		  ifNone: [ model add: (aFamixCEntity new name: aString) ]
]

{ #category : 'visiting' }
TSCImporterVisitor >> extractSourceAnchor: aTSNode [

	^ FamixCIndexedFileAnchor new
		  startPos: aTSNode startByte;
		  endPos: aTSNode endByte;
		  fileName: fileName
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

	^ aFileReference isFile
		ifTrue: [ self importFromFile: aFileReference ]
		ifFalse: [ self importFromFolder: aFileReference ]
]

{ #category : 'importer' }
TSCImporterVisitor >> importFromFile: aFileReference [
	"accept both .c and .h file"

	"check if it's a .c or .h file"

	| acceptedFiles |
	acceptedFiles := #( 'c' 'h' ).

	(acceptedFiles includes: aFileReference extensions first)
		ifTrue: [
			fileName := aFileReference fullName.

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

{ #category : 'initialization' }
TSCImporterVisitor >> initialize [

	super initialize.

	parser := TSParser new.
	parser language: TSLanguage cLanguage.

	context := Stack new.
	model := FamixCModel new.
	inDeclaration := false
]

{ #category : 'accessing' }
TSCImporterVisitor >> model [

	^ model
]

{ #category : 'accessing' }
TSCImporterVisitor >> model: anObject [

	model := anObject
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
TSCImporterVisitor >> visitCArrayDeclarator: aTSNode withFields: fields [
	"declarator size"

	self visitKey: 'size' inDictionnary: fields.
	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCDeclaration: aTSNode withFields: fields [
	"type declarator"

	"check if it is a declaration inside a function, for local variable"

	inDeclaration := true.
	(context isNotEmpty and: [ context top isFunction ])
		ifTrue: [
			| identifiersName |
			identifiersName := self
				                   visitKey: 'declarator'
				                   inDictionnary: fields.

			identifiersName isString ifTrue: [
				identifiersName := OrderedCollection new
					                   add: identifiersName;
					                   yourself ].

			identifiersName do: [ :eachIdentifierName |
				| localVarEntity |
				localVarEntity := FamixCLocalVariable new
					                  name: eachIdentifierName;
					                  sourceAnchor:
						                  (self extractSourceAnchor: aTSNode);
					                  parentBehaviouralEntity: context top.

				model add: localVarEntity.

				context push: localVarEntity.
				self visitKey: 'type' inDictionnary: fields.
				context pop ] ]
		ifFalse: [
			self visitKey: 'type' inDictionnary: fields.
			self visitKey: 'declarator' inDictionnary: fields ].



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
				context top declaredType: enumEntity ].

			context push: enumEntity.
			self visitKey: 'body' inDictionnary: fields.
			context pop ]
		ifFalse: [
			enumEntity := self detect: FamixCEnum name: enumName.
			enumEntity ifNotNil: [ context top declaredType: enumEntity ] ].


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
			fieldsName := self visitKey: 'declarator' inDictionnary: fields.
			
			fieldsName isString ifTrue: [
				fieldsName := OrderedCollection new
					              add: fieldsName;
					              yourself ].
				
			fieldsName do: [ :eachName |
				fieldDelcarationEntity := model newAttribute
					                          name: eachName;
					                          sourceAnchor:
						                          (self extractSourceAnchor: aTSNode);
					                          parentType: context top.

				context push: fieldDelcarationEntity.
				self visitKey: 'type' inDictionnary: fields.
				context pop 
				
				] ]
		ifFalse: [ "this field declaration node is an anonymous struct and doesn't have field_identifier"
			self visitKey: 'type' inDictionnary: fields ]
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

	fnEntity := self ensureEntityExist: FamixCFunction value: fnName.
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
	self visitKey: 'type' inDictionnary: fields.
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

	| firstKey parentFunctionEntity |
	fields isEmpty ifTrue: [ ^ self ].

	parentFunctionEntity := context top.
	parentFunctionEntity parameters isNotEmpty ifTrue: [ "parameters already in the model"
		^ self ].

	firstKey := fields keys first.
	(fields at: firstKey) isCollection
		ifTrue: [
			(fields at: firstKey) do: [ :eachParameterDeclaration |
				self
					visitCParameterDeclaration: eachParameterDeclaration
					withFields: eachParameterDeclaration collectFieldNameOfNamedChild ] ]
		ifFalse: [ super visitCParameterList: aTSNode withFields: fields ]
		
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCPointerDeclarator: aTSNode withFields: fields [

	^ self visitKey: 'declarator' inDictionnary: fields
]

{ #category : 'visiting' }
TSCImporterVisitor >> visitCStructSpecifier: aTSNode withFields: fields [
	"name body"

	| structEntity structName isAnonymous structAsAttributeType isTypedefType |
	isAnonymous := (fields includesKey: 'name') not.
	structAsAttributeType := context isNotEmpty and: [
		                         context top class = FamixCAttribute ].
	isTypedefType := context isNotEmpty and: [
		                 context top class = FamixCAliasType ].



	isAnonymous & structAsAttributeType not & inDeclaration not
	& isTypedefType not ifTrue: [ "skip entity creation for this case: 
			```
			struct foo { 
				struct {
					int a; // here, a is promoted to outer structure
				}
			};
			```
			"
		self visitKey: 'body' inDictionnary: fields.
		^ nil ].

	structName := ''.
	isAnonymous ifFalse: [
		structName := self visitKey: 'name' inDictionnary: fields ].

	(fields includesKey: 'body')
		ifTrue: [
			structEntity := model newStruct
				                name: structName;
				                sourceAnchor: (self extractSourceAnchor: aTSNode).

			inDeclaration | structAsAttributeType ifTrue: [
				context top declaredType: structEntity ].

			isTypedefType ifTrue: [ context top aliasedType: structEntity ].

			context push: structEntity.
			self visitKey: 'body' inDictionnary: fields.
			context pop ]
		ifFalse: [ "no need to create an entity here"
			structEntity := self detect: FamixCStruct name: structName ].
	^ structEntity
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

	| fileAnchor |
	context isNotEmpty ifTrue: [
		fileAnchor := FamixCIndexedFileAnchor new.
		fileAnchor startPos: aTSNode startByte.
		fileAnchor endPos: aTSNode endByte.
		context top sourceAnchor: fileAnchor 
		].
	^ aTSNode textFromSourceText: sourceCode
]
