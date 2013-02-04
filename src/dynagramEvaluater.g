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
      return this.attrs[attr];
    }

    this.getAction = function(actionName) {
      var action = this.getAttr(actionName);
      if (action === undefined) {
        console.log("Action", "'"+actionName+"'", "of", this, "does not exist");
        action = new dynagramAction(this, actionName);
        this.setAttr(actionName, action);
      }

      return action;
    };

    this.defineAction = function(action, subActions) {
      var scope = this;
      var defineAction = new dynagramAction(this);
      defineAction.name = "define";

      defineAction.eval = function() {
        var scopeAction = scope.getAction(action.name);
        scopeAction.addCase(subActions, action.caseParams);
        console.log("Defining", action, scopeAction);

        return scopeAction;
      };

      return defineAction;
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
    
    this.caseParams = undefined;

    this.addCase = function(actions, params) {
      console.log("Adding case", "'"+params+"'", actions, "to", "'"+this.name+"'"); 
      this.cases[params] = actions;
    };

    this.addCases = function(cases) {
      for (var params in cases) {
        var actions = cases[params];
        this.addCase(actions, params);
      }
    };

    this.getCase = function(params) {
      if (this.cases[params] == undefined)
        this.addCase([], params);

      var _case = new dynagramAction(this.scope, this.name);
      _case.cases = this.cases;
      _case.caseParams = params;

      return _case;
    };

    this.eval = function() {
      console.log("Performing", "'"+this.name+"'", "action");

      var subActions = this.cases[this.caseParams];

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
      var params = [$subj.word];
      
      for (var o in $objects) {
        var object = $objects[o].getText();
        params.push(object);
      }

      $action = action.getCase(params);
    }
;

def [scope] returns [action]:
  ^(DEFINE_ACTION subj=action[scope] t=type? block[scope])
  { $action = $scope.defineAction($subj.action, $block.actions); }
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

