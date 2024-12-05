var bagButton = {
  bindClick: function (options) {
    var buttonSelector = '.submits-ids-for-' + options.compression + '-bag'

    $(document).off('click', buttonSelector, function () {}).on('click', buttonSelector, function () {
      var checkedWorks = []
      $("[name='batch_document_ids[]']").each(function (index, el) {
        if (el.checked) { checkedWorks.push(el.value) }
      })
      bagButton.postBagRequest(checkedWorks, options)
    })
  },
  postBagRequest: function (workIds, options) {
    if (workIds.length > 0) {
      $.post('/bag/create', { 'work_ids': workIds, 'compression': options.compression }, function (response) {
      })
    }
  }
}

bagButton.bindClick({'compression': 'zip'})