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




//1781
jQuery(function(){


jQuery( window ).resize(function() {
    var rows = jQuery(".jsgrid-grid-body").find("tr")

    var rowSize = rows.length

    jQuery(".jsgrid-grid-body").css("height",rowSize*30+"px")
});


jQuery('.jsgrid-header-row th:first-child, .jsgrid-filter-row td:first-child, .jsgrid-insert-row td:first-child, .jsgrid-grid-body tr td:first-child')
.css({
position: "absolute",
left: "1px"
});
jQuery('.jsgrid-grid-header, .jsgrid-grid-body').css('margin-left', '100px');


var assignmentId = jQuery("#jsGrid").data("assignmentid");


jQuery("#jsGrid").jsGrid("option", "width","600px");
jQuery("#jsGrid").jsGrid("option", "height","600px");

jQuery("#jsGrid").jsGrid({  
                height: "100%",
                width: "100%",

                filtering: true,
                inserting: true,
                editing: true,
                sorting: true,
                paging: true,
                

                autoload: true,
                pageSize: 20,
                pageButtonCount: 5,
                loadonce: true,
                updateOnResize: true,
                
                deleteConfirm: "Do you really want to delete client?",
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

                                var rows = jQuery(".jsgrid-grid-body").find("tr")
                                console.log(rows.length)
                                var rowSize = rows.length

                                jQuery(".jsgrid-grid-body").css("height",rowSize*20+"px")
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

                              data.resolve(response);
                        });
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

                              data.resolve(response);
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



                
            /*        
                data : [
                    {name : "raga" , age : 24 , address : "avery close"}

                ],
               */


                fields: [
                    { name: "topic_identifier", type: "text" ,title: "Topic #" },
                    { name: "topic_name", type: "text" ,title: "Topic name(s)",
                        itemTemplate: function(value,topic) {
                            return $("<a>").attr("href", topic.link).text(value);
                        } , filtering: true 




                },
                    { name: "category", type: "text",title: "Test category" },
                    { name: "max_choosers", type: "text" ,title: "Num of Slots"},
                    { name: "link", type: "text",title: "Topic Link" ,width :"auto" },
                    { name: "description", type: "text",title: "Topic Description" },
                    { type: "control",                      
                        editButton: true,                               // show edit button
                        deleteButton: true,                             // show delete button
                        clearFilterButton: true,                        // show clear filter button
                        modeSwitchButton: true,                         // show switching filtering/inserting button

                     }
                   
                ]
            });

});

// 1781 Ajax JSGrid Components

   /* 

    */