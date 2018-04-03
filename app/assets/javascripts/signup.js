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

    var tabsPanelInner = $(".ui-tabs-panel").innerWidth();

    var allFields = [{
        visible: false,
        title: "Actions",
        name: "actions",
        width: (tabsPanelInner*0.1),
        type: "control",
        editButton: false,
        deleteButton: false,
        searching: false,
        filtering: false,
        deleteButtonTooltip: "Delete Topic",
        editButtonTooltip: "Edit Topic",
        editButtonClass: "jsgrid-edit-button-custom",
        deleteButtonClass: "jsgrid-delete-button-custom",
        modeSwitchButton: false,
        headerTemplate: function() {
            return $("<button>").attr("type", "button").text("Add").addClass("add-topic-button")
                .on("click", function () {
                    showTopicDialog("Add", {});
                }).hide();
        },
        itemTemplate: function(value,item) {
            if (!item.is_finished) {
                var $result = jsGrid.fields.control.prototype.itemTemplate.apply(this, arguments);

                $(".add-topic-button").show();
                var $customEditButton = $("<button>")
                    .prop("type", "button").append($("<img />").prop("src", "/assets/edit_icon.png"))
                    .on("click", function (e) {
                        showTopicDialog("Edit", item);
                    });

                var $customDeleteButton = $("<button>")
                    .prop("type", "button").append($("<img />").prop("src", "/assets/delete_icon.png"))
                    .on("click", function (e) {
                        if (confirm("Are you sure you want to delete \"" + item.topic_name + "\"?")) {
                            jQuery("#jsGrid").jsGrid('deleteItem', item); //call deleting once more in callback
                        }
                    });

                return $("<div>").append($customEditButton).append($customDeleteButton);
            }
            return false;
        }
    },
        {
            visible: false,
            name: "topic_identifier",
            width: (tabsPanelInner*0.2),
            type: "text",
            title: "Topic #",
            validate: {
                validator: "required",
                message: "Topic Number should not be empty "
            }

        },
        {
            visible: false,
            name: "topic_name",
            width: (tabsPanelInner*0.5),
            type: "text",
            title: "Topic name(s)",
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

        { visible: false,
            width: (tabsPanelInner*0.15),
            name: "category", type: "text", title: "Topic category" },

        /* Validate whether the number of slots entered is greter than 0*/
        {
            visible: false,
            name: "max_choosers",
            width: (tabsPanelInner*0.05),
            type: "text",
            title: "# Slots",
            validate: {
                message: "Choose Num of slots greater than or equal to 1",
                validator: function(value, item) {
                    return value > 0;
                }
            }
        },

        { visible: false,
            width: (tabsPanelInner*0.05),
            name: "slots_available", editing: false, title: "Available Slots" },

        { visible: false,
            width: (tabsPanelInner*0.05),
            name: "slots_waitlisted", editing: false, title: "Num on Waitlist" },

        /*adding Add bookmark and View bookmark functionalities*/
        {
            visible: false,
            width: (tabsPanelInner*0.1),
            name: "bookmarks",
            title: "Book marks",
            editing: false,
            itemTemplate: function(value, topic) {
                console.log("value ", value)
                console.log("topic ", topic)
                if(!topic.is_finished) {
                    $(".add-topic-button").show();
                    var $customBookmarkAddButton = $("<a>").attr({
                        href: "/bookmarks/list/" + topic.id
                    });
                    var $BookmarkSelectButton = $("<i>").attr({
                        class: "jsgrid-bookmark-show fa fa-bookmark",
                        title: "View Topic Bookmarks"
                    });
                    var $customBookmarkSetButton = $("<a>").attr({
                        href: "/bookmarks/new?id=" + topic.id
                    });
                    var $BookmarkSetButton = $("<i>").attr({
                        class: "jsgrid-bookmark-add fa fa-plus",
                        title: "Add Bookmark to Topic"
                    });
                    var set1 = $customBookmarkAddButton.append($BookmarkSelectButton);
                    var set2 = $customBookmarkSetButton.append($BookmarkSetButton);
                    return $("<div>").attr("align", "center").append(set1).append(set2);
                }
                return false;
            },
            filtering: true
        },

        { visible: false,
            width: (tabsPanelInner*0.3),
            name: "description", type: "textarea", title: "Topic Description"}

    ];

    /* this is used for getting the assignment ID passed from Ruby into the Java script for making those Ajax calls*/
    function getAssignmentId() {
        return jQuery("#jsGrid").data("assignmentid");
    }

    //this is the all powerful configuration object for setting up the JS GRID Table
    jQuery("#jsGrid").jsGrid({

        //These are the configurations that are required for our JS Grid Table
        width: tabsPanelInner,
        filtering: false,
        inserting: false,
        editing: false,
        confirmDeleting: false,
        sorting: true,
        paging: true,
        autoload: true,
        updateOnResize: true,
        rowClick: function(args) {
            return false;
        },
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
                    sign_up_topics.sort(function (a, b) {
                        return a.topic_identifier < b.topic_identifier ? -1 : 1;
                    });
                    for (var topic_column_idx in response.included_topic_columns) {
                        $("#jsGrid").jsGrid("fieldOption", response.included_topic_columns[topic_column_idx], "visible", true);
                    }
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
        fields: allFields,
        /* for freezing the first column*/
        onItemUpdated: function(args) {
            // UpdateColPos(1);
        },
        onItemDeleting: function (args) {

        },
        onItemEditing: function(args) {
            //setTimeout(function() { UpdateColPos(1); }, 1);
            //setTimeout(function() { showTopicDialog("Edit",args.item); }, 1);
        },
        onRefreshed: function(args) {
            // UpdateColPos(1);
        },
        onItemUpdating: function(args) {
            previousItem = args.previousItem;
        },
        submitHandler: function(e) {
            formSubmitHandler();
        }
    }); // jsgrid
    //freezing columns

    var formSubmitHandler = $.noop();

    $("#detailsDialog").dialog({
        autoOpen: false,
        width: 400,
        buttons: {
            "Save": function() {
                formSubmitHandler();
            },
            "Close": function () {
                $("#detailsDialog").dialog("close");
            }
        }
    });

    $("#detailsForm").validate({
        rules: {
            topic_name: "required",
        },
        messages: {
            topic_name: "Please enter name",
        }
    });

    function showTopicDialog(dialogType,topic) {
        initializeTopicForm(dialogType,topic);

        formSubmitHandler = function(e) {
            saveTopicFormValuesToObject(topic);
            if(dialogType === "Add") {
                jQuery("#jsGrid").jsGrid('insertItem', topic);
            }
            else {
                jQuery("#jsGrid").jsGrid('updateItem', topic);
            }

            $("#detailsDialog").dialog("close");
        };

        $("#detailsDialog").dialog("option", "title", dialogType + " Topic")
            .dialog("open");
        $("#detailsForm").validate();
    }

    function initializeTopicForm(dialogType,topic) {
        $("#topic_identifier").val(topic.topic_identifier);
        $("#topic_name").val(topic.topic_name);
        $("#max_choosers").val(topic.max_choosers);
        $("#category").val(topic.category);
        $("#link").val(topic.link);
        $("#description").val(topic.description);
    }

    function saveTopicFormValuesToObject(topic) {

        topic.topic_identifier = $("#topic_identifier").val();
        topic.topic_name = $("#topic_name").val();
        topic.max_choosers = $("#max_choosers").val();
        topic.category = $("#category").val();
        topic.link = $("#link").val();
        topic.description = $("#description").val();
    }
});