Class {
	#name : 'FamixCResolver',
	#superclass : 'Object',
	#instVars : [
		'model'
	],
	#category : 'Famix-C-Importer',
	#package : 'Famix-C-Importer'
}

{ #category : 'instance creation' }
FamixCResolver class >> on: aMooseModel [

	^ self new
		  model: aMooseModel;
		  yourself
]

{ #category : 'as yet unclassified' }
FamixCResolver >> allHeaderFiles [

	^ model allWithType: FamixCPreprocHeaderFile
]

{ #category : 'as yet unclassified' }
FamixCResolver >> allLocalPreprocIncludes [

	^ model allWithType: FamixCPreprocInclude
]

{ #category : 'accessing' }
FamixCResolver >> entityNamed: aName in: aCollection [

	^ aCollection detect: [ :each | each name = aName ] ifNone: [ nil ]
]

{ #category : 'accessing' }
FamixCResolver >> lookupFunctions: aString [

	^ model allFunctions select: [ :each | each name = aString ]
]

{ #category : 'as yet unclassified' }
FamixCResolver >> lookupLocalVariable: aString in: aFamixCFunction [

	| localVar |
	localVar := self
		            entityNamed: aString
		            in: aFamixCFunction localVariables.
	localVar ifNil: [
		localVar := self entityNamed: aString in: aFamixCFunction parameters ].
	
	^ localVar
]

{ #category : 'accessing' }
FamixCResolver >> lookupType: aString [

	^ model allTypes
		detect: [ :each | each name = aString ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
FamixCResolver >> model [

	^ model
]

{ #category : 'accessing' }
FamixCResolver >> model: anObject [

	model := anObject
]

{ #category : 'instance creation' }
FamixCResolver >> newEntityTypingFor: aFamixCTypeEntity [

	^ model newEntityTyping
		  declaredType: aFamixCTypeEntity;
		  yourself
]

{ #category : 'navigating' }
FamixCResolver >> resolve [

	self resolvingSteps do: [ :step | self perform: step ]
]

{ #category : 'accessing' }
FamixCResolver >> resolveAccesses [

	model allAccesses do: [ :access |
			access variable ifNil: [
					| varName |
					varName := access attributeAt: #variable ifAbsent: [ nil ].
					access variable:
						(self lookupLocalVariable: varName in: access accessor) ] ]
]

{ #category : 'accessing' }
FamixCResolver >> resolveAliasedTypes [

	(model allWithType: FamixCAliasType) do: [ :eachAlias |
			eachAlias aliasedType ifNil: [
					| aliasedTypeName |
					aliasedTypeName := eachAlias
						                   attributeAt: #aliasedType
						                   ifAbsent: [ nil ].
					eachAlias aliasedType: (self lookupType: aliasedTypeName) ] ]
]

{ #category : 'accessing' }
FamixCResolver >> resolveIncludes [

	self allLocalPreprocIncludes do: [ :include |
			self allHeaderFiles
				detect: [ :headerFile |
						headerFile name asPath basename
						=
						(include attributeAt: #path ifAbsent: [ ^ nil ]) asPath basename ]
				ifFound: [ :headerFile | include included: headerFile ]
				ifNone: [ ] ]
]

{ #category : 'accessing' }
FamixCResolver >> resolveInvocations [

	model allInvocations do: [ :each |
			| fnName |
			fnName := each attributeAt: #name ifAbsent: [ nil ].
			(self lookupFunctions: fnName) do: [ :eachFn |
				each addCandidate: eachFn ] ]
]

{ #category : 'accessing' }
FamixCResolver >> resolveTypes [

	(model allUsing: FamixTTypedEntity) do: [ :each |
			each typing ifNil: [
					| type famixTypeEntity |
					
					type := each attributeAt: #declaredType ifAbsent: [ nil ].
					famixTypeEntity := self lookupType: type.
					famixTypeEntity ifNotNil: [
						each typing: (self newEntityTypingFor: famixTypeEntity) ] ] ]
]

{ #category : 'run' }
FamixCResolver >> resolvingSteps [

	^ #( 
			#resolveIncludes
			#resolveTypes
			#resolveAliasedTypes
			#resolveAccesses
			#resolveInvocations
		)
]
