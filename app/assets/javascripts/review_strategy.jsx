jQuery(document).ready(function() {


    var StrategyTable = React.createClass({
        render: function() {
            var moreContent = [];
            var _strategyDetails = [];
            var strategyType;

            moreContent.push(
                <table>
                    <tr id='assignment_review_assignment_strategy_row'>
                        <td>
                            "Review Strategy: "
                            <select id="dropdownlist" class="form-control">
                                <option><a href="#">Auto-Selected</a></option>
                                <option><a href="#">Instructor-Selected</a></option>
                            </select>

                            <img src="/assets/info.png" title='- Instructor-Selected: Instructor decides who reviews whom
                            - Auto-Selected: When a student is about to begin a review, Expertiza assigns that student a particular review.'></img>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            //{_strategyDetails}
                            <tr id="assignment_review_topic_threshold_row">
                                <td>
                                    <img src="/assets/info.png" title='A topic is reviewable if the minimum number of reviews already done for the submissions on that topic is within k of the minimum number of reviews done on the least-reviewed submission on any topic.'></img>
                                'Maximum number of reviews per submission:'
                                <input type="text" class="form-control" value={this.props.assignment_form.assignment.max_reviews_per_submission} size: "1">
                                </td>
                            </tr>
                        </td>
                    </tr>
                </table>
            );
            $('#dropdownlist option').on('click', function(){
                strategyType = $(this).text();
            });
        }
    });
    
    if (document.getElementById("review_strategy")) {
        React.render(
            React.createElement(StrategyTable),
            document.getElementById("review_strategy")
        )
    }
});