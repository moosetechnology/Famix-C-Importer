Class {
	#name : 'FamixCCommentVisitor',
	#superclass : 'FamixTSAbstractCommentsVisitor',
	#category : 'Famix-C-Importer',
	#package : 'Famix-C-Importer'
}

{ #category : 'visiting' }
FamixCCommentVisitor >> visitNode: aTSNode [

	aTSNode type = #comment ifTrue: [
			(aTSNode sourceText beginsWith: '/*')
				ifTrue: [ self addMultilineCommentNode: aTSNode ]
				ifFalse: [ self addSingleLineCommentNode: aTSNode ] ].
	super visitNode: aTSNode
]
