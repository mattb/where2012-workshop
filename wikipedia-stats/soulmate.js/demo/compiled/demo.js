(function() {
  var render, select;
  $('#search-input').focus();
  render = function(term, data, type) {
    return term;
  };
  select = function(term, data, type) {
    return console.log("Selected " + term);
  };
  $('#search-input').soulmate({
    url: 'http://localhost:8080/',
    types: ['teamband', 'event', 'venue', 'tournament'],
    renderCallback: render,
    selectCallback: select,
    minQueryLength: 1,
    maxResults: 5
  });
}).call(this);
