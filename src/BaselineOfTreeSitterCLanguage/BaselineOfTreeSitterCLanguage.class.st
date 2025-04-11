Class {
	#name : 'BaselineOfTreeSitterCLanguage',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTreeSitterCLanguage',
	#package : 'BaselineOfTreeSitterCLanguage'
}

{ #category : 'baselines' }
BaselineOfTreeSitterCLanguage >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfTreeSitterCLanguage >> defineDependencies: spec [

	spec baseline: 'TreeSitter' with: [ 
		spec repository:
			'https://github.com/Evref-BL/Pharo-Tree-Sitter' ]
]

{ #category : 'baselines' }
BaselineOfTreeSitterCLanguage >> defineGroups: spec [

	spec
		group: 'default'
		with: #( 'TreeSitter-CLanguage' 'TreeSitter-CLanguage-Tests' ).  
]

{ #category : 'baselines' }
BaselineOfTreeSitterCLanguage >> definePackages: spec [

	spec
		package: 'TreeSitter-CLanguage'
		with: [
			spec requires:
					#( TreeSitter ) ]
]
