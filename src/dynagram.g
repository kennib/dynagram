grammar dynagram;
options {
  language=JavaScript;
  output=AST;
}

tokens {
  STATE;
  LIST;
  ITEMS;
  ACTION;
  INSERT;
  REMOVE;
  REVERSE;
  DEFINE;
  OPTIONS;
  OPTION;
  ID;
}

diagram:
   (action EOL)* -> ^(ACTION action*)
;


/*****************************
* Actions
******************************/
action:
    state_action
  | list_action
  | item_action
;

state_action:
    STATE_KW s? -> ^(STATE s?)
;

list_action:
    LIST_KW list LIST_PREP item (LIST_SEP item)*                 -> ^(LIST list ^(ITEMS item*))
  | INSERT_KW item INSERT_PREP list (INSERT_POS_PREP NUM)?       -> ^(INSERT list item NUM?)
  | REMOVE_KW item REMOVE_PREP list                              -> ^(REMOVE list item)
  | REVERSE_KW list                                              -> ^(REVERSE list)
;

item_action:
    DEFINE_KW item (DEFINE_PREP option (LIST_SEP option)*)? -> ^(DEFINE item ^(OPTIONS option*))
;

option:
    opt OPTION_PREP val -> ^(OPTION opt val)
;

/*****************************
* Literals
******************************/
s: ID;
list: ID;
item: ID;
opt: ID|STRING;
val: NUM|STRING;

EOL                 : '.' ;
LIST_SEP            : ',' ;

STATE_KW            : 'state';

DEFINE_KW           : 'define' ;
DEFINE_PREP         : 'with' ;

LIST_KW             : 'list';
LIST_PREP           : 'contains' ;

INSERT_KW           : 'insert' ;
INSERT_PREP         : 'into' ;
INSERT_POS_PREP     : 'at' ;
REMOVE_KW           : 'remove' ;
REMOVE_PREP         : 'from' ;
REVERSE_KW          : 'reverse' ;

OPTION_PREP         : 'as'|;

ID                  : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;
NUM                 : '0'..'9'+ ;

ESC_CHAR            : '\\' . ;
STRING:
   ('"'  (ESC_CHAR | ~('"' |'\\'|'\n'))* '"'
  | '\'' (ESC_CHAR | ~('\''|'\\'|'\n'))* '\'')
  // Remove quotes
  {this.setText(this.getText().substring(1, this.getText().length-1));}
; 


WS : (' '|'\t'|'\r'|'\n')+ {$channel=HIDDEN;} ;
