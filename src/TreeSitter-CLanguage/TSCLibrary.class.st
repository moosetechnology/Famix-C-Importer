Class {
	#name : 'TSCLibrary',
	#superclass : 'FFILibrary',
	#category : 'TreeSitter-CLanguage',
	#package : 'TreeSitter-CLanguage'
}

{ #category : 'accessing - platform' }
TSCLibrary >> macLibraryName [ 
 ^ FFIMacLibraryFinder findAnyLibrary: #('libtree-sitter-c.dylib')
]

{ #category : 'accessing - platform' }
TSCLibrary >> tree_sitter_c [ 
 ^ self ffiCall: 'TSLanguage * tree_sitter_c ()'
]
