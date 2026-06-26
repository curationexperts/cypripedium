$(document).on('show.bs.modal', '#items-modal', function (event) {
  var trigger = event.relatedTarget
  var url     = $(trigger).data('items-url')
  var spinner = $('#items-modal-spinner')
  var content = $('#items-modal-content')

  spinner.removeClass('d-none')
  content.addClass('d-none').empty()

  fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
    .then(function (response) { return response.text() })
    .then(function (html) {
      content.html(html)
      spinner.addClass('d-none')
      content.removeClass('d-none')
    })
})
