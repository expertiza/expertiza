var ready = function() {

    // javascript
    var elements = document.getElementsByClassName("awesome_input");
    if (elements.length > 0) {
        var list = "";
        //Fetching pastebins from database
        $.ajax({
            type: "GET",
            url: "/user_pastebins", // should be mapped in routes.rb
            datatype: "json", // check more option
            success: function (data) {
                // handle response data
                list = data;
                //Calling awesome function
                if (list.length > 0) {
                    for (var i = 0; i < elements.length; i++) {
                       awesome_elements.push(awesome(elements[i], list));
                    }
                }
            }
        });
    }
};

//Used to store the currently stored awesome_elements
//When new text macros are added, these elements are reloaded with new values
var awesome_elements=[];

function awesome(element, list) {
// Show label but insert value into the input:
    return new Awesomplete(element, {
        list: list,

        filter: function (text, input) {
            var currentInput = input.match(/[^\s]*$/)[0];
            if (currentInput)
                return Awesomplete.FILTER_STARTSWITH(text, currentInput);
            else return false;
        },

        replace: function (text) {
            var before = this.input.value.match(/^.+\s\s*|/)[0];
            this.input.value = before + text.value + " ";
        }

    });
}

function addUserPastebin() {
    var short_form = $('#short_form').val();
    var long_form = $('#long_form').val();
    //Posting pastebins to database
    $.ajax({
        type: "POST",
        url: "/user_pastebins", // should be mapped in routes.rb
        data: { short_form: short_form, long_form: long_form },
        async: true,
        success: function(data){
            $( "#user-pastebin-table tbody" ).append( "<tr>" +
                "<td>" + short_form + "</td>" +
                "<td>" + long_form + "</td>" +
                "</tr>" );
            var elements = document.getElementsByClassName("awesome_input");
            if (elements.length > 0) {
                list = data;
                //Calling awesome function
                if (list.length > 0) {
                    for (var i = 0; i < awesome_elements.length; i++) {
                        awesome_elements[i].list = list;
                    }
                }
            }
        },
        error: function (data) {
            var message = $.parseJSON(data.responseText).message
            alert(message);
        },
        fail: function (data) {
            alert(data.message);
        }
    });
}

var dialog;


function show_text_macros(){
    dialog = $("#user-pastebin-form").dialog({
        modal: true,
        draggable: true,
        resizable: true,
        position: ['center', 'center'],
        show: 'blind',
        hide: 'blind',
        width: 400,
        buttons: {
            "Add Text Macros": addUserPastebin,
            Close: function () {
                dialog.dialog("close");
            }
        }
    }).show();
}

$(document).ready(ready);
$(document).on('page:change', ready);
$(document).on('turbolinks:load', ready);