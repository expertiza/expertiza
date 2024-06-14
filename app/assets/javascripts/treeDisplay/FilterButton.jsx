// FilterButton is a child of FilterableTable and contains an input used to toggle viewing others' courses and assignments. Child component of FilterableTable
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
                    onChange={() => this.props.onUserFilter(!this.props.inputCheckboxValue)}
                >
                    {" Include others' items"}
                </input>
            </span>
        )
    }
}