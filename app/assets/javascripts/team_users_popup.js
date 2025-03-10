$(document).ready(function () {
    $('#dialogConfirmMark').dialog({
        autoOpen: false
    })
    $('#dialogConfirmUnmark').dialog({
        autoOpen: false
    })
});

function publish_example_review(bid) {
    $("#dialogConfirmMark").dialog({
        modal: true,
        height: 600,
        width: 500,

        buttons: {
            Cancel : function () {
                $(this).dialog("close");
            },
            'Publish Sample Reviews': function() {
                var array = [];
                $("input:checkbox[name=published_assignments]:checked").each(function() {
                    array.push($(this).val());
                });
                $.ajax({
                    "url":"/sample_reviews/map/"+bid.getAttribute('data-response-id'),
                    "type":"POST",
                    "data":{
                        "assignments":array
                    },
                    "dataType":"json",
                    success:function(data, textStatus, jqXHR)
                    {
                        window.location.reload();
                    },
                });
            }}});

    $('#dialogConfirmMark').dialog('open');
}

function suppress_example_review(bid) {
    $("#dialogConfirmUnmark").dialog({
        modal: true,
        height: 600,
        width: 500,

        buttons: {
            Cancel : function () {
                $(this).dialog("close");
            },
            Yes: function() {
                var array = [];
                $("input:checkbox[name=published_assignments]:checked").each(function() {
                    array.push($(this).val());
                });

                $.ajax({
                    "url":"/sample_reviews/unmap/"+bid.getAttribute('data-response-id'),
                    "type":"POST",
                    "data":{
                        "assignments":array
                    },
                    "dataType":"json", success:function(data, textStatus, jqXHR)
                    {
                        window.location.reload();
                    },
                });
            }}});

    $('#dialogConfirmUnmark').dialog('open');
}

