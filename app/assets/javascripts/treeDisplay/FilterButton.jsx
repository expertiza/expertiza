var FilterButton = React.createClass({
    handleChange: function () {
        this.props.onUserFilter(this.props.filterOption, this.refs.filterCheckbox.getDOMNode().checked)
    },
    render: function () {
        return (
            <span
                className="show-checkbox"
                style={{ display: this.props.dataType === 'questionnaire' ? 'none' : '' }}
            >
                <input
                    type="checkbox"
                    checked={this.props.inputCheckboxValue}
                    ref="filterCheckbox"
                    onChange={this.handleChange}
                >
                    {" Include others' items"}
                </input>
            </span>
        )
    }
})