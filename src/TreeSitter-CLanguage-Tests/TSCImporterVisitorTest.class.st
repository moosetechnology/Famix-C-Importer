"
A TSCImporterVisitorTest is a test class for testing the behavior of TSCImporterVisitor
"
Class {
	#name : 'TSCImporterVisitorTest',
	#superclass : 'TestCase',
	#instVars : [
		'importer'
	],
	#category : 'TreeSitter-CLanguage-Tests',
	#package : 'TreeSitter-CLanguage-Tests'
}

{ #category : 'running' }
TSCImporterVisitorTest >> setUp [
	super setUp.

	importer := TSCImporterVisitor new
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionDefinitionName [

	| tsRoot |
	tsRoot := self tsFunction: 'func'.

	tsRoot accept: importer.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne name equals: 'func'.
	
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunction: aString [

	^TSStub new
		type: #function_definition ;
		collectFieldNameOfNamedChild: { #declarator -> (self tsFunctionDeclarator: aString) }.
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunctionDeclarator: aString [

	^TSStub new
		type: #function_declarator ;
		collectFieldNameOfNamedChild: { #declarator -> (self tsIdentifier: aString) }
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsIdentifier: aString [

	^TSStub new
		type: #identifier ;
		setTextFromSourceText: aString
]
