Class {
	#name : 'FamixCIncludesResolvable',
	#superclass : 'SRResolvable',
	#instVars : [
		'path',
		'entity'
	],
	#category : 'Famix-C-Importer',
	#package : 'Famix-C-Importer'
}

{ #category : 'accessing' }
FamixCIncludesResolvable class >> path: aString [

	^ self new
		  path: aString;
		  yourself
]

{ #category : 'hooks' }
FamixCIncludesResolvable >> applyReplacementStrategyWithCurrentEntity: anEntity [

	self entity:
		(self notFoundReplacementEntity cull: self cull: anEntity)
]

{ #category : 'accessing' }
FamixCIncludesResolvable >> entity [

	^ entity
]

{ #category : 'accessing' }
FamixCIncludesResolvable >> entity: anObject [

	entity := anObject
]

{ #category : 'as yet unclassified' }
FamixCIncludesResolvable >> identifier [

	^ path
]

{ #category : 'accessing' }
FamixCIncludesResolvable >> path [

	^ path
]

{ #category : 'accessing' }
FamixCIncludesResolvable >> path: aString [

	path := aString
]

{ #category : 'resolution' }
FamixCIncludesResolvable >> resolveInScope: aScope currentEntity: currentEntity [
	"For now we are doing a naive version not checking for multiple files with the same name. 
	So we do not really need the scopes management, this is why we raise a SRNoResolutionPossible instead of a NotFound error"

	(currentEntity mooseModel allWithType: FamixCPreprocHeaderFile)
		detect: [ :headerFile | headerFile name asPath basename = path asPath basename ]
		ifFound: [ :headerFile | entity := headerFile ]
		ifNone: [ SRNoResolutionPossible signal ]
]
