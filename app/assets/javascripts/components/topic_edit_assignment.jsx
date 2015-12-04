
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
                </span>
            );
        }
    })


/* Source
<h1>Topics for <%= @assignment_form.assignment.name %> assignment</h1>
        <input name="assignment_form[assignment][allow_suggestions]" type="hidden" value="false"/>
        <%= check_box_tag('assignment_form[assignment][allow_suggestions]', 'true', @assignment_form.assignment.allow_suggestions) %>
        <%= label_tag('assignment_form[assignment][allow_suggestions]', 'Allow topic suggestions from students?') %>
        <br>
        <input name="assignment_form[assignment][is_intelligent]" type="hidden" value="false"/>
        <%= check_box_tag('assignment_form[assignment][is_intelligent]', 'true', @assignment_form.assignment.is_intelligent?)%>
        <%= label_tag('assignment_form[assignment][is_intelligent]', 'Enable bidding for topics?') %>
        <img src="/assets/info.png" title="This feature allow students to &quot;bid&quot; for topics.
      Instructor must specify when topics are assigned, by going to the Due Dates tab and
      entering a due date for &quot;signup&quot;."/>
        <br>
        <input name="assignment_form[assignment][can_review_same_topic]" type="hidden" value="false"/>
        <%= check_box_tag('assignment_form[assignment][can_review_same_topic]', 'true', @assignment_form.assignment.can_review_same_topic?)%>
        <%= label_tag('assignment_form[assignment][can_review_same_topic]', 'Enable authors to review others working on same topic?') %>
        <img src="/assets/info.png" title="If checked, it is possible that the auhtors review another artifact on the same topic "/>
        <br>

        <input name="assignment_form[assignment][can_choose_topic_to_review]" type="hidden" value="false"/>
        <%= check_box_tag('assignment_form[assignment][can_choose_topic_to_review]', 'true', @assignment_form.assignment.can_choose_topic_to_review?)%>
        <%= label_tag('assignment_form[assignment][can_choose_topic_to_review]', 'Allow reviewer to choose which topic to review?') %>

        <br>
        <input name="assignment_form[assignment][use_bookmark]" type="hidden" value="false"/>
        <%= check_box_tag('assignment_form[assignment][use_bookmark]', 'true', @assignment_form.assignment.use_bookmark, {:onChange => 'useBookmarkChanged()'})%>
        <%= label_tag('assignment_form[assignment][use_bookmark]', 'Allow participants to create bookmarks?') %>
        <br><br>
        <% if @assignment_form.assignment.staggered_deadline == true %>
            <%session[:duedates] = SignUpSheet.add_signup_topic(@assignment_form.assignment.id)%>
            <%= render '/sign_up_sheet/add_signup_topics_staggered.html' %>
        <% else %>
            <%= render '/sign_up_sheet/add_signup_topics.html' %>
        <% end %>
        */