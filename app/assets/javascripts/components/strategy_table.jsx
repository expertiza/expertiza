//jQuery(document).ready(function() {

    var StrategyDropdown = React.createClass({
        render: function() {
            return(
                <td>
                    Review Strategy: <select id="dropdownlist" className="form-control">
                    <option><a href="#">Auto-Selected</a></option>
                    <option><a href="#">Instructor-Selected</a></option>
                    </select>

                    <img src="/assets/info.png" title='- Instructor-Selected: Instructor decides who reviews whom
                            - Auto-Selected: When a student is about to begin a review, Expertiza assigns that student a particular review.'/>
                </td>
            );
            $('#dropdownlist option').on('click', function(){
                strategyType = $(this).text();
                this.props.assignment_form.assignment.review_assignment_strategy = strategyType;
            });
        }
    })

    var StrategyOptions = React.createClass({
        render: function() {
            if(this.props.assignment_form.assignment.review_assignment_strategy === "Instructor-Selected"){
                return(
                    <tr id="instructor_selected_review_mapping_mechanism">
                        <td>
                            <input name="max_team_size" type="hidden" value="this.props.assignment_form.assignment.max_team_size"/>,
                            <div class="radio">
                                <label>
                                    <input type="radio" name="num_reviews_per_student" id="num_reviews_per_student" value="num_reviews_per_student" checked/>
                                        Set number of reviews done by each student
                                </label>

                            </div>
                                <div class="radio">
                                    <label>
                                        <input type="radio" name="num_reviews_per_submission" id="num_reviews_per_submission" value="num_reviews_per_submission"/>
                                            Set minimum number of reviews done for each submission
                                    </label>
                                </div>
                        </td>
                    </tr>
                );
            } else {
                return(
                    <tr id="assignment_review_topic_threshold_row">
                        <td>
                            Review topic threshold (k): <input type="text" className="form-control" defaultValue={this.props.assignment_form.assignment.review_topic_threshold} size="1"/> <img src="/assets/info.png" title='A topic is reviewable if the minimum number of reviews already done for the submissions on that topic is within k of the minimum number of reviews done on the least-reviewed submission on any topic.'/>

                            Maximum number of reviews per submission:
                            <br/>
                            <input type="text" className="form-control" defaultValue={this.props.assignment_form.assignment.max_reviews_per_submission} size="1"/>
                        </td>
                    </tr>
                );
            }
        }
    })

    var StrategyTable = React.createClass({
        render: function() {
            var moreContent = [];
            var _strategyDetails = [];
            var strategyType;

            return(
                <table>
                    <tr id='assignment_review_assignment_strategy_row'>
                        <StrategyDropdown assignment_form={this.props.assignment_form}/>
                    </tr>
                    <tr>
                        <td>
                            <StrategyOptions assignment_form={this.props.assignment_form}/>
                        </td>
                    </tr>
                </table>
            );
            $('#dropdownlist option').on('click', function(){
                strategyType = $(this).text();
                this.props.assignment_form.assignment.review_assignment_strategy = strategyType;
            });
        }
    })