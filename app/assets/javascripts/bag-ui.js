var BagUI = {
  init: function () {
    var submitIdsForBagsButton = document.querySelector('.submits-ids-for-bags')
    submitIdsForBagsButton.addEventListener('click', function () {
      var checkedWorks = []
      document.querySelectorAll("[name='batch_document_ids[]']").forEach((el) => { if (el.checked) { checkedWorks.push(el.value) } })
      console.log(checkedWorks)
      BagUI.postBagRequest(checkedWorks)
    }, false)
  },
  postBagRequest: function (workIds) {
    $.post('/bag/create', { 'work_ids': workIds }, function (response) {
      console.log(response)
    })
  }
}
