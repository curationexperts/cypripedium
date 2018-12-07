var BagUI = {
  init: function () {
    var submitIdsForZipBagButton = document.querySelector('.submits-ids-for-zip-bag')
    var submitIdsForTarBagButton = document.querySelector('.submits-ids-for-tar-bag')

    submitIdsForZipBagButton.addEventListener('click', function () {
      var checkedWorks = []
      document.querySelectorAll("[name='batch_document_ids[]']").forEach((el) => { if (el.checked) { checkedWorks.push(el.value) } })
      console.log(checkedWorks)
      BagUI.postZipBagRequest(checkedWorks)
    }, false)

    submitIdsForTarBagButton.addEventListener('click', function () {
      var checkedWorks = []
      document.querySelectorAll("[name='batch_document_ids[]']").forEach((el) => { if (el.checked) { checkedWorks.push(el.value) } })
      console.log(checkedWorks)
      BagUI.postTarBagRequest(checkedWorks)
    }, false)
  },
  postZipBagRequest: function (workIds) {
    $.post('/bag/create', { 'work_ids': workIds, 'compression': 'zip' }, function (response) {
      console.log(response)
    })
  },
  postTarBagRequest: function (workIds) {
    $.post('/bag/create', { 'work_ids': workIds, 'compression': 'tar' }, function (response) {
      console.log(response)
    })
  }
}
