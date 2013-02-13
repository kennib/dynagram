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

    this.setAction = function(action) {
      this.setAttr(action.name, action);
    };

    this.getAction = function(actionName) {
      var action = this.getAttr(actionName);
      if (action === undefined) {
        console.log("Action", "'"+actionName+"'", "of", this, "does not exist");
        action = new dynagramAction(actionName);
        this.setAction(actionName, action);
      }

      return action;
    };

    switch(this.type) {
      case "scope":
        this.eval = function(action) {
          console.log("Evaluating", action, "at root scope.");
          action.eval(this);
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


  dynagramAction = function(name) {
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

      var _case = new dynagramAction(this.name);
      _case.cases = this.cases;
      _case.caseParams = params;

      return _case;
    };

    this.eval = function(scope) {
      console.log("Performing", "'"+this.name+"'", "action");

      this.__proto__ = scope;

      var subActions = this.cases[this.caseParams];

      for (var a in subActions) {
        var subAction = subActions[a];
        var result = subAction.eval(scope);
      }

      return result;
    };
  }

  rootScope = new dynagramObject('scope');

  console.log(this);
}


diagram:
  { var diagram = rootScope; }
  block[diagram]

  { 
    for (var a in $block.actions)
      diagram.eval($block.actions[a]);
  }
;

block [scope] returns [actions]:
  { $actions = []; }
  ^(BLOCK
    (action[scope]
    { $actions.push($action.action); })+
  )
;

action [scope] returns [action]:
  { var params = []; }
  ^(ACTION
    ( subj=noun
      { params.push($subj.word); }
    | act=action[scope]
      { params.push($act.action); }
    )

    ( obj=noun
      { params.push($obj.word); }
    | block[scope]
      { params.push($block.actions); }
    )*
  )
  {
    var action = $scope.getAction($ACTION.text);
    $action = action.getCase(params);
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
