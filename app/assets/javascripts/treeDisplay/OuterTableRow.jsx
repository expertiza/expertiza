class OuterTableRow extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            expanded: false
        }
        this.handleClick = this.handleClick.bind(this)
    }

    componentDidMount() {
        // this buffer holds the title for all of the rubric types under the Questionnaire tab
        rubricBuffer = [
            'Review',
            'Metareview',
            'Author Feedback',
            'Teammate Review',
            'Assignment Survey',
            'Global Survey',
            'Course Survey'
        ]

        //selectedMenuItem then takes the clicked rubric from the panel under questionnaire
        //selectedMenuItemIndex finds the corresponding index of the click rubric from the above buffer
        selectedMenuItem = document.getElementById('tree_display').getAttribute('data-menu-item')
        selectedMenuItemIndex = rubricBuffer.indexOf(selectedMenuItem)

        if (selectedMenuItemIndex !== -1) {
            if (rubricBuffer[selectedMenuItemIndex] === this.props.name) {
                //if the name matches, expand the rubric panel by setting this property to true
                this.setState(
                    {
                        expanded: true
                    },
                    function () {
                        this.props.rowClicked(this.props.id, true, this.props.newParams)
                    }
                )
            }
        }
    }

    handleClick(event) {
        if (event.target.type != 'button') {
            this.setState(function (prevState) {
                return {
                    expanded: !prevState.expanded
                }
            },
                function () {
                    this.props.rowClicked(this.props.id, this.state.expanded, this.props.newParams)
                }
            )
        } else {
            event.stopPropagation()
        }
    }

    render() {
        var creationDate = ""
        var updatedDate = ""
        if (this.props.creationDate && this.props.updatedDate) {
            creationDate = formatDate(new Date(this.props.creationDate))
            updatedDate = formatDate(new Date(this.props.updatedDate))
        }
        var nodeTypeRaw = this.props.id.split('_')[0]
        var nodeType = nodeTypeRaw.substring(0, nodeTypeRaw.length - 4).toLowerCase()
        var id = this.props.id.split('_')[1]
        var institutionName = '-'
        if (this.props.institution && this.props.institution.length != 0) {
            institutionName = this.props.institution[0].name
        }
        return (
            <tr onClick={this.handleClick} id={this.props.id}>
                <td width={this.props.colWidthArray[0]}>{this.props.name}</td>
                {
                    this.props.dataType === 'course' &&
                    <td style={this.props.colDisplayStyle} width={this.props.colWidthArray[1]}>
                        {institutionName}
                    </td>
                }
                <td
                    style={this.props.colDisplayStyle}
                    width={this.props.colWidthArray[2]}
                    dangerouslySetInnerHTML={{ __html: creationDate }}
                />
                <td
                    style={this.props.colDisplayStyle}
                    width={this.props.colWidthArray[3]}
                    dangerouslySetInnerHTML={{ __html: updatedDate }}
                />
                <td width={this.props.colWidthArray[4]}>
                    <RowAction
                        actions={this.props.actions}
                        key={this.props.id}
                        nodeType={nodeType}
                        parentName={this.props.name}
                        private={this.props.private}
                        isAvailable={this.props.isAvailable}
                        courseId={this.props.courseId}
                        maxTeamSize={this.props.maxTeamSize}
                        isIntelligent={this.props.isIntelligent}
                        requireQuiz={this.props.requireQuiz}
                        allowSuggestions={this.props.allowSuggestions}
                        dataType={this.props.dataType}
                        id={id}
                    />
                </td>
            </tr>
        )
    }
}

function formatDate(date) {
    var month = new Array()
    month[0] = 'Jan'
    month[1] = 'Feb'
    month[2] = 'Mar'
    month[3] = 'Apr'
    month[4] = 'May'
    month[5] = 'Jun'
    month[6] = 'Jul'
    month[7] = 'Aug'
    month[8] = 'Sep'
    month[9] = 'Oct'
    month[10] = 'Nov'
    month[11] = 'Dec'

    var hours = date.getHours()
    var minutes = date.getMinutes()
    var ampm = hours >= 12 ? 'PM' : 'AM'
    hours = hours % 12
    hours = hours ? hours : 12 // the hour '0' should be '12'
    minutes = minutes < 10 ? '0' + minutes : minutes
    var strTime = hours + ':' + minutes + ' ' + ampm
    return month[date.getMonth()] + ' ' + date.getDate() + ', ' + date.getFullYear() + ' - ' + strTime
}