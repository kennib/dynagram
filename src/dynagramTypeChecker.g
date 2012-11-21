tree grammar dynagramTypeChecker;
options {
  tokenVocab=dynagram;
  ASTLabelType=CommonTree;
  language=JavaScript;
  output=AST;
}

diagram:
  (action|control)+
;

block returns [type]:
  (action|control)+
;

control:
    ^(ITERATION_WHILE condition block)
  | ^(ITERATION_FOR noun noun block)
  | ^(CONDITION condition block)
;

condition:
  attribute
;

action returns [name]:
    definition
  | ^(ACTION actName=verb subject=noun object=noun*)
      { $name = $actName.text; }
;

definition returns [name]:
  ^(ACTION actName=(DEFINE_KW|SET_KW) (subject=attribute|subject=action) type? block)
  {
    var type = $type.type;
    //console.log($subject.name+': '+type);
    if (type != $block.type) {
      var mte = new org.antlr.runtime.MismatchedTokenException(null, this.input);
      //this.recover(mte);
      //throw mte;
    }
  }
  { $name = $actName.text; }
;

attribute returns [name]:
  ^(ATTRIBUTE attrName=noun object=noun*)
  { $name = $attrName.text; }
;

verb:
 (ID|STRING)
;

noun:
  ARTICLE!? (ID|STRING|NUM)
;

type returns [type]:
  ^(TYPE t=noun)
  { $type = $t.text; }
;

