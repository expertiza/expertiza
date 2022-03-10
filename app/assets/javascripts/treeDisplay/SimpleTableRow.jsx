class SimpleTableRow extends React.Component {
    render() {
        var creationDate
        var updatedDate
        var colWidthArray = ['30%', '0%', '0%', '0%', '25%', '25%', '20%']
        var colDisplayStyle = {
            display: ''
        }
        if (this.props.dataType === 'questionnaire') {
            colWidthArray = ['30%', '0%', '0%', '0%', '20%', '20%', '30%']
            colDisplayStyle = {
                display: 'none'
            }
        } else if (this.props.dataType === 'course') {
            colWidthArray = ['20%', '0%', '0%', '20%', '20%', '20%', '20%']
        }
        if (this.props.creationDate && this.props.updatedDate) {
            creationDate = this.props.creationDate.replace('T', '<br/>')
            updatedDate = this.props.updatedDate.replace('T', '<br/>')
        }
        var nodeTypeRaw = this.props.id.split('_')[0]
        var nodeType = nodeTypeRaw.substring(0, nodeTypeRaw.length - 4).toLowerCase()
        var id = this.props.id.split('_')[1]
        var institution_name = '-'
        if (typeof this.props.institution !== 'undefined' && this.props.institution.length != 0) {
            institution_name = this.props.institution[0].name
        }
        return (
            <tr id={this.props.id}>
                <td width={colWidthArray[0]}>{this.props.name}</td>
                {
                    this.props.dataType == 'course' &&
                    <td style={colDisplayStyle} width={colWidthArray[3]}>
                        {institution_name}
                    </td>
                }
                <td width={colWidthArray[4]} dangerouslySetInnerHTML={{ __html: creationDate }} />
                <td width={colWidthArray[5]} dangerouslySetInnerHTML={{ __html: updatedDate }} />
                <td width={colWidthArray[6]}>
                    <RowAction
                        actions={this.props.actions}
                        key={'simpleTable_' + this.props.id}
                        nodeType={nodeType}
                        parentName={this.props.name}
                        private={this.props.private}
                        isAvailable={this.props.is_available}
                        courseId={this.props.course_id}
                        maxTeamSize={this.props.max_team_size}
                        isIntelligent={this.props.is_intelligent}
                        requireQuiz={this.props.require_quiz}
                        allowSuggestions={this.props.allow_suggestions}
                        id={id}
                        instructorId={this.props.instructor_id}
                    />
                </td>
            </tr>
        )
    }
}