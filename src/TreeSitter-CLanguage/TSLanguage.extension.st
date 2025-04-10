Extension { #name : 'TSLanguage' }

{ #category : '*TreeSitter-CLanguage' }
TSLanguage class >> cLanguage [

	^ TSCLibrary uniqueInstance tree_sitter_c
]
