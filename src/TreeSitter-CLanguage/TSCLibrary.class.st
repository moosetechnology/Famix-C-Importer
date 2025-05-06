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

{ #category : 'accessing - platform' }
TSCLibrary >> unix32LibraryName [ 
 ^ FFIUnix32LibraryFinder findAnyLibrary: #('libtree-sitter-c.so')
]

{ #category : 'accessing - platform' }
TSCLibrary >> unix64LibraryName [ 
 ^ FFIUnix64LibraryFinder findAnyLibrary: #('libtree-sitter-c.so')
]
