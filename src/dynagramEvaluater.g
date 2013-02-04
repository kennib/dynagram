tree grammar dynagramEvaluater;
options {
  tokenVocab=dynagram;
  ASTLabelType=CommonTree;
  language=JavaScript;
  output=AST;
}

@members {
  dynagramObject = function(type) {
    this.type = type;

    this.attrs = {};
    
    this.setAttr = function(val) {
      this.attrs[attr] = val;
    };

    this.getAttr = function(val) {
      return this.attrs[attr];
    };

    return;
  };

  dynagramActionPlan = function(scope) {
    this.__proto__ = scope;

    this.cases = {};

    this.setCase = function(params, action) {
      this.cases[params] = action;
    };

    this.getCase = function(params) {
      return this.cases[params];
    };
  };

  dynagramAction = function(actionPlan, params) {
    this.__proto__ = actionPlan;

    this.params = params;
    this.subActions = this.getCase(this.params);
    
    this.eval = function() {
      for (var a in this.subactions) {
        var subAction = this.subActions[a];
        var result = subAction.eval();
      }
      return result;
    };
  }

  console.log(this);
}


diagram:
  (action|control)+
;

block returns [result]:
  (action|control)+
  { $result = $action.result; }
;

control:
    ^(ITERATION_WHILE condition block)
  | ^(ITERATION_FOR noun noun block)
  | ^(CONDITION condition block)
;

condition returns [result]:
  attribute
  { $result = $attribute.result ? true : false; }
;

action returns [result]:
  ^(ACTION subj=noun object=noun*)
  { $result = this.getObject($subj.word); }
;

attribute returns [result, attr, objects]:
  ^(ATTRIBUTE atr=noun objs+=noun*)
  {
    var subj = $atr.word.text;
    var objs = [];
    for (var obj in $objs) {
      objs.push(this.getObject(obj.text));
    }
    if (objs.length == 0)
      obj = null;

    $result = [];
    for (var obj in objs) {
      result.push(obj);
    }

    $objects = objs;
  }
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
  t=TYPE
  { $type = $t.text; }
;

