raphaelDiagram = function() {
  this.init = function() {
    this.paper = Raphael(10, 50, 500, 350);
  };
  
  this.createItem = function(properties) {
    var item = new raphaelItem(this.paper, properties);
    return item;
  }
}

raphaelItem = function(paper, props) {
  this.paper = paper;
  this.props =  props;

  this.create = function() {
    // Defaults
    this.label = null;
    this.shape = null;
    var width = 25;
    var height = 15;
    var padding = 4;
    var font = "Arial";

    // Set default position
    if (this.props.x == undefined)
      this.props.x = 50;
    if (this.props.y == undefined)
      this.props.y = 50;

    
    // Create text element
    paper.setStart();
    if (this.props.label) {
      this.label = this.paper.text(this.props.x, this.props.y, this.props.label)
        .attr('font', height+' '+font);
      width = this.label.node.getComputedTextLength();
    }
    
    // Set default size
    if (this.props.shape != 'circle') {
      if (this.props.width == undefined)
        this.props.width = width+padding;
      if (this.props.height == undefined)
        this.props.height = height+padding;
    }

    if (this.props.shape == 'circle' && this.props.radius == undefined)
      this.props.radius = width;

    // Create shape element
    if (this.props.shape) {
      var s = this.props.shape;
      if (s == 'circle') {
        this.shape = this.paper.circle(this.props.x, this.props.y, this.props.radius);
      } else if (s == 'rect') {
        this.shape = this.paper.rect(this.props.x,this.props.y,
          this.props.width, this.props.height)
          .transform("T"+(-this.props.width/2)+
            ","+(-this.props.height/2));
      }
    }
    this.set = this.paper.setFinish();
  };

  this.create();
}


function clone(obj){
  if(obj == null || typeof(obj) != 'object')
    return obj;

  var temp = obj.constructor();

  for(var key in obj)
    temp[key] = clone(obj[key]);
  
  return temp;
}
