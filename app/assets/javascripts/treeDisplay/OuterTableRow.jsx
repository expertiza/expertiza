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
        var creationDate
        var updatedDate
        var colWidthArray = ['30%', '0%', '0%', '0%', '25%', '25%', '20%']
        var colDisplayStyle = {
            display: '',
            'word-wrap': 'break-word'
        }
        if (this.props.dataType === 'questionnaire') {
            colWidthArray = ['70%', '0%', '0%', '0%', '0%', '0%', '30%']
            colDisplayStyle = {
                display: 'none'
            }
        } else if (this.props.dataType === 'course') {
            colWidthArray = ['20%', '0%', '0%', '20%', '20%', '20%', '20%']
        }
        if (this.props.creation_date && this.props.updated_date) {
            creationDate = formatDate(new Date(this.props.creation_date))
            updatedDate = formatDate(new Date(this.props.updated_date))
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
                <td width={colWidthArray[0]}>{this.props.name}</td>
                {
                    this.props.dataType === 'course' &&
                    <td style={colDisplayStyle} width={colWidthArray[3]}>
                        {institutionName}
                    </td>
                }
                <td
                    style={colDisplayStyle}
                    width={colWidthArray[4]}
                    dangerouslySetInnerHTML={{ __html: creationDate }}
                />
                <td
                    style={colDisplayStyle}
                    width={colWidthArray[5]}
                    dangerouslySetInnerHTML={{ __html: updatedDate }}
                />
                <td width={colWidthArray[6]}>
                    <RowAction
                        actions={this.props.actions}
                        key={this.props.id}
                        nodeType={nodeType}
                        parentName={this.props.name}
                        private={this.props.private}
                        isAvailable={this.props.is_available}
                        courseId={this.props.course_id}
                        maxTeamSize={this.props.max_team_size}
                        isIntelligent={this.props.is_intelligent}
                        requireQuiz={this.props.require_quiz}
                        allowSuggestions={this.props.allow_suggestions}
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