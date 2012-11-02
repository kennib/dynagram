dynagramInterpreter = function(display) {
  this.display = display;
  this.items = {};

  this.eval = function(input) {
    var cstream = new org.antlr.runtime.ANTLRStringStream(input);
    var lexer = new dynagramLexer(cstream);
    var tstream = new org.antlr.runtime.CommonTokenStream(lexer);
    var parser = new dynagramParser(tstream);
    var tree = parser.diagram().tree;

    this.eval_tree(tree);
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
    }
  }
};
