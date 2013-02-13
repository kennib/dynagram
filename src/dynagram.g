grammar dynagram;
options {
  language=JavaScript;
  output=AST;
}

tokens {
  ACTION;
  ATTRIBUTE;
  BLOCK;
  TYPE;

  CASE_ACTION;
  ATTR_ACTION;
}

@lexer::members {
  previousIndents = 0;
  indentLevel = 0;

  this.jump = function(ttype) {
    indentLevel += (ttype == this.DEDENT ? -1 : 1);
    
    var indent = '';
    for (var i=0; i<indentLevel; i++) indent += '  ';

    var level = new org.antlr.runtime.CommonToken(ttype, '\n'+indent);
    level.setLine(this.getLine());
    this.emit(level);
  }
}


diagram:
  actions+=action+
  -> ^(BLOCK $actions+)
;

block:
  INDENT actions+=action+ (DEDENT|EOF)
  -> ^(BLOCK $actions+)
;


/*****************************
* Actions
******************************/

action:
    act=verb
    PREPOSITION? (subject=noun | subject=case)
    ((PREPOSITION (objects+=noun | objects+=block))
     ((PREPOSITION|AND) (objects+=noun | objects+=block))*)?
    -> ^(ACTION $act $subject $objects*)
;

case:
  CASE_START! action CASE_END!
;


/*****************************
* Literals
******************************/

verb:
  (ID|STRING)
;

noun:
  ARTICLE? (ID|STRING|NUM|TYPE)
;

ARTICLE             : 'the'|'an'|'a' ;
AND                 : 'and'|',' ;
IF                  : 'if' ;
IN                  : 'in' ;
FOR                 : 'for' ;
THEN                : 'then' ;
WHILE               : 'while' ;
PREPOSITION         : 'with'|'between'|'of'|'to'|'from'|'as' ;
TYPE                : 'list'|'number'|'string' ;

CASE_START          : '(' ;
CASE_END            : ')' ; 

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
  SP { $channel=HIDDEN; }
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
