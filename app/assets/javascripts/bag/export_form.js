// Event listener for the "Create Bag Export" button on the works index page.
// Copies selected work ids to a hidden form field and submits the form..

document.addEventListener('DOMContentLoaded', function () {
  var button = document.getElementById('create-bag-export')
  if (!button) return

  button.addEventListener('click', function (event) {
    event.preventDefault()

    var form = document.getElementById('export-form')
    document.querySelectorAll("[name='batch_document_ids[]']:checked")
      .forEach(function (el) {
        var input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'export[items][]'
        input.value = el.value
        form.appendChild(input)
      })

    form.submit()
  })
})