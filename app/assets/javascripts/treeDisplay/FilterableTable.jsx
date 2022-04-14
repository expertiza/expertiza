/** beta branch isnt getting a prop related to the data to be displayed in the dropdown */
var FilterableTable = React.createClass({
    getInitialState: function () {
        return {
            filterText: '',
            privateCheckbox: false,
            publicCheckbox: false,
            tableData: this.props.data
        }
    },
    handleUserInput: function (filterText) {
        this.setState({
            filterText: filterText
        })
    },
    handleUserClick: function (colName, order) {
        var tmpData = this.state.tableData
        tmpData.sort(function (a, b) {
            var a_val = eval('a.' + colName)
            var b_val = eval('b.' + colName)
            if (order === 'normal') {
                if (!a_val && b_val) {
                    return 1
                }
                if (!b_val && a_val) {
                    return -1
                }
                if (!a_val && !b_val) {
                    return 0
                }
                return -a_val.localeCompare(b_val)
            } else {
                if (!a_val && b_val) {
                    return -1
                }
                if (!b_val && a_val) {
                    return 1
                }
                if (!a_val && !b_val) {
                    return 0
                }
                return a_val.localeCompare(b_val)
            }
        })
        // this.setState({
        //   tableData: tmpData
        // })
    },
    componentWillReceiveProps: function (nextProps) {
        this.setState({
            tableData: nextProps.data
        })
    },
    handleUserFilter: function (name, checked) {
        var publicCheckboxStatus = this.state.publicCheckbox
        publicCheckboxStatus = checked
        var tmpData = this.props.data.filter(function (element) {
            if (publicCheckboxStatus) {
                return true
            } else return element.private === true
        })
        this.setState({
            tableData: tmpData,
            publicCheckbox: publicCheckboxStatus
        })
    },
    render: function () {
        return (
            <div className="filterable_table">
                <SearchBar
                    filterText={this.state.filterText}
                    onUserInput={this.handleUserInput}
                    dataType={this.props.dataType}
                />
                <FilterButton
                    filterOption="public"
                    onUserFilter={this.handleUserFilter}
                    inputCheckboxValue={this.state.publicCheckbox}
                    dataType={this.props.dataType}
                />
                <NewItemButton dataType={this.props.dataType} private={true} />
                <OuterTable
                    data={this.state.tableData}
                    filterText={this.state.filterText}
                    onUserClick={this.handleUserClick}
                    dataType={this.props.dataType}
                    showPublic={this.state.publicCheckbox}
                />
            </div>
        )
    }
})