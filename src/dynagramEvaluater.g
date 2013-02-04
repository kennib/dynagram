tree grammar dynagramEvaluater;
options {
  tokenVocab=dynagram;
  ASTLabelType=CommonTree;
  language=JavaScript;
  output=AST;
}

@members {
  dynagramObject = function(type, value) {
    this.type = type;

    this.attrs = {};
    
    this.setAttr = function(attr, val) {
      this.attrs[attr] = val;
    };
    
    this.getAttr = function(attr) {
      var attr = this.attrs[attr];
    }

    this.getAction = function(actionName) {
      var action = this.attrs[actionName];
      if (action === undefined) {
        console.log("Action '", actionName, "' of", this, "does not exist");
        action = new dynagramAction(this, actionName);
      }

      return action;
    };

    this.defineAction = function(action) {
      var scope = this;
      var define = new dynagramAction(this);
      define.name = "define";
      define.eval = function() {
        console.log("Defining", action);
        scope.setAttr(action.name, action);
      };
      return define;
    };

    switch(this.type) {
      case "scope":
        this.eval = function(actions) {
          console.log("Evaluating scope.");
          console.log(actions);
          for (var a in actions) {
            actions[a].eval();
          }
        };
        break;

      default:
        this.eval = function() {
          return value;
        };
        break;
    }

    return;
  };

  dynagramAction = function(scope, name) {
    this.__proto__ = scope;

    this.name = name;
    this.cases = {};
    
    this.case_params = undefined;

    this.setCase = function(actions, params) {
      this.cases[params] = actions;
    };

    this.getCase = function(params) {
      var _case = new dynagramAction(this.scope, this.name);
      _case.cases = this.cases;
      _case.case_params = params;
      return _case;
    };

    this.eval = function() {
      console.log("Performing '", this.name, "' action");

      var subActions = this.cases[this.case_params];

      for (var a in subActions) {
        var subAction = subActions[a];
        var result = subAction.eval();
      }

      return result;
    };
  }

  console.log(this);
}


diagram:
  { var diagram = new dynagramObject('scope'); }
  block[diagram]
  { diagram.eval($block.actions); }
;

block [scope] returns [actions]:
  { $actions = []; }
  (
    action[scope]
    { $actions.push($action.action); }
  | control[scope]
  )+
;

action [scope] returns [action]:
     def[scope]
     { $action = $def.action; }
   | set[scope]
     { $action = $set.action; }
   | new[scope]
     { $action = $new.action; }
   | ^(ACTION subj=noun objects+=noun*)
    {
      var action = $scope.getAction($ACTION.text);
      $action = action.getCase({subject: $subj.word, objects: $objects});
    }
;

def [scope] returns [action]:
  ^(DEFINE_ACTION subj=action[scope] t=type? block[scope])
  { $action = scope.defineAction($subj.action); }
;

set [scope] returns [action]:
  ^(SET_ATTR subj=attribute[scope] t=type? block[scope])
  { $action = new dynagramAction(); /*TODO*/ }
;

new [scope] returns [action]:
  ^(NEW_OBJECT t=type)
  { $action = new dynagramAction(); /*TODO*/ }
;

control [scope]:
    ^(ITERATION_WHILE condition[scope] block[scope])
  | ^(ITERATION_FOR noun noun block[scope])
  | ^(CONDITION condition[scope] block[scope])
;

condition [scope] returns [result]:
  attribute[scope]
  { $result = $attribute.result ? true : false; }
;

attribute [scope] returns [result, attr, objects]:
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
  { $word = $w.text; }
;

noun returns [word]:
  ARTICLE? w=(ID|STRING|NUM)
  { $word = $w.text; }
;

type returns [type]:
  t=TYPE
  { $type = $t.text; }
;

