/**
 * Created by ferry on 3/8/16.
 */

var mImg = "/assets/arrow_down.png";
var pImg = "/assets/arrow_right.png";
$(document).ready(function(){

    // used for instructor's summary
    $('.header_class').click(function(){
        if($(this).find("img").attr("src") == mImg){
            $(this).find("img").attr("src", pImg)
        }else {
            $(this).find("img").attr("src", mImg)
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

});