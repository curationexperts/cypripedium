Blacklight.onLoad(function () {
  var listeners_added = false

  $('[data-autocomplete]').each((function() {
      var elem = $(this)
      var creator_label = null;

      if (elem.data('autocomplete') === "creator_id" && listeners_added === false) {
        var div = elem.parent().parent();
        addCreatorListener(div, elem);
        addControlListener(div);
        listeners_added = true
      }

      if (elem.data('autocomplete') === "creator_id") {
        var creator_identifier = elem[0].value
        if (creator_identifier) {
          elem.addClass("creator_identifier_" + creator_identifier);
          elem.attr("readonly", "readonly")
          let creator_authority_url = "/authorities/show/creator_authority/" + creator_identifier
          getCreatorLabel(creator_authority_url)
        }
      }
  }))
})

function addCreatorListener(grandparent, elem) {
  grandparent.on( "autocompleteselect", function( event, ui ) {
    let creator_label = ui.item.label
    $("<p class=\"form-control creator_id_label\" readonly>" + creator_label + "</p>").insertAfter(event.target);
    $(event.target).attr("readonly", "readonly")
  } );
}

function addControlListener(div) {
  list = $("ul")
  list.on("change", function(event) {
    event.currentTarget
  })
}

function getCreatorLabel(url) {
  $.get( url, successCallback);
}

function successCallback(data) {
  creator_label = data.label;
  $(".creator_identifier_" + data["value"]).after($("<input class=\"form-control\" value=\"" + creator_label + "\" readonly>"));
}
