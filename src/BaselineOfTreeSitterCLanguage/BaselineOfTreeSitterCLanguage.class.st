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
			'github://Evref-BL/Pharo-Tree-Sitter:main/src' ]
]

{ #category : 'baselines' }
BaselineOfTreeSitterCLanguage >> defineGroups: spec [

	spec
		group: 'default'
		with: #( 'TreeSitter-CLanguage' 'TreeSitter-CLanguage-Tests').  
]

{ #category : 'baselines' }
BaselineOfTreeSitterCLanguage >> definePackages: spec [

	spec
		package: 'TreeSitter-CLanguage'
		with: [ spec requires: #( TreeSitter ) ];
		
		package: 'TreeSitter-CLanguage-Tests'
		with: [ spec requires: #('TreeSitter-CLanguage') ]
]
