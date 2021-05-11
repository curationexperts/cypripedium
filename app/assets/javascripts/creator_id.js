Blacklight.onLoad(function () {
  $('[data-autocomplete]').each((function() {
      var elem = $(this)
      if (elem.data('autocomplete') === "creator_id") {
        addCreatorListener(elem.parent().parent());
      }
  }))
})

function addCreatorListener(elem) {
  elem.on( "autocompleteselect", function( event, ui ) {
    let creator_label = ui.item.label
    console.log("CYP with creator_label: " + creator_label)
    $("<input class=\"form-control\" value=\"" + creator_label + "\" readonly>").appendTo(event.currentTarget);
  } );
}
