var SongBar = function( el ) {
  this.el = $(el);
  this.title = $(el).find('p.title');
}

SongBar.prototype.render = function( title, keep ) {
  var self = this;
  self.title.html( title );
  self.el.hide();
  self.el.animate({
    height: 'toggle'
  });
  if( !keep ) {
    setTimeout( function() {
      self.el.animate({
        height: 'toggle'
      });
    }, 5000);
  }
}
