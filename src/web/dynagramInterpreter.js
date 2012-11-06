dynagramInterpreter = function(display) {
  this.display = display;
  this.items = {};
  this.lists = {};
  this.listItems = {};
  this.states = {};

  this.eval = function(input) {
    var cstream = new org.antlr.runtime.ANTLRStringStream(input);
    var lexer = new dynagramLexer(cstream);
    var tstream = new org.antlr.runtime.CommonTokenStream(lexer);
    var parser = new dynagramParser(tstream);
    var tree = parser.diagram().tree;

    this.eval_tree(tree);
    return tree;
  };

  this.eval_tree = function(tree) {
    var operation = null;
    if (tree.token)
      operation = tree.token.text;

    switch(operation) {
      case "FOR_LOOP":
        var itemName = tree.children[0];
        var listName = tree.children[1];
        var actions = tree.children[2]
        var items = this.listItems[listName];
        
        // For every item in the list
        if (items != undefined) {
          for (var i=0; i<items.length; i++) {
            this.items[itemName] = items[i];
            // Do each action
            for (var a=0; a<actions.children.length; a++)
              this.eval_tree(actions.children[a]);
          }
        }
        break;

      case "ACTION":
        this.eval_tree(tree.children[0]);
        break;

      case "STATE":
        if (tree.children[0])
          var stateName = tree.children[0].getText();
        else
          var stateName = "<un-named "+this.states.length+">";

        // Create the state
        this.getState(stateName);
        break;

      case "DEFINE":
        var itemName = tree.children[0].getText();
        
        // Construct properties
        var itemProps = {label: itemName, shape:"rect"};
        var props = tree.children[1].children;
        if (props) {
          for (var p=0; p<props.length; p++) {
            var prop = props[p].children[0].getText();
            var val = props[p].children[1].getText();
            itemProps[prop] = val;
          }
        }

        // Create item
        this.items[itemName] = this.display.createItem(itemProps);
        break;

      case "LIST":
        var listName = tree.children[0].getText();

        // Get list items
        var listItems = [];
        var items = tree.children[1].children;
        if (items) {
          for (var i=0; i<items.length; i++) {
            var item  = items[i].getText();
            item = this.getItem(item);
            listItems.push(item);
          }
        }

        // Construct properties
        var listProps = {};

        // Create list
        this.lists[listName] = this.display.createList(listProps, listItems);
        this.listItems[listName] = listItems;
        break;

      case "INSERT":
        // Get list
        var listName = tree.children[0].getText();
        var list = this.getList(listName);

        // Get item
        var itemName = tree.children[1].getText();
        var item = this.getItem(itemName);

        // Get index
        if (tree.children[2])
          var index = tree.children[2].getText();

        // Insert item into list
        list.insert(item, index);
        break;

      case "REVERSE":
        // Get list
        var listName = tree.children[0].getText();
        var list = this.getList(listName);

        // Reverse list
        list.reverse();
        break;

      default:
        // Evaluate each child operation
        if (tree.children) {
          for (var c=0; c<tree.children.length; c++)
            this.eval_tree(tree.children[c]);
        }
    }
  }

  this.getState = function(stateName) {
    if (this.states[stateName]) {
      return this.states[stateName]; 
    } else {
      var state = this.display.createState(stateName);
      this.states[stateName] = state;
      return state;
    }
  };

  this.getItem = function(itemName) {
    if (this.items[itemName]) {
      return this.items[itemName];
    } else {
      var itemProps = {label: itemName, shape:"rect"};
      var item = this.display.createItem(itemProps);
      this.items[itemName] = item;
      return item;
    }
  };

  this.getList = function(listName) {
    if (this.lists[listName]) {
      return this.lists[listName];
    } else {
      var listProps = {};
      var listItems = [];
      var list = this.display.createList(listProps, listItems);
      this.lists[listName] = list;
      this.listItems[listName] = listItems;
      return list;
    }
  };

  this.reset = function() {
    // Remove items, lists etc
    this.items = {};
    this.lists = {};
    this.states = {};
    
    // Clear diagram
    diagram.clear();
  }
};
