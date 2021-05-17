Blacklight.onLoad(function () {
  var listeners_added = false

  $('[data-autocomplete]').each((function() {
      var elem = $(this)
      var creator_label = null;

      if (elem.data('autocomplete') === "creator_id" && listeners_added === false) {
        addCreatorListener(elem.parent().parent(), elem);
        addRemoveListener(elem.parent().parent());
        listeners_added = true
      }

      if (elem.data('autocomplete') === "creator_id") {
        console.log("hit CYP conditional with parent index: " + elem.parent().index())
        var creator_identifier = elem[0].value
        if (creator_identifier) {
          console.log("creator_identifier_" + creator_identifier);
          elem.addClass("creator_identifier_" + creator_identifier);
          elem.attr("readonly", "readonly")
          let test_url = "http://localhost:3000/authorities/show/creator_authority/" + creator_identifier
          getCreatorLabel(test_url)
        }
      }
  }))
})

function addCreatorListener(grandparent, elem) {
  grandparent.on( "autocompleteselect", function( event, ui ) {
    let creator_label = ui.item.label
    $("<input class=\"form-control\" value=\"" + creator_label + "\" readonly>").appendTo(event.currentTarget);
    $(event.target).attr("readonly", "readonly")
  } );
}

function addRemoveListener(elem) {
  elem.on("click", ".remove", event => {
    let creator_label = $(event.currentTarget).parent().parent().next();
    creator_label.remove();
  })
}

function getCreatorLabel(url) {
  $.get( url, successCallback);
}

function successCallback(data) {
  creator_label = data.label;
  console.log("Creator label: " + creator_label)
  $(".creator_identifier_" + data["value"]).after($("<input class=\"form-control\" value=\"" + creator_label + "\" readonly>"));
}
