class InnerTableRow extends React.Component {
    render() {
        var creationDate
        var updatedDate
        if (this.props.creationDate && this.props.updatedDate) {
            creationDate = this.props.creationDate.replace('T', '<br/>')
            updatedDate = this.props.updatedDate.replace('T', '<br/>')
        }
        var nodeTypeRaw = this.props.id.split('_')[0]
        var nodeType = nodeTypeRaw.substring(0, nodeTypeRaw.length - 4).toLowerCase()
        var id = this.props.id.split('_')[1]
        var institutionName = '-'
        if (this.props.institution && this.props.institution.length != 0) {
            institutionName = this.props.institution[0].name
        }
        return (
            <tr id={this.props.id}>
                <td width={this.props.colWidthArray[0]}>{this.props.name}</td>
                {
                    this.props.dataType == 'course' &&
                    <td style={this.props.colDisplayStyle} width={this.props.colWidthArray[1]}>
                        {institutionName}
                    </td>
                }
                <td width={this.props.colWidthArray[2]} dangerouslySetInnerHTML={{ __html: creationDate }} />
                <td width={this.props.colWidthArray[3]} dangerouslySetInnerHTML={{ __html: updatedDate }} />
                <td width={this.props.colWidthArray[4]}>
                    <RowAction
                        actions={this.props.actions}
                        key={'innerTable_' + this.props.id}
                        nodeType={nodeType}
                        parentName={this.props.name}
                        private={this.props.private}
                        isAvailable={this.props.isAvailable}
                        courseId={this.props.courseId}
                        maxTeamSize={this.props.maxTeamSize}
                        isIntelligent={this.props.isIntelligent}
                        requireQuiz={this.props.requireQuiz}
                        allowSuggestions={this.props.allowSuggestions}
                        id={id}
                        instructorId={this.props.instructorId}
                    />
                </td>
            </tr>
        )
    }
}