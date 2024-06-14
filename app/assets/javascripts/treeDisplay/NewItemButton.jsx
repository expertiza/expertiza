//NewItemButton is a button which on clicked leads to a page for new assignment/course. Child component of FilterableTable
class NewItemButton extends React.Component {
    render() {
        var renderContent = []
        var formStyle = {
            margin: 0,
            padding: 0,
            display: 'inline'
        }
        if (this.props.dataType.length > 0) {
            if (this.props.dataType != 'questionnaire') {
                renderContent.push(
                    <form
                        style={formStyle}
                        action={
                            '/' +
                            (this.props.dataType === 'assignment'
                                ? this.props.dataType + 's'
                                : this.props.dataType) +
                            '/new'
                        }
                        method="GET"
                        key={this.props.dataType + '_new' + this.props.private.toString()}
                    >
                        <input type="hidden" name="private" value={this.props.private ? 1 : 0} />
                        <button type="submit" className="btn btn-primary pull-right new-button">
                            <b>+</b>
                        </button>
                    </form>
                )
            }
        }
        return <span>{renderContent}</span>
    }
}