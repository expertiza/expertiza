
function getUrl(){
        if(this.props.assignment_form.assignment.staggered_deadline === true) {
            Session.duedates = SignUpSheet.add_signup_topic(this.props.assignment_form.assignment.id);
            return(
                jQuery.get("/sign_up_sheet/add_signup_topics_staggered.html")
            );
        } else {
            return(
                jQuery.get("/sign_up_sheet/add_signup_topics.html")
            );
        }
}


    var TopicTab = React.createClass({
        render: function(){
            var header = "Topics for " + this.props.assignment_form.assignment.name + " assignment";
            return(
                <span>
                <h1><script type="text/javascript">document.write(header);</script></h1>

                    <div class="checkbox">
                        <label>
                            <input type="checkbox" value={this.props.assignment_form.assignment.allow_suggestions}/>
                                Allow topic suggestions from students
                        </label>
                    </div>
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" value={this.props.assignment_form.assignment.is_intelligent}/>
                            Enable bidding for topics
                        </label>
                        <img src="/assets/info.png" title="This feature allow students to &quot;bid&quot; for topics.
                        Instructor must specify when topics are assigned, by going to the Due Dates tab and
                        entering a due date for &quot;signup&quot;."/>
                    </div>
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" value={this.props.assignment_form.assignment.can_review_same_topic}/>
                            Enable authors to review others working on same topic
                        </label>
                        <img src="/assets/info.png" title="If checked, it is possible that the authors review another artifact on the same topic "/>
                    </div>
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" value={this.props.assignment_form.assignment.can_choose_topic_to_review}/>
                            Allow reviewer to choose which topic to review
                        </label>
                    </div>
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" value={this.props.assignment_form.assignment.use_bookmark}/>
                            Allow participants to create bookmarks
                        </label>
                    </div>
                    <br></br>
                    <script>getUrl();</script>
                </span>
            );
        }
    })


/* Source
        <% if @assignment_form.assignment.staggered_deadline == true %>
            <%session[:duedates] = SignUpSheet.add_signup_topic(@assignment_form.assignment.id)%>
            <%= render '/sign_up_sheet/add_signup_topics_staggered.html' %>
        <% else %>
            <%= render '/sign_up_sheet/add_signup_topics.html' %>
        <% end %>
        */