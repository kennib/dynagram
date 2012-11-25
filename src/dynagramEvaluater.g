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
    
    this.setAttr = function(val) {
      this[attr] = val;
    };

    return;
  };

  this.objects = {};

  this.createObject = function(type) {
    return new dynagramObject(type);
  };

  this.getObject = function(obj) {
    return this.objects[obj];
  };

  this.setObject = function(obj, val) {
    this.objects[obj] = val;
  };
  
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
    def
    { $result = $def.result; }
  | set
    { $result = $set.result; }
  | new
    { $result = $new.result; }
  | ^(ACTION subj=noun object=noun*)
    { $result = this.getObject($subj.word); }
;

def returns [result]:
  ^(DEFINE_ACTION subj=action t=type? block)
  { $result = $block.result; }
;

set returns [result]:
  ^(SET_ATTR subj=attribute t=type? block)
  { 
    var value = $block.result;
    var objs = $subj.objects;
    var attr = $subj.attr;

    if (obj) {
      for (var obj in objs) {
        subj.setAttr(attr, value);
      };
    } else {
      console.log($text, $subj.attr);
      this.setObject(attr, value);
    }

    $result = value;
  }
;

new returns [type, result]:
  ^(NEW_OBJECT t=type)
  { 
    $type = $t.type;
    $result = this.createObject($type);
  }
;

attribute returns [result, attr, objects]:
  ^(ATTRIBUTE subj=noun objs+=noun*)
  {
    var subj = $subj.text;
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

