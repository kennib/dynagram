tree grammar dynagramTypeChecker;
options {
  tokenVocab=dynagram;
  ASTLabelType=CommonTree;
  language=JavaScript;
  output=AST;
}

@header {
  // Create an exception for incorrect types
  // Has expected type and given type parameters
  org.antlr.runtime.TypeCheckException = function(input, expected, given) {
    org.antlr.runtime.TypeCheckException.superclass.constructor.call(this, input);
    this.expected = expected;
    this.given = given;
  };

  // Add the exception
  org.antlr.lang.extend(
    org.antlr.runtime.TypeCheckException,
    org.antlr.runtime.RecognitionException,
    {
      toString: function() {
        return 'TypeCheckException('+this.expected+', '+this.given+')';
      },
      getMessage: function() {
        var msg = '\n';
        msg += 'An error has occured in "'+this.node.toString()+'"\n'; 
        msg += 'The given type <'+this.given+'> is incorrect. The type should be <'+this.expected+'>.';
        return msg;
      },
      name: "org.antlr.runtime.TypeCheckException" 
    }
  );
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
      throw new org.antlr.runtime.TypeCheckException(this.input, type, $block.type);
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

