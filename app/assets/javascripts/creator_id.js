Blacklight.onLoad(function () {
  var listeners_added = false
  $('[data-autocomplete]').each((function() {
      var elem = $(this)

      if (elem.data('autocomplete') === "creator_id" && listeners_added === false) {
        console.log("hit CYP conditional with parent index: " + elem.parent().index())
        addCreatorListener(elem.parent().parent());
        addRemoveListener(elem.parent().parent());
        listeners_added = true
      }
  }))
})

function addCreatorListener(elem) {
  elem.on( "autocompleteselect", function( event, ui ) {
    let creator_label = ui.item.label
    $("<input class=\"form-control\" value=\"" + creator_label + "\" readonly>").appendTo(event.currentTarget);
  } );
}

function addRemoveListener(elem) {
  elem.on("click", ".remove", event => {
    let creator_label = $(event.currentTarget).parent().parent().next();
    creator_label.remove();
  })
}
