class SearchBar extends React.Component {
    render() {
        return (
            <span style={{ display: this.props.dataType === 'questionnaire' ? 'none' : '' }}>
                <input
                    type="text"
                    placeholder="Search..."
                    value={this.props.filterText}
                    onChange={(event) => this.props.onUserInput(event.target.value)}
                />
            </span>
        )
    }
}