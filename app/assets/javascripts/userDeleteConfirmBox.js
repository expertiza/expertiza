//show more than one data confirmation when attempting to delete users.
//overwrite rails default behavior
$.rails.allowAction = function(link) {
  //use normal confirm dialog, when link does not have 'data-overridden' attribute.
  if (!link.attr("confirm")){
    if (link.attr('data-confirm')){
      if (link.attr('data-overridden')){
        //use special confirm dialog(delete user with relationship), when link has 'data-overridden' attribute.
        $.rails.showConfirmDialogSpecial(link);
        return false;
      }
      else{
        $.rails.showConfirmDialogNormal(link);
        return false;
      }
    }
    else{
      return true;
    }
  }
  else{
    $.rails.showConfirmDialogNormal(link);
    return false;
  }
};

$.rails.confirmed = function(link) {
  message = link.removeAttr('confirm');
  if (!message) {message = link.removeAttr('data-confirm');}
  return link.trigger('click.rails');
};

//Normal
$.rails.showConfirmDialogNormal = function(link) {
  var html, message;
  message = link.attr('confirm');
  if (!message) {message = link.attr('data-confirm');}
  html = "<div class=\"modal\" id=\"confirmationDialogNormal\" title=\"Warning\">\n  <div class=\"modal-body\">\n    <p>" + message + "</p>\n";

  $(function() {
    $(html).modal();
    $("#confirmationDialogNormal").dialog({
      buttons: [
          {
            text: "Cancel",
            click: function() {
              $( this ).dialog( "close" );
              location.reload();
            }
          },
          {
            text: "OK",
            click: function() {
              $.rails.confirmed(link);
            }
          }
      ]
    });
  });
};

//Special
$.rails.showConfirmDialogSpecial = function(link) {
  var message = link.attr('data-confirm');
  var html1 = "<div class=\"modal\" id=\"dialog-confirm1\" title=\"Delete This User?\">\n  <div class=\"modal-body\">\n    <p>" + message + "</p>\n";

  var html2 = "<div class=\"modal\" id=\"dialog-confirm2\" title=\"System Information\">\n  <div class=\"modal-body\">\n    <p>This user cannot be deleted. Do you want to rename the user account to <b>" + link.attr('data-username') + "_hidden</b>?</p>\n"; 

  var html3 = "<div class=\"modal\" id=\"dialog-confirm3\" title=\"System Information\">\n  <div class=\"modal-body\">\n    <p>Rename successfully!!</p>\n";

  var html4 = "<div class=\"modal\" id=\"dialog-confirm4\" title=\"System Information\">\n  <div class=\"modal-body\">\n    <p>You cannot delete this user!!</p>\n";

  //confirmation box style
  $(function() {
    $(html1).modal();
    $("#dialog-confirm1").dialog({
      width: 340,
      buttons: {
        "Cancel": function() {
          $( this ).dialog( "close" );
          location.reload();
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
                location.reload();
              },
              "Yes": function() {
                  
                    $('#rename').click() 

                  $( this ).dialog( "close" );
                  $(html3).modal();
                  $("#dialog-confirm3").dialog({
                    width: 340
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
                          location.reload();
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
};
