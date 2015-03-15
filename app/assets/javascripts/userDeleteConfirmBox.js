//show more than one data confirmation when attempting to delete users.
//overwrite rails default behavior
$.rails.allowAction = function(link) {
  console.log(link.attr('data-relationship'))
  console.log(link.attr('data-username'))
  if ((!link.attr('data-confirm')) || (link.attr('data-relationship') && link.attr('data-relationship') == 'false')) {
   return true;
  }
  $.rails.showConfirmDialog(link);
  return false;
};

$.rails.confirmed = function(link) {
  link.removeAttr('data-confirm');
  return link.trigger('click.rails');
};

$.rails.showConfirmDialog = function(link) {
  var html, message;
  message = link.attr('data-confirm');
  html1 = "<div class=\"modal\" id=\"dialog-confirm1\" title=\"Delete This User?\">\n  <div class=\"modal-body\">\n    <p>" + message + "</p>\n";

  html2 = "<div class=\"modal\" id=\"dialog-confirm2\" title=\"System Information\">\n  <div class=\"modal-body\">\n    <p>This user cannot be deleted. Do you want to rename the user account to <b>" + link.attr('data-username') + "_hidden</b>?</p>\n"; 

  html3 = "<div class=\"modal\" id=\"dialog-confirm3\" title=\"System Information\">\n  <div class=\"modal-body\">\n    <p>Rename successfully!!</p>\n";

  html4 = "<div class=\"modal\" id=\"dialog-confirm4\" title=\"System Information\">\n  <div class=\"modal-body\">\n    <p>You cannot delete this user!!</p>\n";

  //confirmation box style
  $(function() {
    $(html1).modal();
    $("#dialog-confirm1").dialog({
      width: 340,
      buttons: {
        "Cancel": function() {
          $( this ).dialog( "close" );
        },
        "Yes": function() {
          //return $.rails.confirmed(link);
          $( this ).dialog( "close" );
          $(html2).modal();
          $("#dialog-confirm2").dialog({
            width: 340,
            buttons: {
              "Cancel": function() {
                $( this ).dialog( "close" );
              },
              "Yes": function() {
                  
                    $('#rename').click() 

                  $( this ).dialog( "close" );
                  $(html3).modal();
                  $("#dialog-confirm3").dialog({
                    width: 340,
                    buttons: {
                      "Close": function() {
                        $( this ).dialog( "close" );
                      }
                    }
                  });
              },
              "No, delete any way!": function() {
                  $( this ).dialog( "close" );
                  $(html4).modal();
                  $("#dialog-confirm4").dialog({
                      width: 340,
                      buttons: {
                        "Close": function() {
                          $( this ).dialog( "close" );
                        }
                      }
                  });
              }
            }
          });
        }
      }
    });
  });
  return $('#dialog-confirm .confirm').on('click', function() {
    return $.rails.confirmed(link);
  });
};
