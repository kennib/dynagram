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

    switch (this.type) {
      case "list":
        this.data = [];
        this.append = function(d) {
          this.data.push(d);
        };
        this.prepend = function(d) {
          this.data.unshift(d);
        };
        break;
    }

    this.setAttr = function(attr, val) {
      this[attr] = val;
    };

    this.getAttr = function(attr) {
      return this[attr];
    };

    this.createObject = function(type, name) {
      var obj = new dynagramObject(type);
      this.setAttr(name, obj);
      return obj;
    };

    this.getAction = function(type, name) {
      var action = this.getAttr(name);
      if (action == undefined) {
        var action = new dynagramAction(type);
        action.name = name;
        action.__proto__ = this;
        this.setAttr(name, action);
      }
      
      return action;
    };

    this.eval = function() {
      console.log("No eval");
    };

    return;
  };
  
  dynagramAction = function(type) {
    this.__proto__ = new dynagramObject(type);
    this.cases = [];
    this.actions = [];
    this.action_params = [];

    this.addCase = function(params, actions, action_params) {
      this.cases.push(params);
      this.actions.push(actions);
      this.action_params.push(action_params);
    };

    this.getSubActions = function(params) {
      for (var c in this.cases) {
        var case_ = this.cases[c];

        var valid_case = true;
        for (var p in case_) {
          var case_param = case_[p];
          var param = params[p];
          if (param != case_param) {
            valid_case = false;
            break;
          }
        }
        
        if (valid_case)
          return { actions: this.actions[c], params: this.action_params[c] };
      }
    };

    this.eval = function(params) {
      var subactions = this.getSubActions(params);
      console.log("Evaluating:", this, params, subactions);
      if (subactions == undefined)
        return console.log("No actions for these parameters");

      for (var a in subactions.actions) {
        var action = subactions.actions[a];
        var action_params = subactions.params[a];
        for (var p in action_params) {
          console.log("--", this, action_params);
          action_params[p] = this.getAttr(action_params[p]);
        }
        var result = action.eval(action_params);
      }

      return result;
    };

    return;
  };

  this.root = new dynagramObject();
  
  this.root.print = new dynagramAction();
  this.root.print.eval = function(value) {
    console.log("PRINT", value);
    return value;
  };

  console.log(this);
}


diagram:
  block[this.root]
  {
    for (var a in $block.actions) {
      var action = $block.actions[a];
      var param = $block.params[a];
      var attr = this.root.getAttr(action)
      if (attr)
        attr.eval(param);
    }
  }
;

block [scope] returns [actions, params]:
  { 
    console.log('Scope: ', $scope, $block.text);
    var actions = [];
    var params = [];
  }
  ( 
    action[scope]
    {
      actions.push($action.action);
      params.push($action.params);
    }
  | control[scope]
  )+
  {
    $actions = actions;
    $params = params;
  }
;

control[scope] returns [action]:
    ^(ITERATION_WHILE condition[scope] block[scope])
  | ^(ITERATION_FOR noun noun block[scope])
  | ^(CONDITION condition[scope] block[scope])
;

condition [scope] returns [action]:
  attribute[scope]
  { $action = $scope.getAttr($attribute.attr); }
;

action [scope] returns [action, params]:
    def[scope]
    {
      $action = $def.action;
    }
  | set[scope]
    {
      $action = $set.action;
    }
  | new[scope]
    {
      $action = $new.object;
    }
  | ^(ACTION subj=noun objects+=noun*)
    {
      var params = {};
      for (var o in $objects) {
        params[o] = $objects[o].word;
      }
      params.subject = $subj.text;

      $action = $scope.getAction(undefined, $ACTION.text);
      $params = params;
    }
;

def [scope] returns [action]:
  ^(DEFINE_ACTION subj=action[scope] type? 
    { $action = $subj.action; }
    block[$action]
    { $action.addCase($subj.params, $block.actions, $block.params); }
  )
  
;

set [scope] returns [action]:
  ^(SET_ATTR subj=attribute[scope]
    t=type? block[scope]
    { 
      var objs = $subj.objects;
      var attr = $subj.attr;
      
      if (objs.length > 0) {
        console.log("Set", attr, "of", objs);
        for (var o in objs) {
          var obj = objs[o];
          for (var a in $block.actions) {
            var action = $block.actions[a];
            var param = $block.params[a];
            var result = $obj.getAttr(action).eval(param);
          }
          obj.setAttr(attr, result);
        }
      } else {
        console.log("Set", attr, "of", $scope);
        for (var a in $block.actions) {
          var action = $block.actions[a];
          var param = $block.params[a];
          var result = action.eval(param);
        }
        $scope.setAttr(attr, result);
        $action = result;
      }
    }
  )
;

new [scope] returns [type, object]:
  ^(NEW_OBJECT t=type)
  { 
    console.log('Scope: ', $scope);
    $type = $t.type;
    $object = new dynagramObject($type);
    $object.eval = function() {
      return this;
    };
  }
;

attribute [scope] returns [attr, objects]:
  ^(ATTRIBUTE subj=noun objs+=noun*)
  {
    var subj = $subj.text;
    var objs = [];
    for (var obj in $objs) {
      objs.push(this.getObject(obj.text));
    }
    if (objs.length == 0)
      obj = null;

    $attr = subj;
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

