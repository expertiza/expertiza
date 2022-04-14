class OuterTable extends React.Component {

    constructor(props) {
        super(props)
        this.state = {
            expandedRow: [],
        }
        this.handleExpandClick = this.handleExpandClick.bind(this);
        this.handleSortingClick = this.handleSortingClick.bind(this);
    }

    handleExpandClick(id, collapsed, newParams) {
        if (collapsed) {
            this.setState((prevState) => ({
                expandedRow: prevState.expandedRow.concat([id])
            }))
            var formData = new FormData();
            for (var dataKey in newParams) {
                if (dataKey === 'child_nodes') {
                    for (var key in newParams[dataKey]) {
                        formData.append(`reactParams2[child_nodes][${key}]`, newParams[dataKey][key]);
                    }
                }
                else {
                    formData.append(`reactParams2[${dataKey}]`, newParams[dataKey]);
                }
            }
            fetch('/tree_display/get_sub_folder_contents', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
                },
                body: serialize({
                    reactParams2: newParams
                }),
            }).then(function (response) {
                return response.json()
            }).then(function (data) {
                this.props.data[id.split('_')[2]]['children'] = data
                this.forceUpdate()
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

    handleSortingClick(colName, order) {
        this.props.onUserClick(colName, order)
    }

    render() {
        var rows = []
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
                rows.push(<TitleRow title="My Courses" />)
            } else if (this.props.dataType == 'assignment') {
                rows.push(<TitleRow title="My Assignments" />)
            }
            jQuery.each(this.props.data, function (i, entry) {
                if (
                    ((entry.name && entry.name.indexOf(this.props.filterText) !== -1) ||
                        (entry.creation_date && entry.creation_date.indexOf(this.props.filterText) !== -1) ||
                        (entry.institution && entry.institution.indexOf(this.props.filterText) !== -1) ||
                        (entry.updated_date && entry.updated_date.indexOf(this.props.filterText) !== -1)) &&
                    (entry.private == true || entry.type == 'FolderNode')
                ) {
                    rows.push(
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
                            dataType={this.props.dataType}
                            //this is just a hack. All current users courses are marked as private during fetch for display purpose.
                            private={entry.private}
                            allow_suggestions={entry.allow_suggestions}
                            has_topic={entry.has_topic}
                            rowClicked={this.handleExpandClick}
                            newParams={entry.newParams}
                        />
                    )
                    rows.push(
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
                                this.state.expandedRow.indexOf(
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
                            dataType={this.props.dataType}
                            children={entry.children}
                        />
                    )
                } else {
                    return
                }
            }.bind(this))
            /** this was protecting an always null field, weird TODO */
            if (this.props.showPublic) {
                if (this.props.dataType === 'course')
                    rows.push(<TitleRow title="Others' Public Courses" />)
                if (this.props.dataType === 'assignment')
                    rows.push(<TitleRow title="Others' Public Assignments" />)
                jQuery.each(this.props.data, function (i, entry) {
                    if (
                        ((entry.name && entry.name.indexOf(this.props.filterText) !== -1) ||
                            (entry.creation_date &&
                                entry.creation_date.indexOf(this.props.filterText) !== -1) ||
                            (this.props.dataType === 'course' && entry.institution && entry.institution.indexOf(this.props.filterText) !== -1) ||
                            (entry.updated_date &&
                                entry.updated_date.indexOf(this.props.filterText) !== -1)) &&
                        entry.private == false
                    ) {
                        rows.push(
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
                                institution={this.props.dataType === 'course' ? entry.institution : ''}
                                creation_date={entry.creation_date}
                                updated_date={entry.updated_date}
                                actions={entry.actions}
                                is_available={entry.is_available}
                                course_id={entry.course_id}
                                max_team_size={entry.max_team_size}
                                is_intelligent={entry.is_intelligent}
                                require_quiz={entry.require_quiz}
                                dataType={this.props.dataType}
                                private={entry.private}
                                allow_suggestions={entry.allow_suggestions}
                                has_topic={entry.has_topic}
                                rowClicked={this.handleExpandClick}
                                newParams={entry.newParams}
                            />
                        )
                        rows.push(
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
                                    this.state.expandedRow.indexOf(
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
                                dataType={this.props.dataType}
                                children={entry.children}
                            />
                        )
                    } else {
                        return
                    }
                }.bind(this))
            }
        }
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
                        {
                            this.props.dataType === 'course' &&
                            <th style={colDisplayStyle} width={colWidthArray[3]}>
                                Institution
                                <SortToggle
                                    colName="institution"
                                    order="normal"
                                    handleUserClick={this.handleSortingClick}
                                />
                            </th>
                        }
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
                <tbody>{rows}</tbody>
            </table>
        )
    }
}

function serialize(obj, prefix) {
    var str = [],
        p;
    for (p in obj) {
        if (obj.hasOwnProperty(p)) {
            var k = prefix ? prefix + "[" + p + "]" : p,
                v = obj[p];
            str.push((v !== null && typeof v === "object") ?
                serialize(v, k) :
                encodeURIComponent(k) + "=" + encodeURIComponent(v));
        }
    }
    return str.join("&");
}