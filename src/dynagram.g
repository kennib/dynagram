grammar dynagram;
options {
  language=JavaScript;
  output=AST;
}

tokens {
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
    (action EOL)* -> ^(ACTION action) 
;


/*****************************
* Actions
******************************/
action:
    list_action
  | item_action
;

list_action:
    INSERT_KW item INSERT_PREP list (INSERT_POS_PREP ID)?   -> ^(INSERT list item ID)
  | REMOVE_KW item REMOVE_PREP list                         -> ^(REMOVE list item)
  | REVERSE_KW list                                         -> ^(REVERSE list)
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
item: ID;
list: ID;
opt: ID;
val: ID|NUM;

EOL                 : '.' ;
LIST_SEP            : ',' ;

INSERT_KW           : 'insert' ;
INSERT_PREP         : 'into' ;
INSERT_POS_PREP     : 'at' ;
REMOVE_KW           : 'remove' ;
REMOVE_PREP         : 'from' ;
REVERSE_KW          : 'reverse' ;

DEFINE_KW           : 'define' ;
DEFINE_PREP         : 'with' ;
OPTION_PREP         : 'as'|;

ID                  : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;
NUM                 : '0'..'9'+ ;
WS : (' '|'\t'|'\r'|'\n')+ {$channel=HIDDEN;} ;
