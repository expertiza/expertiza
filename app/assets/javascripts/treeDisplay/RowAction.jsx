// RowAction contains the action button in each row of a table
class RowAction extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            showDetails: true
        }
        this.handleButtonClick = this.handleButtonClick.bind(this);
    }
    handleButtonClick(e) {
        e.stopPropagation()
        if (e.target.type === 'button' && e.target.name === 'more') {
            this.setState({
                showDetails: true
            })
        }
    }

    render() {
        let moreContent = []
        var moreButtonStyle = {
            display: '',
            padding: '0 2px'
        }
        if (nodeAttributes.isQuestionnaire(this.props.dataType))
            return nodeAttributes.questionnaire.getActions(this.handleButtonClick, this.props.parentName)
        if (this.state.showDetails) {
            /** only running this check after the state changes to show the details (which currently is on any click on the row) */
            /** this will update after the user clicks anywhere on the row */

            moreButtonStyle.display = 'none'
            if (this.props.isAvailable || nodeAttributes.isQuestionnaire(this.props.nodeType)) {
                // check if the user id exists
                // check if the current user id matches the user/instructor id associated with a questionnaire/survey
                // show edit button only for the items which are associated to that user
                // if (appVariables.currentUserId == null || this.props.instructorId == appVariables.currentUserId) {
                moreContent.push(
                    <span>
                        <a
                            title="Edit"
                            href={`/${nodeAttributes[this.props.nodeType].plural}/${parseInt(this.props.id) /
                                2}/edit`}
                        >
                            <img src="/assets/tree_view/edit-icon-24.png" />
                        </a>
                    </span>,
                    <span>
                        <a
                            title="Delete"
                            href={`/tree_display/confirm?id=${parseInt(this.props.id) /
                                2}&nodeType=${nodeAttributes[this.props.nodeType].plural}`}
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
                        href={`/${nodeAttributes[this.props.nodeType].plural}/copy?assets=course&id=${parseInt(
                            this.props.id
                        ) / 2}`}
                    >
                        <img src="/assets/tree_view/Copy-icon-24.png" />
                    </a>
                </span>
            )
            if (nodeAttributes.isCourse(this.props.dataType))
                moreContent.push(<br />, ...nodeAttributes.course.getActions(parseInt(this.props.id) / 2))
        }
        if (nodeAttributes.isAssignment(this.props.dataType) && appVariables.homeActionShowFlag == 'true') {
            // Assignment tab starts here
            // Now is_intelligent and Add Manager related buttons have not been added into the new UI
            moreContent.push(...nodeAttributes.assignment.getActions(this.props))
        } else if (nodeAttributes.isQuestionnaire(this.props.dataType)) {
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
