jQuery ->
  $('#per_page').change ->
    window.open("/users/list?per_page=" + $('#per_page').val(), "_self")