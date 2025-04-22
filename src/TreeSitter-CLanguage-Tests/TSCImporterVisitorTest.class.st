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
	self assert: importer model allFunctions anyOne name equals: 'func'
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testFunctionIdentifierStartEndPosition [
	"in a function_definition TSNode, the name, the startByte and the endByte are in the identifer node (function_definition > function_declarator > identifier)"

	| tsRoot tsIdentifier |
	tsRoot := self tsFunction: 'func'.

	tsIdentifier := (tsRoot collectFieldNameOfNamedChild at: #declarator)
		              collectFieldNameOfNamedChild at: #declarator.
	tsIdentifier startEnd: 1 @ 5.

	tsRoot accept: importer.

	self assert: importer model allFunctions size equals: 1.
	self assert: importer model allFunctions anyOne sourceAnchor isNotNil.
	self
		assert: importer model allFunctions anyOne sourceAnchor startPos
		equals: 1.
	self
		assert: importer model allFunctions anyOne sourceAnchor endPos
		equals: 5
]

{ #category : 'tests' }
TSCImporterVisitorTest >> testParameterName [

	| tsRoot |
	tsRoot := self tsParamater: 'arg1'.
	tsRoot accept: importer.

	self assert: importer model allParameters size equals: 1.
	self assert: importer model allParameters anyOne name equals: 'arg1'
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsFunction: aString [

	^ TSStub new
		  type: #function_definition;
		  collectFieldNameOfNamedChild:
			  { (#declarator -> (self tsFunctionDeclarator: aString)) }
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

{ #category : 'running' }
TSCImporterVisitorTest >> tsParamater: aString [

	^TSStub new
		type: #parameter_declaration ;
		collectFieldNameOfNamedChild: { #declarator -> (self tsIdentifier: aString) }.
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsParamaterList: aTSStubOrADictionnary [

	^TSStub new
		type: #parameter_list ;
		collectFieldNameOfNamedChild: { '<unnamedChild>' -> aTSStubOrADictionnary }.
]

{ #category : 'running' }
TSCImporterVisitorTest >> tsTranslationUnit: aTSStubOrADictionnary [

	^TSStub new
		type: #translation_unit ;
		collectFieldNameOfNamedChild: { '<unnamedChild>' -> aTSStubOrADictionnary }.
]
