// OuterTableDetailsRow contains the inner table that will be displayed when an outer table row is clicked. Child component of OuterTable.
class OuterTableDetailsRow extends React.Component {
    render() {
        var colSpan = '5'
        var colDisplayStyle = {
            display: ''
        }
        if (this.props.dataType === 'questionnaire') {
            colSpan = '6'
            colDisplayStyle = {
                display: 'none'
            }
        }
        var style
        if (this.props.children && this.props.children.length > 0) {
            style = {
                display: this.props.showElement
            }
        } else {
            style = {
                display: 'none'
            }
        }
        return (
            <tr style={style} className="active">
                <td style={colDisplayStyle} />
                <td colSpan={colSpan}>
                    <InnerTable
                        key={'innertable_' + this.props.id}
                        itemsDisplayed={this.props.children}
                        dataType={this.props.dataType}
                    />
                </td>
            </tr>
        )
    }
}