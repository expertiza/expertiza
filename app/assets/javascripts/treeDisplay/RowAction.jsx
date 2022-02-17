class RowAction extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            showDetails: true
        }
    }
    handleButtonClick = (e) => {
        e.stopPropagation()
        if (e.target.type === 'button' && e.target.name === 'more') {
            this.setState({
                showDetails: true
            })
        }
    }

    render = () => {
        let moreContent = []
        var moreButtonStyle = {
            display: '',
            padding: '0 2px'
        }
        if (node_attributes.isQuestionnaire(this.props.dataType))
            return node_attributes.questionnaire.getActions(this.handleButtonClick, this.props.parent_name)
        if (this.state.showDetails) {
            /** only running this check after the state changes to show the details (which currently is on any click on the row) */
            /** this will update after the user clicks anywhere on the row */

            moreButtonStyle.display = 'none'
            if (this.props.is_available || node_attributes.isQuestionnaire(this.props.nodeType)) {
                // check if the user id exists
                // check if the current user id matches the user/instructor id associated with a questionnaire/survey
                // show edit button only for the items which are associated to that user
                // if (app_variables.currentUserId == null || this.props.instructor_id == app_variables.currentUserId) {
                moreContent.push(
                    <span>
                        <a
                            title="Edit"
                            href={`/${node_attributes[this.props.nodeType].plural}/${parseInt(this.props.id) /
                                2}/edit`}
                        >
                            <img src="/assets/tree_view/edit-icon-24.png" />
                        </a>
                    </span>,
                    <span>
                        <a
                            title="Delete"
                            href={`/tree_display/confirm?id=${parseInt(this.props.id) /
                                2}&nodeType=${node_attributes[this.props.nodeType].plural}`}
                        >
                            <img src="/assets/tree_view/delete-icon-24.png" />
                        </a>
                    </span>
                )
            }
            moreContent.push(
                <span>
                    <a
                        title="Copy"
                        href={`/${node_attributes[this.props.nodeType].plural}/copy?assets=course&id=${parseInt(
                            this.props.id
                        ) / 2}`}
                    >
                        <img src="/assets/tree_view/Copy-icon-24.png" />
                    </a>
                </span>
            )
            if (node_attributes.isCourse(this.props.dataType))
                moreContent.push(<br />, ...node_attributes.course.getActions(parseInt(this.props.id) / 2))
        }
        if (node_attributes.isAssignment(this.props.dataType) && app_variables.homeActionShowFlag == 'true') {
            // Assignment tab starts here
            // Now is_intelligent and Add Manager related buttons have not been added into the new UI
            moreContent.push(...node_attributes.assignment.getActions(this.props))
        } else if (node_attributes.isQuestionnaire(this.props.dataType)) {
            moreContent.push(
                <span>
                    <a
                        title="View questionnaire"
                        href={'/questionnaires/view?id=' + (parseInt(this.props.id) / 2).toString()}
                    >
                        <img src="/assets/tree_view/view-survey-24.png" />
                    </a>
                </span>
            )
        }
        // if ends
        return (
            <span onClick={this.handleButtonClick}>
                <button
                    style={moreButtonStyle}
                    name="more"
                    type="button"
                    className="glyphicon glyphicon-option-horizontal"
                />
                {moreContent}
            </span>
        )
    }
}
