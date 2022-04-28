class FilterButton extends React.Component {
    render() {
        return (
            <span
                className="show-checkbox"
                style={{ display: this.props.dataType === 'questionnaire' ? 'none' : '' }}
            >
                <input
                    type="checkbox"
                    checked={this.props.inputCheckboxValue}
                    ref="filterCheckbox"
                    onChange={() => this.props.onUserFilter(!this.props.inputCheckboxValue)}
                >
                    {" Include others' items"}
                </input>
            </span>
        )
    }
}