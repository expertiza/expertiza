class OuterTable extends React.Component {

    constructor(props) {
        super(props)
        this.state = {
            expandedRow: [],
        }
        this.handleExpandClick = this.handleExpandClick.bind(this);
        this.populateOuterTableRows = this.populateOuterTableRows.bind(this);
    }

    handleExpandClick(id, collapsed, newParams) {
        if (collapsed) {
            this.setState((prevState) => ({
                expandedRow: prevState.expandedRow.concat([id])
            }))
            getSubFolderResults(newParams).then(function (response) {
                this.props.updateData(id, response);
            }.bind(this))
        } else {
            var index = this.state.expandedRow.indexOf(id)
            if (index > -1) {
                var list = this.state.expandedRow
                list.splice(index, 1)
                this.setState({
                    expandedRow: list
                })
            }
        }
    }

    populateOuterTableRows(rows, public, colWidthArray, colDisplayStyle) {
        Array.prototype.forEach.call(this.props.tableContent, function (entry, i) {
            if (((entry.name && entry.name.indexOf(this.props.filterText) !== -1) ||
                (entry.creation_date && entry.creation_date.indexOf(this.props.filterText) !== -1) ||
                (entry.institution && entry.institution.indexOf(this.props.filterText) !== -1) ||
                (entry.updated_date && entry.updated_date.indexOf(this.props.filterText) !== -1)) &&
                ((!public && (entry.private || entry.type === 'FolderNode')) || (public && !entry.private))) {
                rows.push(
                    <OuterTableRow
                        key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2).toString() + '_' + i}
                        id={entry.type + '_' + (parseInt(entry.nodeinfo.node_object_id) * 2).toString() + '_' + i}
                        name={entry.name}
                        institution={this.props.dataType === 'course' ? entry.institution : ''}
                        creationDate={entry.creation_date}
                        updatedDate={entry.updated_date}
                        actions={entry.actions}
                        isAvailable={entry.is_available}
                        maxTeamSize={entry.max_team_size}
                        isIntelligent={entry.is_intelligent}
                        requireQuiz={entry.require_quiz}
                        dataType={this.props.dataType}
                        private={entry.private}
                        allowSuggestions={entry.allow_suggestions}
                        rowClicked={this.handleExpandClick}
                        newParams={entry.newParams}
                        colWidthArray={colWidthArray}
                        colDisplayStyle={colDisplayStyle}
                    />
                )
                rows.push(
                    <OuterTableDetailsRow
                        key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2 + 1).toString() + '_' + i}
                        id={entry.type + '_' + (parseInt(entry.nodeinfo.node_object_id) * 2 + 1).toString() + '_' + i}
                        showElement={this.state.expandedRow.indexOf(entry.type + '_' + (parseInt(entry.nodeinfo.node_object_id) * 2).toString() + '_' + i) > -1 ? ('') : ('none')}
                        dataType={this.props.dataType}
                        children={entry.children}
                    />
                )
            } else {
                return
            }
        }.bind(this))
    }

    render() {
        var rows = []
        var colWidthArray = ['30%', '0%', '25%', '25%', '20%']
        var colDisplayStyle = {
            display: '',
            wordWrap: 'break-word'
        }
        if (this.props.dataType === 'questionnaire') {
            colWidthArray = ['70%', '0%', '0%', '0%', '30%']
            colDisplayStyle = {
                display: 'none'
            }
        }
        if (this.props.dataType === 'course') {
            colWidthArray = ['20%', '20%', '20%', '20%', '20%']
            rows.push(<TitleRow title="My Courses" />)
        } else if (this.props.dataType == 'assignment') {
            rows.push(<TitleRow title="My Assignments" />)
        }
        this.populateOuterTableRows(rows, false, colWidthArray, colDisplayStyle)
        /** this was protecting an always null field, weird TODO */
        if (this.props.showOthersWork) {
            if (this.props.dataType === 'course')
                rows.push(<TitleRow title="Others' Public Courses" />)
            if (this.props.dataType === 'assignment')
                rows.push(<TitleRow title="Others' Public Assignments" />)
            this.populateOuterTableRows(rows, true, colWidthArray, colDisplayStyle)
        }
        return (
            <table className="table table-hover" style={{ 'tableLayout': 'fixed' }}>
                <thead>
                    <tr>
                        <th width={colWidthArray[0]}>
                            Name
                            <SortToggle
                                colName="name"
                                order="normal"
                                handleUserClick={this.props.onUserClick}
                            />
                        </th>
                        {
                            this.props.dataType === 'course' &&
                            <th style={colDisplayStyle} width={colWidthArray[1]}>
                                Institution
                                <SortToggle
                                    colName="institution"
                                    order="normal"
                                    handleUserClick={this.props.onUserClick}
                                />
                            </th>
                        }
                        <th style={colDisplayStyle} width={colWidthArray[2]}>
                            Creation Date
                            <SortToggle
                                colName="creation_date"
                                order="normal"
                                handleUserClick={this.props.onUserClick}
                            />
                        </th>
                        <th style={colDisplayStyle} width={colWidthArray[3]}>
                            Updated Date
                            <SortToggle
                                colName="updated_date"
                                order="normal"
                                handleUserClick={this.props.onUserClick}
                            />
                        </th>
                        <th width={colWidthArray[4]}>Actions</th>
                    </tr>
                </thead>
                <tbody>{rows}</tbody>
            </table>
        )
    }
}
