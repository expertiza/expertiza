/** beta branch isnt getting a prop related to the data to be displayed in the dropdown */
class FilterableTable extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            filterText: '',
            showOthersWork: false,
            tableData: this.props.tableContent
        }
        this.handleUserInput = this.handleUserInput.bind(this);
        this.handleUserClick = this.handleUserClick.bind(this);
        this.toggleShowOthersWork = this.toggleShowOthersWork.bind(this);
        this.updateTableDataFromChild = this.updateTableDataFromChild.bind(this);
    }

    componentWillReceiveProps(nextProps) {
        this.setState({
            tableData: nextProps.tableContent
        })
    }

    handleUserInput(filterText) {
        this.setState({
            filterText,
        })
    }

    handleUserClick(colName, order) {
        var tmpData = this.state.tableData
        tmpData.sort(function (a, b) {
            if (!a[colName] && b[colName]) {
                return order === 'normal' ? 1 : -1;
            }
            if (!b[colName] && a[colName]) {
                return order === 'normal' ? -1 : 1;
            }
            if (!a[colName] && !b[colName]) {
                return 0
            }
            if (colName === "institution") {
                aVal = a[colName].length > 0 ? a[colName][0].name : "";
                bVal = b[colName].length > 0 ? b[colName][0].name : "";
            } else {
                aVal = a[colName];
                bVal = b[colName];
            }
            return order === 'normal' ? -aVal.localeCompare(bVal) : aVal.localeCompare(bVal)
        })
        this.setState({
            tableData: tmpData
        })
    }

    toggleShowOthersWork(checked) {
        this.setState({
            showOthersWork: checked
        })
    }

    updateTableDataFromChild(id, response) {
        var tableData = this.state.tableData;
        tableData[id.split('_')[2]]['children'] = response;
        this.setState({
            tableData,
        })
    }

    render() {
        return (
            <div className="filterable_table">
                <SearchBar
                    filterText={this.state.filterText}
                    onUserInput={this.handleUserInput}
                    dataType={this.props.dataType}
                />
                <FilterButton
                    onUserFilter={this.toggleShowOthersWork}
                    inputCheckboxValue={this.state.showOthersWork}
                    dataType={this.props.dataType}
                />
                <NewItemButton dataType={this.props.dataType} private={true} />
                <OuterTable
                    tableContent={this.state.tableData}
                    filterText={this.state.filterText}
                    onUserClick={this.handleUserClick}
                    dataType={this.props.dataType}
                    showOthersWork={this.state.showOthersWork}
                    updateData={this.updateTableDataFromChild}
                />
            </div>
        )
    }
}