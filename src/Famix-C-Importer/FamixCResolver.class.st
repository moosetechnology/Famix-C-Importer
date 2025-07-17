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
FamixCResolver >> model [

	^ model
]

{ #category : 'accessing' }
FamixCResolver >> model: anObject [

	model := anObject
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
FamixCResolver >> resolveInvocations [

	model allInvocations do: [ :each |
			| fnName |
			fnName := each attributeAt: #name ifAbsent: [ nil ].
			(self lookupFunctions: fnName) do: [ :eachFn |
				each addCandidate: eachFn ] ]
]

{ #category : 'run' }
FamixCResolver >> resolvingSteps [

	^ #( #resolveAccesses #resolveInvocations )
]
