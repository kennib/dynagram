forceDiagram = function() {
  this.init = function() {
    var width = 960,
    height = 500;

    this.color = d3.scale.category20();

    this.force = d3.layout.force()
      .gravity(.05)
      .distance(100)
      .charge(-120)
      .linkDistance(30)
      .size([width, height]);

    this.diagram = d3.select("#diagram").append("svg")
      .attr("width", width)
      .attr("height", height);

    var self = this;
    this.force.on("tick", function() {
      self.diagram.selectAll("g.node")
        .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

      self.diagram.selectAll("line.link")
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
    });
  };

  this.redraw = function() {
    var link = this.diagram.selectAll("line.link")
      .data(this.force.links(), function(d) { return d.source.id + "-" + d.target.id; });

    link.enter().insert("svg:line", "g.node")
      .attr("class", "link");

    link.exit().remove();

    var node = this.diagram.selectAll("g.node")
      .data(this.force.nodes(), function(d) { return d.name;});

    var nodeEnter = node.enter().append("svg:g")
      .attr("class", "node");

    nodeEnter.append("svg:text")
      .attr("class", "nodetext")
      .attr("dx", 12)
      .attr("dy", ".35em")
      .text(function(d) { return d.name });

    node.exit().remove();

    this.force.start()
  }
}
