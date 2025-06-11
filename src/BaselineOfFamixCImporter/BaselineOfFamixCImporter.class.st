Class {
	#name : 'BaselineOfFamixCImporter',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfFamixCImporter',
	#package : 'BaselineOfFamixCImporter'
}

{ #category : 'baselines' }
BaselineOfFamixCImporter >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfFamixCImporter >> defineDependencies: spec [

	spec
		baseline: 'TreeSitter'
		with: [
			spec repository: 'github://Evref-BL/Pharo-Tree-Sitter:main/src' ];
		baseline: 'FamixCpp'
		with: [
			spec repository: 'github://moosetechnology/Famix-Cpp:main/src' ]
]

{ #category : 'baselines' }
BaselineOfFamixCImporter >> defineGroups: spec [

	spec
		group: 'default'
		with: #( 'Famix-C-Importer' 'Famix-C-Importer-Tests' )
]

{ #category : 'baselines' }
BaselineOfFamixCImporter >> definePackages: spec [

	spec
		package: 'Famix-C-Importer'
		with: [ spec requires: #( 'TreeSitter' 'FamixCpp' ) ];
		package: 'Famix-C-Importer-Tests'
		with: [ spec requires: #( 'Famix-C-Importer' ) ]
]
