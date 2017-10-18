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


jQuery(function(){

var assignmentId = jQuery("#jsGrid").data("assignmentid");

jQuery("#jsGrid").jsGrid({
                height: "80%",
                width: "100%",
                filtering: true,
                inserting: true,
                editing: true,
                sorting: true,
                paging: true,
                autoload: true,
                pageSize: 10,
                pageButtonCount: 5,
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
                        });
                    return data.promise();
                    },
                    insertItem: $.noop,
                    updateItem: $.noop,
                    deleteItem: $.noop
                },



                
            /*        
                data : [
                    {name : "raga" , age : 24 , address : "avery close"}

                ],
               */


                fields: [
                    { name: "topic_identifier", type: "text", width: 100 ,title: "Topic #" },
                    { name: "topic_name", type: "text", width: 50 ,title: "Topic name(s)"},
                    { name: "category", type: "text", width: 100 ,title: "Test category" },
                    { name: "max_choosers", type: "text", width: 20 ,title: "Num of Slots"},
                    { name: "link", type: "text", width: 100 ,title: "Topic Link"},
                    { name: "description", type: "text", width: 100 ,title: "Topic Description"},
                    { type: "control" }
                   
                ]
            });

});

// 1781 Ajax JSGrid Components

   /* 

    */