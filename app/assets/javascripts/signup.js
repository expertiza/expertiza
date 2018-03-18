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

function showHideTeamMembersInTeamsListPage(){
    var element = document.getElementById('teamsMembers');
    var show = element.innerHTML == 'Hide all team members';
    if (show){
        element.innerHTML='Show all team members';
    }else{
        element.innerHTML='Hide all team members';
    }
    toggleTeamMembersInTeamsListPage();
}

function toggleTeamMembersInTeamsListPage(){
    var trObjs = document.getElementsByName('team member');
    for (var i = 0; i < trObjs.length; i++) {
      if (trObjs[i].style.display == 'none') {
        trObjs[i].style.display = '';
      }
      else {
        trObjs[i].style.display = 'none';
      }
    }
    alternate('theTable');
    return false;
};

function toggleSingleTeamAndMember(i) {
    var elem = document.getElementById(i.toString() + "_myDiv");
    if (elem.style.display == 'none') {
        elem.style.display = '';
    } else {
        elem.style.display = 'none';
    }
}

function manageTopics(assignmentId) {
    $.getJSON({
        url: "/sign_up_sheet/retrieve_topics",
        data: {
            id: assignmentId
        },
        success: function(topics) {
            $("#manage-topics").jsGrid({
                controller: topics,
                height: "70%",
                width: "100%",
                editing: true,
                autoload: true,
                paging: true
            });
        },
        error: function(err) {
            alert(err);
        }
    });

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

/*1781
 This is used for taking care of all the JS GRID Operations which will be shown in Topics Tab of Assignment page
 JS grid information http://js-grid.com/
*/
jQuery(document).ready(function() {
    /* this is used for getting the assignment ID passed from Ruby into the Java script for making those Ajax calls*/
    function getAssignmentId() {
        return jQuery("#jsGrid").data("assignmentid");
    }

    //this is the all powerful configuration object for setting up the JS GRID Table
    jQuery("#jsGrid").jsGrid({

        //These are the configurations that are required for our JS Grid Table
        width: "100%",
        height: "auto",
        filtering: false,
        inserting: true,
        editing: true,
        sorting: true,
        paging: true,
        autoload: true,
        updateOnResize: true,
        deleteConfirm: "Do you really want to delete the Topic?",

        /* controller Object : All the CRUD functionalities of our JS GRID is taken care under this controller object*/
        controller: {
            /*This makes an Ajax call to load all the signup topics which will be rendered as a json from endpoint */
            loadData: function(filter) {
                var data = $.Deferred();
                $.ajax({
                    type: "GET",
                    contentType: "application/json; charset=utf-8",
                    url: "/sign_up_sheet/" + getAssignmentId() + "/load_add_signup_topics", // end point for making the load topics
                    dataType: "json"
                }).done(function(response) {
                    var sign_up_topics = response.sign_up_topics;
                    data.resolve(sign_up_topics);
                }).fail(function(response) {
                    alert("Issue on Loading Topics"); // If problem occurs in loading topics
                    data.resolve(response);
                });
                return data.promise();
            },

            /*This makes an Ajax call to insert a new  signup topic which will be entered by the user as topic argument */
            insertItem: function(topic) {
                topic.id = getAssignmentId() // the data to be sent through Ajax should be having the assignment id in id field
                var data = $.Deferred();
                $.ajax({
                    type: "POST",
                    url: "/sign_up_sheet/",
                    data: topic
                }).done(function(response) {
                    jQuery("#jsGrid").jsGrid("loadData");
                    data.resolve(response);
                }).fail(function(response) {
                    var responseJson = response;
                    data.resolve(response);
                    // this is the special case when user tries to set slots than slots already booked
                    if (responseJson.status == 400) {
                        jQuery(document).scrollTop(0);
                        location.reload();
                    } else
                        alert(responseJson.responseText);
                });
                return data.promise();
            },

            /*This makes an Ajax call to update a single record in our JS Grid when user makes changes to it*/
            updateItem: function(topic) {
                var data = $.Deferred();
                $.ajax({
                    type: "PUT",
                    url: "/sign_up_sheet/" + topic.id,
                    data: topic
                }).done(function(response) {
                    jQuery("#jsGrid").jsGrid("loadData");
                    data.resolve(response);
                }).fail(function(response) {
                    var responseJson = response;
                    data.resolve(previousItem);
                    // this is the special case when user tries to set slots than slots already booked
                    if (responseJson.status == 400) {
                        jQuery(document).scrollTop(0);
                        location.reload();
                    } else
                        alert(responseJson.responseText);
                });
                return data.promise();
            },

            /*This makes an Ajax call to delete a single record*/
            deleteItem: function(topic) {
                return $.ajax({
                    type: "DELETE",
                    url: "/sign_up_sheet/" + topic.id
                });
            }
        },

        /*This Object takes care of all the columns in the JS GRID Table
          All the configurations required for each column is mentioned here.
          Fields - Controls, Topic Number, Topic Category, # Slots, Available Slots, Num of Waitlist, Book mark, Topic Description, Tpic Link
            */
        fields: [{
            title: "Actions",
            type: "control",
            editButton: true,
            deleteButton: true,
            searching: false,
            filtering: false,
            deleteButtonTooltip: "Delete Topic",
            editButtonTooltip: "Edit Topic",
            editButtonClass: "jsgrid-edit-button-custom",
            deleteButtonClass: "jsgrid-delete-button-custom",
            modeSwitchButton: false,
            width: "2%"
        },
            {
                name: "topic_identifier",
                type: "text",
                title: "Topic #",
                width: "1.5%",
                validate: {
                    validator: "required",
                    message: "Topic Number should not be empty "
                }

            },
            {
                name: "topic_name",
                type: "text",
                title: "Topic name(s)",
                width: "5%",
                validate: {
                    validator: "required",
                    message: "Topic Name should not be empty "
                },

                /* this is used for customizing our Topic Names Field with details of signing up student and showing
                    details of all teams subscribed to a topic
                */
                itemTemplate: function(value, topic) {
                    /*setting a link for topic name if any link is present.*/
                    if (topic.link != null && topic.link != "") {
                        var topicLink = $("<a>").attr("href", topic.link).attr("target", "_blank").text(value);
                    } else {
                        var topicLink = $("<span>").text(value);
                    }

                    /* button for signing up to a topic */
                    var signupUrl = "/sign_up_sheet/signup_as_instructor?assignment_id=" + getAssignmentId() + "&topic_id=" + topic.id;
                    var signUpUser = $("<a>").attr("href", signupUrl);
                    var signUpUserImage = $("<img>").attr({
                        src: "/assets/signup-806fc3d5ffb6923d8f5061db243bf1afd15ec4029f1bac250793e6ceb2ab22bf.png",
                        title: "Sign Up Student",
                        alt: "Signup"
                    });
                    var signUp = signUpUser.append(signUpUserImage)

                    /* adding all participants/teams to be shown under the topic name*/
                    var participants_temp = topic.participants;
                    if (participants_temp == null)
                        participants_temp = []
                    var participants_div = $("<div>");
                    for (var p = 0; p < participants_temp.length; p++) {
                        var current_participant = participants_temp[p];
                        var text = $("<span>");
                        text.html(current_participant.user_name_placeholder);
                        var dropStudentUrl = "/sign_up_sheet/delete_signup_as_instructor/" + current_participant.team_id + "?topic_id=" + topic.id;
                        var dropStudentAnchor = $("<a>").attr("href", dropStudentUrl);
                        var dropStudentImage = $("<img>").attr({
                            src: "/assets/delete_icon.png",
                            title: "Drop Student",
                            alt: "Drop Student Image"
                        });
                        participants_div.append(text).append(dropStudentAnchor.append(dropStudentImage));
                    }
                    return $("<div>").append(topicLink).append(signUp).append(participants_div);
                },
                filtering: true
            },

            { name: "category", type: "text", title: "Topic category", width: "5%" },

            /* Validate whether the number of slots entered is greter than 0*/
            {
                name: "max_choosers",
                type: "text",
                title: "# Slots",
                width: "2%",
                validate: {
                    message: "Choose Num of slots greater than or equal to 1",
                    validator: function(value, item) {
                        return value > 0;
                    }
                }
            },

            { name: "slots_available", editing: false, title: "Available Slots", width: "2%" },

            { name: "slots_waitlisted", editing: false, title: "Num on Waitlist", width: "2%" },

            /*adding Add bookmark and View bookmark functionalities*/
            {
                name: "id",
                title: "Book marks",
                width: "20%",
                editing: false,
                width: "2%",
                itemTemplate: function(value, topic) {
                    console.log("value ", value)
                    console.log("topic ", topic)
                    var $customBookmarkAddButton = $("<a>").attr({
                        href: "/bookmarks/list/" + topic.id
                    });
                    var $BookmarkSelectButton = $("<i>").attr({ class: "jsgrid-bookmark-show fa fa-bookmark", title: "View Topic Bookmarks" });
                    var $customBookmarkSetButton = $("<a>").attr({
                        href: "/bookmarks/new?id=" + topic.id
                    });
                    var $BookmarkSetButton = $("<i>").attr({ class: "jsgrid-bookmark-add fa fa-plus", title: "Add Bookmark to Topic" });
                    var set1 = $customBookmarkAddButton.append($BookmarkSelectButton);
                    var set2 = $customBookmarkSetButton.append($BookmarkSetButton);
                    return $("<div>").attr("align", "center").append(set1).append(set2);
                },
                filtering: true
            },

            { name: "description", type: "textarea", title: "Topic Description", width: "12%" },
            { name: "link", type: "text", title: "Topic Link", width: "12%" }

        ],
        /* for freezing the first column*/
        onItemUpdated: function(args) {
            UpdateColPos(1);
        },
        onItemEditing: function(args) {
            setTimeout(function() { UpdateColPos(1); }, 1);
        },
        onRefreshed: function(args) {
            UpdateColPos(1);
        },
        onItemUpdating: function(args) {
            previousItem = args.previousItem;
        },

    }); // jsgrid
    //freezing columns



    $('.jsgrid-grid-body').scroll(function() {
        UpdateColPos(1);
    });

    /* Again used for freezing the controls column in our JS GRID*/
    function UpdateColPos(cols) {
        var left = $('.jsgrid-grid-body').scrollLeft() < $('.jsgrid-grid-body .jsgrid-table').width() - $('.jsgrid-grid-body').width() + 16 ?
            $('.jsgrid-grid-body').scrollLeft() : $('.jsgrid-grid-body .jsgrid-table').width() - $('.jsgrid-grid-body').width() + 16;
        $('.jsgrid-header-row th:nth-child(-n+' + cols + '), .jsgrid-filter-row td:nth-child(-n+' + cols + '), .jsgrid-insert-row td:nth-child(-n+' + cols + '), .jsgrid-grid-body tr td:nth-child(-n+' + cols + ')')
            .css({
                "position": "relative",
                "left": left
            });
    }



});
