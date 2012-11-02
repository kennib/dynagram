raphaelDiagram = function() {
  this.init = function() {
    this.paper = Raphael(10, 50, 500, 350);
  };
  
  this.createItem = function(properties) {
    var item = new raphaelItem(this.paper, properties);
    return item;
  };

  this.createList = function(properties, items) {
    var list = new raphaelList(this.paper, properties);
    
    // Add the items to the list
    if (items) {
      for (var i=0; i<items.length; i++)
        list.insert(items[i]);
    }

    return list;
  };
}

raphaelList = function(paper, props) {
  this.paper = paper;
  this.props =  props;
  this.items = [];

  this.create = function() {
    // Default settings
    if (this.props.padding == undefined)
      this.props.padding = 2;
    
    if (this.props.x == undefined)
      this.props.x = 50;
    if (this.props.y == undefined)
      this.props.y = 50;
  };

  this.insert = function(item, index) {
    var len = this.items.length;
    // Make sure index is in bounds
    if (index == undefined)
      var index = len;
    else if (index > len)
      var index = len;
    else if (index < 0)
      var index = len - (Math.abs(index) % len);
    
    // Add the item to the list
    this.items.splice(index,0,item);

    this.update();
  };

  this.remove = function(item) {
    var index = this.items.indexOf(item);
    if (index != -1)
      this.items.splice(index, 1);

    this.update();
  };

  this.reverse = function() {
    this.items.reverse();

    this.update();
  };
   
  this.update = function() {
    // Update list
    var len = this.items.length;
    var pos = 0; var item;
    for(var i=0; i<len; i++) {
      item = this.items[i];
      pos += item.props.width/2;
      item.set.animate({x: pos}, 500);
      pos += item.props.width/2 + this.props.padding;
    }
  };

  this.create();
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

    // Create set of elements
    this.paper.setStart();
    
    // Create text element
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
      //Apply attributes
      if (this.shape)
        this.shape.attr(this.props);
    }

    // Create set of elements
    this.set = this.paper.setFinish();

    // Make sure label is visible
    if (this.label)
      this.label.toFront();
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
