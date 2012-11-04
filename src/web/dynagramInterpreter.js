dynagramInterpreter = function(display) {
  this.display = display;
  this.items = {};
  this.lists = {};

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
    switch(tree.token.text) {
      case "ACTION":
        this.eval_tree(tree.children[0]);
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
    }
  }

  this.getItem = function(itemName) {
    if (this.items[itemName]) {
      return this.items[itemName];
    } else {
      var itemProps = {label: itemName, shape:"rect"};
      var item = this.display.createItem(itemProps);
      this.items[itemName] = item;
      return item;
    }
  }

  this.getList = function(listName) {
    if (this.lists[listName]) {
      return this.lists[listName];
    } else {
      var listProps = {};
      var listItems = [];
      var list = this.display.createItem(listProps, listItems);
      this.lists[listName] = list;
      return list;
    }
  }

};
