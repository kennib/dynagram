grammar dynagram;
options {
  language=JavaScript;
  output=AST;
}

tokens {
  SENTENCE;
  ITERATION_FOR;
  ITERATION_WHILE;
  CONDITION;
  ACTION;
  ATTRIBUTE;
  TYPE;
}

@lexer::members {
  previousIndents = -1;
  indentLevel = 0;
  tokens = [];

  this.jump = function(ttype) {
    indentLevel += (ttype == this.DEDENT ? -1 : 1);
    this.emit(new org.antlr.runtime.CommonToken(ttype, "level=" + indentLevel));
  }
}

diagram:
  (action|control)+
;

block:
  INDENT (action|control)+ (DEDENT|EOF)
;


/*****************************
* Control Flow
******************************/

control:
  ( iteration | conditional )
;

iteration:
    FOR object=noun IN list=noun body=block
    -> ^(ITERATION_FOR $object $list $body)

  | WHILE condition body=block
    -> ^(ITERATION_WHILE condition $body)
;

conditional:
    IF condition THEN body=block
    -> ^(CONDITION condition $body)
;

condition:
  attribute
;

/*****************************
* Actions
******************************/

action:
    general_action
  | define_action
  | set_attribute
;

general_action:
    act=verb PREPOSITION? subject=noun ((PREPOSITION object+=noun) (AND object+=noun)*)?
    -> ^(ACTION $act $subject? $object*)
;

define_action:
    act=DEFINE_KW '(' subject=(general_action) ')' AS type? object=(block+)
    -> ^(ACTION $act $subject? type? $object*)
;

set_attribute:
    act=SET_KW subject=attribute AS type? object=(block+)
    -> ^(ACTION $act $subject? type? $object*)
;

/*****************************
* Attributes
******************************/

attribute:
    attr=noun (PREPOSITION object+=noun (AND object+=noun)*)? -> ^(ATTRIBUTE $attr $object*)
;


/*****************************
* Literals
******************************/

verb:
  (ID|STRING) 
;

noun:
  ARTICLE? (ID|STRING)
;

type:
  noun -> ^(TYPE noun)
;


DEFINE_KW           : 'define' ;
SET_KW              : 'set' ;

ARTICLE             : 'the'|'an'|'a' ;
AND                 : 'and'|',' ;
AS                  : 'as' ; 
IF                  : 'if' ;
IN                  : 'in' ;
FOR                 : 'for' ;
THEN                : 'then' ;
WHILE               : 'while' ;
PREPOSITION         : 'with'|'between'|'of'|'to'|'from' ;

ID                  : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;
NUM                 : '0'..'9'+ ;
STRING:
   ('"'  (ESC_CHAR | ~('"' |'\\'|'\n'))* '"'
  | '\'' (ESC_CHAR | ~('\''|'\\'|'\n'))* '\'')
  // Remove quotes
  {this.setText(this.getText().substring(1, this.getText().length-1));}
;

ESC_CHAR            : '\\' . ;

WS:
  SP { this.skip(); }
;

NEWLINE:
  NL SP?
  {
    n = (!$SP.text ? 0 : $SP.text.length);
    //console.log('line: '+this.state.tokenStartLine+', indent: '+n);

    if(n > previousIndents) {
      this.jump(this.INDENT);
      previousIndents = n;
    } else if(n < previousIndents) {
      this.jump(this.DEDENT);
      previousIndents = n;
    } else if(this.input.LA(1) == EOF) {
      while(indentLevel > 0) {
        this.jump(this.DEDENT);
      }
    } else {
      this.skip();
    }
  }
;

fragment NL     : '\r'? '\n' | '\r';
fragment SP     : (' ' | '\t')+;
fragment INDENT : ;
fragment DEDENT : ;
