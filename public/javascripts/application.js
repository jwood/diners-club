/*
 * Updates the diner directions link for the specified diner
 */
updateDinerDirectionsLink = function(url) {
  var selector = document.getElementById('diner_selector');
  var newLinkHtml = '<a href="' + url + '?diner_name=' + selector.value + 
    '" target="new">Get directions for</a> ';
  Element.update('diner_directions_link', newLinkHtml);
}
