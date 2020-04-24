$(document).ready(function () {
    $('#dialog').dialog({
        autoOpen: false
    })
    $('#btn').click(function() {
        $("#dialog").dialog({
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
                    console.log(array)
                    $(this).dialog("close");
                }


            }
        });

        $('#dialog').dialog('open');
    });
});

