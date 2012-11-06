raphaelDiagram = function() {
  this.init = function(element) {
    // Get/set height and width of diagram
    var e = $(element);
    if (e.width()) {
      var width = e.width();
    } else {
      var width = 700;
      e.width(width);
    }
    if (e.height()) {
      var height = e.width();
    } else {
      var height = 350;
      e.height(height);
    }
    var top = 10, left = 10;

    // Create canvas
    if (element != undefined)
      this.paper = Raphael(element, 2/3*width, height);
    else
      this.paper = Raphael(left, top, width, height);

    // Create UI
    this.controls = $('<div class="dynagramUI"></div>').insertAfter(this.paper.canvas);
    // Place UI next to the canvas
    var c = $(this.paper.canvas).css('display', 'inline-block');
    c.css('vertical-align', 'top');
    this.controls.css({
      display: 'inline-block',
      'vertical-align': 'top',
      position: c.css('position'),
      top: c.css('top'),
      left: parseInt(c.css('left'))+c.width(),
      width: 1/3*width,
      height: c.height(),
    });
    // Create list for states
    this.controls.states = $('<ul class="dynagramUI-states"></ul>');
    this.controls.append(this.controls.states);
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

  this.createState = function(name) {
    var state = new raphaelState(this.paper);

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

var raphaelDefaults = {
    x: 0, y:10,
    height: 20,
};

raphaelState = function(paper) {
  this.paper = paper;
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

raphaelList = function(paper, props) {
  this.paper = paper;
  this.props =  props;
  this.items = [];

  this.create = function() {
    // Default settings
    if (this.props.padding == undefined)
      this.props.padding = 2;
    
    if (this.props.x == undefined)
      this.props.x = raphaelDefaults.x;
    if (this.props.y == undefined)
      this.props.y = raphaelDefaults.y;
    
    // Get next default positions
    raphaelDefaults.y += raphaelDefaults.height;
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
      item.set.attr({x: pos, y: this.props.y});
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
      this.props.x = raphaelDefaults.x;
    if (this.props.y == undefined)
      this.props.y = raphaelDefaults.y;

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

      // Apply attributes
      if (this.shape)
        this.shape.attr(this.props);
    }

    // Create set of elements
    this.set = this.paper.setFinish();

    // Make sure label is visible
    if (this.label)
      this.label.toFront();
    
    // Get next default positions
    raphaelDefaults.y = this.set.getBBox().y2;
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
