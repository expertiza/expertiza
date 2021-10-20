/**
 * Created by ferry on 3/8/16.
 */

var mImg = "/assets/expand.png";
var pImg = "/assets/collapse.png";
$(document).ready(function(){

    // toggle icon collapse
    $('.header_class').click(function(e){
        e.preventDefault();
        var a = $(this).find("img");
        if(a.attr("src") == mImg){
            a.attr("src", pImg)
        }else {
            a.attr("src", mImg)
        }
    });

    // used for student's summary
    $('.fake-link').hover(function(){
        $(this).css("color", "#2e517e");
        $(this).css("text-decoration", "underline");
    }, function(){
        $(this).css("color", "#94672d");
        $(this).css("text-decoration", "none");
    });

    $('#show_hide_summary_link').click(function(){
        if ($('#show_hide_summary_link').text() == "show review summary"){
            $('#show_hide_summary_link').html("hide review summary");
        }else
            $('#show_hide_summary_link').html("show review summary");
    });
});