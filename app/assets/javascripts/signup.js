function showHideTeamAndMembers(numTeams){
    var element = document.getElementById('teamsAndMembers');
    var show = element.innerHTML == 'Hide all teams';
    if (show){
        element.innerHTML='Show all teams';
    }else{
        element.innerHTML='Hide all teams';
    }
    toggleTeamsAndMembers(numTeams);
}

function toggleTeamsAndMembers(numTeams) {
    for(var i=1; i<=numTeams; i++){
        var elem = document.getElementById(i.toString() + "_myDiv");
        if (elem.style.display == 'none') {
            elem.style.display = '';
        } else {
            elem.style.display = 'none';
        }
    }
}

function toggleSingleTeamAndMember(i) {
    var elem = document.getElementById(i.toString() + "_myDiv");
    if (elem.style.display == 'none') {
        elem.style.display = '';
    } else {
        elem.style.display = 'none';
    }
}

jQuery("input[id^='due_date_']").datetimepicker({
    dateFormat: 'yy/mm/dd',
    timeFormat: 'HH:mm:ss',
    controlType: 'select',
    timezoneList: [
        { value: -000, label: 'GMT'},
        { value: -300, label: 'Eastern'},
        { value: -360, label: 'Central' },
        { value: -420, label: 'Mountain' },
        { value: -480, label: 'Pacific' }
    ]
});






// after document is ready
//1781
jQuery(function(){





jQuery('.jsgrid-header-row th:first-child, .jsgrid-filter-row td:first-child, .jsgrid-insert-row td:first-child, .jsgrid-grid-body tr td:first-child')
.css({
position: "absolute",
left: "1px"
});
jQuery('.jsgrid-grid-header, .jsgrid-grid-body').css('margin-left', '100px');






var assignmentId = jQuery("#jsGrid").data("assignmentid");

jQuery("#jsGrid").jsGrid({  
                width: "100%",
                height : "auto",

                filtering: false,
                inserting: true,
                editing: true,
                sorting: true,
                paging: true,

                autoload: true,
                updateOnResize : true,
                

                
                deleteConfirm: "Do you really want to delete the Topic?",
                controller: {
                    loadData: function (filter) {

                   
                    var data = $.Deferred();
                        $.ajax({
                            type: "GET",
                            contentType: "application/json; charset=utf-8",
                            url: "/sign_up_sheet/"+jQuery("#jsGrid").data("assignmentid")+"/load_add_signup_topics",
                              // url: "/sign_up_sheet/847/load_add_signup_topics",
                            dataType: "json"
                            }).done(function(response){
                               
                               var sign_up_topics =  response.sign_up_topics;
                               data.resolve(sign_up_topics);
                        }).fail(function(response){
                             alert("Issue on Loading Topics");
                             data.resolve(respomse);
                        });
                    return data.promise();
                    },


                    insertItem: function (topic) {
                    console.log("testing")
                    console.log(topic)   
                    topic.id = jQuery("#jsGrid").data("assignmentid")

                     var data = $.Deferred();
                        $.ajax({
                            type: "POST",
                            url: "/sign_up_sheet/",
                              // url: "/sign_up_sheet/847/load_add_signup_topics",
                            data: topic
                            }).done(function(response){
                              jQuery("#jsGrid").jsGrid("loadData");
                              data.resolve(response);
                        }).fail(function(response){
                            alert("Issue on inserting Topic");
                            data.resolve(response);
                        }
                        );
                    return data.promise();
                    },


                    updateItem: function (topic) {
                    console.log("testing")
                    console.log(topic)
                    

                    var data = $.Deferred();
                        $.ajax({
                            type: "PUT",
                            url: "/sign_up_sheet/"+topic.id,
                              // url: "/sign_up_sheet/847/load_add_signup_topics",
                            data: topic
                            }).done(function(response){
                              jQuery("#jsGrid").jsGrid("loadData");
                              data.resolve(response);

                        }).fail(function(response){
                             alert("Issue on Update Topic");
                            data.resolve(previousItem);
                        });
                    return data.promise();
                    },


                    deleteItem: function(item) {
                        return $.ajax({
                            type: "DELETE",
                            url: "/sign_up_sheet/" + item.id
                        });
                    }
                },




                fields: [
                      {
                       title : "Actions",
                       type: "control",                      
                        editButton: true,                               // show edit button
                        deleteButton: true,     
                        searching : false,
                         filtering: false,                         // show delete button
                      //  clearFilterButton: true,                        // show clear filter button
                        modeSwitchButton: false,                         // show switching filtering/inserting button
                        width : "2%"
                        
                        
                 }  ,
                    { name: "topic_identifier", type: "text" ,title: "Topic #",width : "1.5%" ,  validate: { 
                        validator: "required" ,
                        message : "Topic Number should not be empty " }

                },
                    { name: "topic_name", type: "text" ,title: "Topic name(s)",width : "5%" ,  validate: { 
                        validator: "required" ,
                        message : "Topic Name should not be empty " },
                        itemTemplate: function(value,topic) {

                            if(topic.link !=null && topic.link != "")
                            {
                            var linkText =  $("<a>").attr("href", topic.link).text(value);
                            }
                            else
                            {
                            var linkText =  $("<span>").text(value);
                           // console.log("value : "+value, " link : "+topic.link)
                            }

                            var signupUrl = "/sign_up_sheet/signup_as_instructor?assignment_id=" + assignmentId + "&topic_id="+topic.id;
                            var signUpUser = $("<a>").attr("href", signupUrl);

                            var signUpUserImage = $("<img>").attr({src: "/assets/signup-806fc3d5ffb6923d8f5061db243bf1afd15ec4029f1bac250793e6ceb2ab22bf.png"
                            , title: "Sign Up Student" 
                            , alt: "Signup"});



                            
                            //participants
                            var participants_temp = topic.partipants;
                            if(participants_temp == null)
                                participants_temp = []

                            var participants_div = $("<div>");


                            for(var p = 0 ; p < participants_temp.length ; p ++)
                            {
                                
                                var current_participant = participants_temp[p];
                                var text = $("<span>");
                                text.html(current_participant.user_name_placeholder);

                                var dropStudentUrl = "/sign_up_sheet/delete_signup_as_instructor/" + current_participant.team_id + "?topic_id="+topic.id;
                                
                                var dropStudentAnchor = $("<a>").attr("href", dropStudentUrl);
                               
                                var dropStudentImage = $("<img>").attr({src: "/assets/delete_icon.png"
                                 , title: "Drop Student" 
                                 , alt: "Drop Student Image"});

                                participants_div.append(text).append(dropStudentAnchor.append(dropStudentImage));


                            }



                            return $("<div>").append(linkText).append(signUpUser.append(signUpUserImage)).append(participants_div);




                       //     return $("<a>").attr("href", topic.link).text(value);
                        } , filtering: true 




                },
                    { name: "category", type: "text",title: "Topic category" ,width : "5%"},
                    { name: "max_choosers", type: "text" ,title: "# Slots" ,width : "2%",
                        validate: {
                        message: "Choose Num of slots greater than or equal to 1",
                        validator: function(value, item) {
                        return value > 0;
                        }

                        }


                    },
                    { name: "slots_available", editing: false ,title: "Available Slots",width : "2%"},
                    { name: "slots_waitlisted",  editing: false  ,title: "Num on Waitlist"  , width : "2%"},

                   
                    { name: "id",title: "Book marks",width :"20%", editing: false,width :"2%",

                        itemTemplate: function(value, topic) {
                        console.log("value ",value)
                        console.log("topic ",topic)
                        var $customBookmarkAddButton = $("<a>").attr({
                            href:"/bookmarks/list/"+topic.id });
                        
                        var $BookmarkSelectButton= $("<i>").attr({class :"jsgrid-bookmark-show fa fa-bookmark", title :"View Topic Bookmarks"});


                        var $customBookmarkSetButton = $("<a>").attr({
                            href:"/bookmarks/new?id="+topic.id });
                        
                        var $BookmarkSetButton= $("<i>").attr({class :"jsgrid-bookmark-add fa fa-plus" , title :"Add Bookmark to Topic"});


                        var set1 = $customBookmarkAddButton.append($BookmarkSelectButton);
                        var set2 = $customBookmarkSetButton.append($BookmarkSetButton);

                        return $("<div>").attr("align","center").append(set1).append(set2);
                     }
                     ,filtering: true 
                      },
                  { name: "link", type: "text",title: "Topic Link" ,width :"12%" },
                    { name: "description", type: "textarea",title: "Topic Description",width :"12%" }
                   
                ],
                // for freezing the first column
                onItemUpdated: function (args) {
                UpdateColPos(1);
                },
                onItemEditing: function (args) {
                setTimeout(function () { UpdateColPos(1); }, 1);
                },
                onRefreshed: function (args) {
                UpdateColPos(1);
                },
                 onItemUpdating: function(args) {
                  previousItem = args.previousItem;
                 },

            }); // jsgrid
//freezing columns
$('.jsgrid-grid-body').scroll(function () {
    UpdateColPos(1);
});

function UpdateColPos(cols) {
    var left = $('.jsgrid-grid-body').scrollLeft() < $('.jsgrid-grid-body .jsgrid-table').width() - $('.jsgrid-grid-body').width() + 16
        ? $('.jsgrid-grid-body').scrollLeft() : $('.jsgrid-grid-body .jsgrid-table').width() - $('.jsgrid-grid-body').width() + 16;
    $('.jsgrid-header-row th:nth-child(-n+' + cols + '), .jsgrid-filter-row td:nth-child(-n+' + cols + '), .jsgrid-insert-row td:nth-child(-n+' + cols + '), .jsgrid-grid-body tr td:nth-child(-n+' + cols + ')')
        .css({
            "position": "relative",
            "left": left
        });
}



});

// 1781 Ajax JSGrid Components

   /* 

    */