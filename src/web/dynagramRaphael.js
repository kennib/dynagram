raphaelDiagram = function() {
  this.init = function() {
    var width = 500, height = 350;
    var top = 10, left = 10;

    // Create canvas
    this.paper = Raphael(left, top, width, height);
    // Next default placement for an item
    this.nextPos = {x:10, y:10}

    // Create UI
    this.controls = $('<div class="dynagramUI"></div>').insertAfter(this.paper.canvas);
    // Place UI next to the canvas
    this.controls.css({
      position: 'absolute',
      top: top,
      left: left+width,
      width: width/3,
      height: height,
    });
    // Create list for states
    this.controls.states = $('<ul class="dynagramUI-states"></ul>');
    this.controls.append(this.controls.states);
  };
  
  this.createItem = function(properties) {
    var item = new raphaelItem(this, properties);
    return item;
  };

  this.createList = function(properties, items) {
    var list = new raphaelList(this, properties);
    
    // Add the items to the list
    if (items) {
      for (var i=0; i<items.length; i++)
        list.insert(items[i]);
    }

    return list;
  };

  this.createState = function(name) {
    var state = new raphaelState(this);

    // Add state to state list in the UI
    var stateUI = $('<li>'+name+'</li>');
    this.controls.states.append(stateUI);

    // State UI loads the state on click
    stateUI.click(function() {
      state.load();
    });

    return state;
  };
}

raphaelState = function(diagram) {
  this.diagram = diagram
  this.paper = diagram.paper;
  this.attrs = {};

  this.create = function() {
    // Store element attributes
    var self = this;
    this.paper.forEach(function(el) {
      self.attrs[el.id] = el.attr();
    });
  };

  this.load = function () {
    // Load element attributes
    var self = this;
    this.paper.forEach(function(el) {
      var oldState = self.attrs[el.id];
      if (oldState) {
        el.show();
        el.animate(oldState, 500);
      } else {
        el.hide();
      }
    });
  };

  this.create();
};

raphaelList = function(diagram, props) {
  // Default properties
  var listProps = {
    x: diagram.nextPos.x, y: diagram.nextPos.y,
    height: 20,
    padding: 4,
  };
  this.listProps = listProps;
  
  // Set properties
  for (var prop in props)
    listProps[prop] = listProps[prop];

  this.diagram = diagram;
  this.paper = diagram.paper;
  this.items = [];

  this.create = function() {
    // Update next diagram position
    diagram.nextPos = {x: listProps.x, y: listProps.y+listProps.height};
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
      pos += item.shapeProps.width/2;
      item.set.attr({x: pos, y: listProps.y});
      pos += item.shapeProps.width/2 + listProps.padding;
    }
  };

  this.create();
}


raphaelItem = function(diagram, props) {
  // Default properties
  var textProps = {
    x: diagram.nextPos.x, y: diagram.nextPos.y,
    height: 16,
    font: 'arial',
  };
  this.textProps = textProps;
  var shapeProps = {
    x: diagram.nextPos.x, y: diagram.nextPos.y,
    height: 20, width: 40,
    padding: 4,
    fill: 'white',
  };
  this.shapeProps = shapeProps;

  // Set properties
  for (var prop in props)
    textProps[prop] = props[prop];
  for (var prop in props)
    shapeProps[prop] = props[prop];

  this.diagram = diagram;
  this.paper = diagram.paper;

  this.create = function() {
    // Create set of elements
    this.paper.setStart();
    
    // Create text element
    if (textProps.label) {
      this.label = this.paper.text(textProps.x, textProps.y, textProps.label)
        .attr(textProps)
        .attr('font', textProps.height+' '+textProps.font);
      shapeProps.width = this.label.node.getComputedTextLength() + shapeProps.padding;
    }
    
    if (shapeProps.shape == 'circle' && shapeProps.radius == undefined)
      shapeProps.radius = width;

    // Create shape element
    if (shapeProps.shape) {
      var s = shapeProps.shape;
      if (s == 'circle') {
        this.shape = this.paper.circle(shapeProps.x, shapeProps.y, shapeProps.radius);
      } else if (s == 'rect') {
        this.shape = this.paper.rect(shapeProps.x, shapeProps.y,
          shapeProps.width, shapeProps.height)
          .transform("T"+(-shapeProps.width/2)+
            ","+(-shapeProps.height/2));
      }

      // Apply attributes
      if (this.shape)
        this.shape.attr(shapeProps);
    }

    // Create set of elements
    this.set = this.paper.setFinish();

    // Make sure label is visible
    if (this.label)
      this.label.toFront();
    
    // Update next diagram position
    var bbox =  this.set.getBBox();
    diagram.nextPos = {x: bbox.x, y: bbox.y2};
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
