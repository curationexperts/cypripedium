Blacklight.onLoad(function () {
  console.log('LOADED LOCAL JAVASCRIPT');

  $('[data-autocomplete]').each((function() {
      var elem = $(this)
      if (elem.data('autocomplete') === "creator_id") {
        elem.on( "autocompleteselect", function( event, ui ) {
          let creator_label = ui.item.label
          console.log("hit CYP creator_label: " + creator_label)
        } );
      }
  }))


})
