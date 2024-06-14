class TitleRow extends React.Component {
    render() {
        return (
            <tr className="active">
                <td colSpan="6">
                    <b>{this.props.title}</b>
                </td>
            </tr>
        )
    }
}