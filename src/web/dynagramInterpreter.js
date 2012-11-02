dynagramInterpreter = function(diagram) {
  this.diagram = diagram;
  this.eval = function(input) {
    var cstream = new org.antlr.runtime.ANTLRStringStream(input);
    var lexer = new dynagramLexer(cstream);
    var tstream = new org.antlr.runtime.CommonTokenStream(lexer);
    var parser = new dynagramParser(tstream);
    var tree = parser.diagram().tree;

    this.eval_tree(tree);
  };

  this.eval_tree = function(tree) {
    console.log(tree);
  }
};
