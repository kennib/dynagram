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
    DEFINE_KW item (DEFINE_PREP option (LIST_SEP option)*)? -> ^(DEFINE item option*)
;

option:
;

/*****************************
* Literals
******************************/
item: ID;
list: ID;

EOL                 : '.' ;
LIST_SEP            : ',' ;

INSERT_KW           : 'insert' ;
INSERT_PREP         : 'into' ;
INSERT_POS_PREP     : 'at' ;
REMOVE_KW           : 'remove' ;
REMOVE_PREP         : 'from' ;
REVERSE_KW          : 'reverse' ;

DEFINE_KW           : 'define' ;
DEFINE_PREP         : 'as' ;

ID                  : 'a'..'z'+ ;
NUM                 : '0'..'9'+ ;
WS : (' '|'\t'|'\r'|'\n')+ {$channel=HIDDEN;} ;
