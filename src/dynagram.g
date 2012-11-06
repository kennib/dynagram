grammar dynagram;
options {
  language=JavaScript;
  output=AST;
}

tokens {
  SENTENCE;
  CONDITION;
  ACTION;
  ATTRIBUTE;
  TYPE;
}

diagram:
  (sentence EOS)* -> sentence*
;

sentence:
  (conditional THEN)? action -> ^(SENTENCE conditional? action)
;


/*****************************
* Conditionals
******************************/

conditional:
  IF condition=(action|attribute) -> ^(CONDITION $condition)
;


/*****************************
* Actions
******************************/

action:
    general_action
  | define
;

general_action:
    '(' act=verb subject=(general_action|noun) (PREPOSITION object+=(general_action|noun) (AND object+=(general_action|noun))*)? ')'
    -> ^(ACTION $act $subject? $object*)
;

define:
    act=DEFINE_KW subject=(action|attribute) AS object=(sentence|type)    -> ^(ACTION $act $subject? $object?)
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

ARTICLE             : 'the'|'an'|'a' ;
AND                 : 'and'|',' ;
AS                  : 'as' ; 
IF                  : 'if' ;
THEN                : 'then' ;
PREPOSITION         : 'with'|'between'|'of'|'to'|'from' ;

ID                  : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;
NUM                 : '0'..'9'+ ;
STRING:
   ('"'  (ESC_CHAR | ~('"' |'\\'|'\n'))* '"'
  | '\'' (ESC_CHAR | ~('\''|'\\'|'\n'))* '\'')
  // Remove quotes
  {this.setText(this.getText().substring(1, this.getText().length-1));}
;

EOS                 : '.' ; // end of sentence
ESC_CHAR            : '\\' . ;

WS : (' '|'\t'|'\r'|'\n')+ {$channel=HIDDEN;} ;
