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

@members {
  // Type dictionary for attributes and actions
  this.dataType = {};
}


diagram:
  (action|control)+
;

block returns [type]:
  (action|control)+
  { $type = $action.type; }
;

control:
    ^(ITERATION_WHILE condition block)
  | ^(ITERATION_FOR noun noun block)
  | ^(CONDITION condition block)
;

condition:
  attribute
;

action returns [type, subject]:
    definition
    { $type = $definition.type; }
  | new
    { $type = $new.type; }
  | ^(ACTION act=verb subj=noun object=noun*)
    { $type = this.dataType[$subj.word]; $subject = $subj.word; }
;

definition returns [type, subject]:
  ^(ACTION act=(DEFINE_KW|SET_KW) (subj=attribute|subj=action) t=type? block)
  {
    var type = $t.type;
    if (type != undefined && type != $block.type) {
      throw new org.antlr.runtime.TypeCheckException(this.input, type, $block.type);
    }
  }
  { this.dataType[$subj.subject] = $block.type; $subject=$subj.subject; }
;

new returns [type]:
  ^(ACTION t=type)
  { $type = $t.type; }
;

attribute returns [type, subject]:
  ^(ATTRIBUTE attr=noun object=noun*)
  { $type = this.dataType[$attr.word]; $subject = $attr.word }
;

verb returns [word]:
  w=(ID|STRING)
  { $word = $w; }
;

noun returns [word]:
  ARTICLE? w=(ID|STRING|NUM)
  { $word = $w; }
;

type returns [type]:
  ^(TYPE t=noun)
  { $type = $t.text; }
;

