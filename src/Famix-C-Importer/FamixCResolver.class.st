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
	self shouldBeImplemented.
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
	self shouldBeImplemented.
]

{ #category : 'accessing' }
FamixCResolver >> resolveTypes [
	^ true
]

{ #category : 'run' }
FamixCResolver >> resolvingSteps [

	^ #( 
			#resolveIncludes
			#resolveTypes
			"#resolveAccesses"
			"#resolveInvocations"
		)
]
