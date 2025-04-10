Extension { #name : 'TSLanguage' }

{ #category : '*TreeSitter-CLanguage' }
TSLanguage class >> cLang [

	^ TSCLibrary uniqueInstance tree_sitter_c
]
