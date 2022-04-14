var SearchBar = React.createClass({
    handleChange: function () {
        this.props.onUserInput(this.refs.filterTextInput.getDOMNode().value)
    },
    render: function () {
        return (
            <span style={{ display: this.props.dataType === 'questionnaire' ? 'none' : '' }}>
                <input
                    type="text"
                    placeholder="Search..."
                    value={this.props.filterText}
                    ref="filterTextInput"
                    onChange={this.handleChange}
                />
            </span>
        )
    }
})