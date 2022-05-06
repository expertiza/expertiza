class SortToggle extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            order: this.props.order
        }
        this.handleClick = this.handleClick.bind(this)
    }
    handleClick() {
        var newOrder = this.state.order === 'normal' ? 'reverse' : 'normal';
        this.setState(
            {
                order: newOrder
            },
            function () {
                this.props.handleUserClick(this.props.colName, this.state.order)
            }
        )
    }
    render() {
        return <span className="glyphicon glyphicon-sort" onClick={this.handleClick} />
    }
}