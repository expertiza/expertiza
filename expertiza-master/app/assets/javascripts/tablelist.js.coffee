jQuery ->
  $("#topics").sortable
    cursor: 'move',
    opacity: 0.65,
    tolerance: 'pointer'
    connectWith: ".connectedSortable"
    items: ">*:not(.sort-disabled)"

  $("#selections").sortable
    cursor: 'move',
    opacity: 0.65,
    tolerance: 'pointer'
    connectWith: ".connectedSortable"
    items: ">*:not(.sort-disabled)"
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
