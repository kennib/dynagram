tree grammar dynagramEvaluater;
options {
  tokenVocab=dynagram;
  ASTLabelType=CommonTree;
  language=JavaScript;
  output=AST;
}

@members {
  dynagramObject = function(name, type) {
    this.name = name;

    if (type != undefined)
      this.type = type;
    else
      this.type = 'object';

    this.setValue = function(value) {
      this.value = value;
    };
    
    this.getValue = function() {
      return this.value;
    };

    this.toString = function() {
      return this.type+':'+this.getValue();
    };

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
        this.setAction(action);
      }

      return action;
    };

    this.setObject = function(object) {
      this.setAttr(object.name, object);
    }

    this.getObject = function(name, type) {
      var object = this.getAttr(name);

      if (object === undefined) {
        console.log("Object", "'"+name+"'", "of", this, "does not exist");
        object = new dynagramObject(name, type);
        this.setObject(object);
      }

      return object;
    };

    switch(this.type) {
      case "actions":
        this.actions = [];
        this.addAction = function(action) {
          this.actions.push(action);
        };

        this.eval = function() {
          for (var a in this.actions) {
            console.log("Evaluating", this.actions[a], "at", this.name, "scope.");
            this.actions[a].eval(this);
          };
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
    this.type = 'action';
    this.cases = {};

    this.toString = function() {
      return this.type+':'+this.name;
    };
    
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
      var _case = new dynagramAction(this.name);
      _case.eval = this.eval;
      _case.cases = this.cases;
      _case.caseParams = params;

      return _case;
    };

    this.getSubActions = function(params) {
      var subActions = this.cases[params];
      if (subActions === undefined) {
        for (var c in this.cases) {
          var _case = this.cases[c];
          
          var match = true;
          for (var param in _case) {
            if (
              (_case[param].type === 'type' && params[param].type === _case[param].name)
              || params[param].getValue() != _case[param].getValue()
            ) {
              match = false;
              break;
            }
          }

          if(match)
            return _case
        }

        console.log("There is no case for", params, "in", this.name);
      
      } else {
        return subActions;
      }
    };

    this.eval = function(scope) {
      console.log("Performing", "'"+this.name+"'", "action");

      this.__proto__ = scope;

      var subActions = this.getSubActions(this.caseParams);

      for (var a in subActions) {
        var subAction = subActions[a];
        var result = subAction.eval(scope);
      }

      return result;
    };
  }

  var defineAction = new dynagramAction('define');
  defineAction.eval = function(scope) {
    var subject = this.caseParams[0];
    var object = this.caseParams[1];
    
    if (subject.type == 'action') {
      var scopeAction = scope.getAction(subject.name);
      scopeAction.addCase(object, subject.caseParams);
      console.log("Defining", subject, object, scopeAction);
      return scopeAction;
    } else {
      subject.type = object.type;
      scope.setObject(subject);
      console.log("Defining", subject, object);
      return object;
    }
  };

  rootScope = new dynagramObject('root', 'actions');
  rootScope.setAction(defineAction);

  console.log(this);
}


diagram:
  {console.log(this.input.root.getTree().toStringTree());}
  { var diagram = rootScope; }
  block[diagram]

  { $block.actions.eval(); }
  { console.log(rootScope); }
;

block [scope] returns [actions]:
  { $actions = new dynagramObject('block', 'actions'); }
  ^(BLOCK
    (action[scope]
    { $actions.addAction($action.action); })+
  )
;

action [scope] returns [action]:
  { var params = []; }
  ^(ACTION
    verb[scope]

    ( subj=noun[scope]
      { params.push($subj.object); }
    | act=action[scope]
      { params.push($act.action); }
    )

    ( obj=noun[scope]
      { params.push($obj.object); }
    | block[scope]
      { params.push($block.actions); }
    )*
  )
  { $action = $verb.action.getCase(params); }
;

verb[scope] returns [action]:
  w=(ID|STRING)
  { $action = $scope.getAction($w.text); }
;

noun[scope] returns [object]:
  ARTICLE?
  ( w=ID
    { var name = $w.text; type = "object"; var value = undefined; }
  | w=STRING
    { var name = undefined; var type = "string"; var value = $w.text; }
  | w=NUM
    { var name = undefined; var type = "number"; var value = parseInt($w.text); }
  | w=TYPE
    { var name = undefined; var type = "type"; var value = $w.text; }
  )
  {
    $object = $scope.getObject($w.text, type);
    $object.setValue(value);
  }
;
