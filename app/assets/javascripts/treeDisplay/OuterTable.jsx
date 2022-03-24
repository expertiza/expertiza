var OuterTable = React.createClass({
    getInitialState: function () {
        return {
            expandedRow: []
        }
    },
    handleExpandClick: function (id, expanded, newParams) {
        this.state.expandedRow.concat([id])
        if (expanded) {
            this.setState({
                expandedRow: this.state.expandedRow.concat([id])
            })
            // if(this.props.dataType!='assignment') {
            _this = this
            jQuery.post(
                '/tree_display/get_sub_folder_contents',
                {
                    reactParams2: newParams
                },
                function (data) {
                    _this.props.data[id.split('_')[2]]['children'] = data
                    _this.forceUpdate()
                },
                'json'
            )
            // }
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
    },
    handleSortingClick: function (colName, order) {
        this.props.onUserClick(colName, order)
    },
    render: function () {
        var _rows = []
        var _this = this
        var colWidthArray = ['30%', '0%', '0%', '0%', '25%', '25%', '20%']
        var colDisplayStyle = {
            display: ''
        }
        if (this.props) {
            if (this.props.dataType === 'questionnaire') {
                colWidthArray = ['70%', '0%', '0%', '0%', '0%', '0%', '30%']
                colDisplayStyle = {
                    display: 'none'
                }
            }
            if (this.props.dataType == 'course') {
                colWidthArray = ['20%', '0%', '0%', '20%', '20%', '20%', '20%']
                _rows.push(<TitleRow title="My Courses" />)
            } else if (this.props.dataType == 'assignment') {
                _rows.push(<TitleRow title="My Assignments" />)
            }
            jQuery.each(this.props.data, function (i, entry) {
                if (
                    ((entry.name && entry.name.indexOf(_this.props.filterText) !== -1) ||
                        (entry.creation_date && entry.creation_date.indexOf(_this.props.filterText) !== -1) ||
                        (entry.institution && entry.institution.indexOf(_this.props.filterText) !== -1) ||
                        (entry.updated_date && entry.updated_date.indexOf(_this.props.filterText) !== -1)) &&
                    (entry.private == true || entry.type == 'FolderNode')
                ) {
                    _rows.push(
                        <OuterTableRow
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
                            creation_date={entry.creation_date}
                            updated_date={entry.updated_date}
                            actions={entry.actions}
                            is_available={entry.is_available}
                            course_id={entry.course_id}
                            max_team_size={entry.max_team_size}
                            is_intelligent={entry.is_intelligent}
                            require_quiz={entry.require_quiz}
                            dataType={_this.props.dataType}
                            //this is just a hack. All current users courses are marked as private during fetch for display purpose.
                            private={entry.private}
                            allow_suggestions={entry.allow_suggestions}
                            has_topic={entry.has_topic}
                            rowClicked={_this.handleExpandClick}
                            newParams={entry.newParams}
                        />
                    )
                    _rows.push(
                        <OuterTableDetailsRow
                            key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2 + 1).toString() + '_' + i}
                            id={
                                entry.type +
                                '_' +
                                (parseInt(entry.nodeinfo.node_object_id) * 2 + 1).toString() +
                                '_' +
                                i
                            }
                            // showElement={true}
                            showElement={
                                _this.state.expandedRow.indexOf(
                                    entry.type +
                                    '_' +
                                    (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                                    '_' +
                                    i
                                ) > -1 ? (
                                    ''
                                ) : (
                                    'none'
                                )
                            }
                            dataType={_this.props.dataType}
                            children={entry.children}
                        />
                    )
                } else {
                    return
                }
            })
            /** this was protecting an always null field, weird TODO */
            if (this.props.showPublic) {
                if (this.props.dataType == 'course') {
                    _rows.push(<TitleRow title="Others' Public Courses" />)
                    jQuery.each(this.props.data, function (i, entry) {
                        if (
                            ((entry.name && entry.name.indexOf(_this.props.filterText) !== -1) ||
                                (entry.creation_date &&
                                    entry.creation_date.indexOf(_this.props.filterText) !== -1) ||
                                (entry.institution && entry.institution.indexOf(_this.props.filterText) !== -1) ||
                                (entry.updated_date &&
                                    entry.updated_date.indexOf(_this.props.filterText) !== -1)) &&
                            entry.private == false
                        ) {
                            _rows.push(
                                <OuterTableRow
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
                                    creation_date={entry.creation_date}
                                    updated_date={entry.updated_date}
                                    actions={entry.actions}
                                    is_available={entry.is_available}
                                    course_id={entry.course_id}
                                    max_team_size={entry.max_team_size}
                                    is_intelligent={entry.is_intelligent}
                                    require_quiz={entry.require_quiz}
                                    dataType={_this.props.dataType}
                                    private={entry.private}
                                    allow_suggestions={entry.allow_suggestions}
                                    has_topic={entry.has_topic}
                                    rowClicked={_this.handleExpandClick}
                                    newParams={entry.newParams}
                                />
                            )
                            _rows.push(
                                <OuterTableDetailsRow
                                    key={
                                        entry.type +
                                        '_' +
                                        (parseInt(entry.nodeinfo.id) * 2 + 1).toString() +
                                        '_' +
                                        i
                                    }
                                    id={
                                        entry.type +
                                        '_' +
                                        (parseInt(entry.nodeinfo.node_object_id) * 2 + 1).toString() +
                                        '_' +
                                        i
                                    }
                                    showElement={
                                        _this.state.expandedRow.indexOf(
                                            entry.type +
                                            '_' +
                                            (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                                            '_' +
                                            i
                                        ) > -1 ? (
                                            ''
                                        ) : (
                                            'none'
                                        )
                                    }
                                    dataType={_this.props.dataType}
                                    children={entry.children}
                                />
                            )
                        } else {
                            return
                        }
                    })
                } else if (this.props.dataType == 'assignment') {
                    _rows.push(<TitleRow title="Others' Public Assignments" />)
                    jQuery.each(this.props.data, function (i, entry) {
                        if (
                            ((entry.name && entry.name.indexOf(_this.props.filterText) !== -1) ||
                                (entry.creation_date &&
                                    entry.creation_date.indexOf(_this.props.filterText) !== -1) ||
                                (entry.updated_date &&
                                    entry.updated_date.indexOf(_this.props.filterText) !== -1)) &&
                            entry.private == false
                        ) {
                            _rows.push(
                                <OuterTableRow
                                    key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2).toString() + '_' + i}
                                    id={
                                        entry.type +
                                        '_' +
                                        (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                                        '_' +
                                        i
                                    }
                                    name={entry.name}
                                    creation_date={entry.creation_date}
                                    updated_date={entry.updated_date}
                                    actions={entry.actions}
                                    is_available={entry.is_available}
                                    course_id={entry.course_id}
                                    max_team_size={entry.max_team_size}
                                    is_intelligent={entry.is_intelligent}
                                    require_quiz={entry.require_quiz}
                                    dataType={_this.props.dataType}
                                    private={entry.private}
                                    allow_suggestions={entry.allow_suggestions}
                                    has_topic={entry.has_topic}
                                    rowClicked={_this.handleExpandClick}
                                    newParams={entry.newParams}
                                />
                            )
                            _rows.push(
                                <OuterTableDetailsRow
                                    key={
                                        entry.type +
                                        '_' +
                                        (parseInt(entry.nodeinfo.id) * 2 + 1).toString() +
                                        '_' +
                                        i
                                    }
                                    id={
                                        entry.type +
                                        '_' +
                                        (parseInt(entry.nodeinfo.node_object_id) * 2 + 1).toString() +
                                        '_' +
                                        i
                                    }
                                    showElement={
                                        _this.state.expandedRow.indexOf(
                                            entry.type +
                                            '_' +
                                            (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                                            '_' +
                                            i
                                        ) > -1 ? (
                                            ''
                                        ) : (
                                            'none'
                                        )
                                    }
                                    dataType={_this.props.dataType}
                                    children={entry.children}
                                />
                            )
                        } else {
                            return
                        }
                    })
                }
            }
        }
        if (this.props.dataType == 'course') {
            return (
                <table className="table table-hover" style={{ 'table-layout': 'fixed' }}>
                    <thead>
                        <tr>
                            <th width={colWidthArray[0]}>
                                Name
                                <SortToggle
                                    colName="name"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                            <th style={colDisplayStyle} width={colWidthArray[3]}>
                                Institution
                                <SortToggle
                                    colName="institution"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                            <th style={colDisplayStyle} width={colWidthArray[4]}>
                                Creation Date
                                <SortToggle
                                    colName="creation_date"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                            <th style={colDisplayStyle} width={colWidthArray[5]}>
                                Updated Date
                                <SortToggle
                                    colName="updated_date"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                            <th width={colWidthArray[6]}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>{_rows}</tbody>
                </table>
            )
        } else {
            return (
                <table className="table table-hover" style={{ 'table-layout': 'fixed' }}>
                    <thead>
                        <tr>
                            <th width={colWidthArray[0]}>
                                Name
                                <SortToggle
                                    colName="name"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                            <th style={colDisplayStyle} width={colWidthArray[4]}>
                                Creation Date
                                <SortToggle
                                    colName="creation_date"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                            <th style={colDisplayStyle} width={colWidthArray[5]}>
                                Updated Date
                                <SortToggle
                                    colName="updated_date"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                            <th width={colWidthArray[6]}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>{_rows}</tbody>
                </table>
            )
        }
    }
})