jQuery(document).ready ($) ->
  sendUpdatedOrder = ->
    sortedIDs = $(this).sortable('toArray')

    topicIDs = sortedIDs.map (id) ->
      id.replace 'topic_', ''

    participant_id = $(this).data('participant-id')

    assignment_id = new URL($(this).data('update-url'), window.location.origin).searchParams.get('assignment_id')

    $.ajax
      type: 'POST'
      url: $(this).data('update-url')
      data:
        topic: topicIDs
        participant_id: participant_id
        assignment_id: assignment_id
      success: (response) ->
        console.log 'Selections updated successfully.'
      error: (xhr, status, error) ->
        alert 'An error occurred while saving your selections. Please try again.'
        console.error error

  $("#topics").sortable
    cursor: 'move'
    opacity: 0.65
    tolerance: 'pointer'
    connectWith: ".connectedSortable"
    items: ">*:not(.sort-disabled)"

  $("#selections").sortable
    cursor: 'move'
    opacity: 0.65
    tolerance: 'pointer'
    connectWith: ".connectedSortable"
    items: ">*:not(.sort-disabled)"
    update: sendUpdatedOrder