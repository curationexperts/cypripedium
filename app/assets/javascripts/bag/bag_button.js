var bagButton = {
  init: function (options) {
    var submitIdsForBagButton = document.querySelector('.submits-ids-for-' + options.compression + '-bag')

    if (submitIdsForBagButton) {
      submitIdsForBagButton.addEventListener('click', function (event) {
        var checkedWorks = []
        document.querySelectorAll("[name='batch_document_ids[]']").forEach((el) => { if (el.checked) { checkedWorks.push(el.value) } })
        bagButton.postBagRequest(checkedWorks, options)
        event.stopPropagation()
      }, false)
    }
  },
  postBagRequest: function (workIds, options) {
    $.post('/bag/create', { 'work_ids': workIds, 'compression': options.compression }, function (response) {})
  }
}
