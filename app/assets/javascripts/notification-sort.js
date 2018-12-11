$(document).on('turbolinks:load', function() {
  if ($('h1').text() === '  Notifications') {
    $('table').DataTable().order([0, 'desc']).draw()
  }
})
