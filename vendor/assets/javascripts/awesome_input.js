var ready = function() {

    // javascript
    var elements = document.getElementsByClassName("awesome_input");
    if(elements.length > 0){
        var list = "";
        //Fetching pastebins from database
        $.ajax({
            type: "GET",
            url: "/user_pastebins", // should be mapped in routes.rb
            datatype:"json", // check more option
            success: function(data) {
                // handle response data
                alert("Here");
                list = data;
                //Calling awesome function
                if(list.length> 0){
                    for(var i=0; i<elements.length; i++) {
                        awesome(elements[i],list);
                    }
                }
            }
        });



    }


    function awesome(element,list){
// Show label but insert value into the input:
        new Awesomplete(element, {
            list: list,

            filter: function(text, input) {
                var currentInput = input.match(/[^\s]*$/)[0];
                if(currentInput)
                    return Awesomplete.FILTER_STARTSWITH(text, currentInput);
                else return false;
            },

            replace: function(text) {
                var before = this.input.value.match(/^.+\s\s*|/)[0];
                this.input.value = before + text.value + " ";
            }

        });
    }
};

$(document).ready(ready);
$(document).on('page:change', ready);
$(document).on('turbolinks:load', ready);