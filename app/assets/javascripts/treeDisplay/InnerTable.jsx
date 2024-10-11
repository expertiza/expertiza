//InnerTable component is the inner table which shows up when an outer table row is clicked. Child component of OuterTableDetailsRow.
class InnerTable extends React.Component {
    render() {
        var rows = []
        var firstColText = (this.props.dataType === 'questionnaire' ? 'Item' : 'Assignment') + ' name'
        var colWidthArray = ['30%', '0%', '25%', '25%', '20%']
        var colDisplayStyle = {
            display: ''
        }
        if (this.props.dataType === 'questionnaire') {
            colWidthArray = ['30%', '0%', '20%', '20%', '30%']
            colDisplayStyle = {
                display: 'none'
            }
        } else if (this.props.dataType === 'course') {
            colWidthArray = ['20%', '20%', '20%', '20%', '20%']
        }
        if (this.props.itemsDisplayed) {
            this.props.itemsDisplayed.forEach(function (entry, i) {
                rows.push(
                    <InnerTableRow
                        key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2).toString() + '_' + i}
                        id={
                            entry.type +
                            '_' +
                            (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                            '_' +
                            i
                        }
                        name={entry.name}
                        institution={entry.institution}
                        creationDate={entry.creation_date}
                        updatedDate={entry.updated_date}
                        private={entry.private}
                        actions={entry.actions}
                        isAvailable={entry.is_available}
                        courseId={entry.course_id}
                        maxTeamSize={entry.max_team_size}
                        isIntelligent={entry.is_intelligent}
                        allowSuggestions={entry.allow_suggestions}
                        requireQuiz={entry.require_quiz}
                        dataType={this.props.dataType}
                        instructorId={entry.instructor_id}
                        colWidthArray={colWidthArray}
                        colDisplayStyle={colDisplayStyle}
                    />
                )
            }.bind(this))
        }
        return (
            <table className="table table-hover">
                <thead>
                    <tr>
                        <th width={colWidthArray[0]}>{firstColText}</th>
                        {
                            this.props.dataType === 'course' &&
                            <th style={colDisplayStyle} width={colWidthArray[1]}>
                                Institution
                            </th>
                        }
                        <th width={colWidthArray[2]}>Creation Date</th>
                        <th width={colWidthArray[3]}>Updated Date</th>
                        <th width={colWidthArray[4]}>Actions</th>
                    </tr>
                </thead>
                <tbody>{rows}</tbody>
            </table>
        )
    }
}