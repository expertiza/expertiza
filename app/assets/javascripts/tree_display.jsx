// initialize a global object available throughout the application
// can be useful on different pages
let app_variables = {

  currentUserId: null,
  homeActionShowFlag: null
};

/** this object helps consolidate some of the logic used on this page */
const nodeAttributes = {
  isAssignment(name) {
    return name === 'assignment' || name === 'assignments'
  },
  isCourse(name) {
    return name === 'course' || name === 'courses'
  },
  isQuestionnaire(name) {
    return name === 'questionnaire' || name === 'questionnaires'
  },
  assignment: {
    plural: 'assignments',
    colWidthArray: ['30%', '0%', '0%', '0%', '25%', '25%', '20%'],

    actions: [
      (props) => ({
        title: props.courseId ? 'Remove from course' : 'Assign to course',
        href: props.courseId
          ? '/assignments/remove_assignment_from_course?id=' + (parseInt(props.id) / 2).toString()
          : '/assignments/place_assignment_in_course?id=' + (parseInt(props.id) / 2).toString(),
        src: props.courseId
          ? '/assets/tree_view/remove-from-course-24.png'
          : '/assets/tree_view/view-review-report-24.png'
      }),
      (props) => ({
        title: 'Add participants',
        href: '/participants/list?id=' + `${parseInt(props.id) / 2}` + '&model=Assignment',
        src: '/assets/tree_view/add-participant-24.png'
      }),
      (props) =>
        parseInt(props.maxTeamSize) > 1
          ? {
            title: 'Create teams',
            href: '/teams/list?id=' + `${parseInt(props.id) / 2}` + '&type=Assignment',
            src: '/assets/tree_view/create-teams-24.png'
          }
          : null,
      (props) => ({
        title: 'Assign reviewers',
        href: '/review_mapping/list_mappings?id=' + `${parseInt(props.id) / 2}`,
        src: '/assets/tree_view/assign-reviewers-24.png'
      }),
      (props) => ({
        title: 'Assign survey',
        href: '/survey_deployment/new?id=' + `${parseInt(props.id) / 2}` + '&type=AssignmentSurveyDeployment',
        src: '/assets/tree_view/assign-survey-24.png'
      }),
      (props) =>
        props.requireQuiz
          ? {
            title: 'View quiz questions',
            href:
              '/student_quizzes/review_questions?id=' +
              `${parseInt(props.id) / 2}` +
              '&type=Assignment',
            src: '/assets/tree_view/view-survey-24.png'
          }
          : null,
      (props) => ({
        title: 'View submissions',
        href: '/assignments/list_submissions?id=' + `${parseInt(props.id) / 2}`,
        src: '/assets/tree_view/List-submisstions-24.png'
      }),
      (props) => ({
        title: 'View scores',
        href: '/grades/view?id=' + `${parseInt(props.id) / 2}`,
        src: '/assets/tree_view/view-scores-24.png'
      }),
      (props) => ({
        title: 'View reports',
        href: '/reports/response_report?id=' + `${parseInt(props.id) / 2}`,
        src: '/assets/tree_view/view-review-report-24.png'
      }),
      (props) => ({
        title: 'View survey responses',
        href: '/survey_deployment/view_responses?id=' + `${parseInt(props.id) / 2}`,
        src: '/assets/tree_view/view-survey-24.png'
      }),
      (props) =>
        props.isIntelligent
          ? {
            title: 'Intelligent Assignment',
            href: '/lottery/run_intelligent_assignment/' + `${parseInt(props.id) / 2}`,
            src: '/assets/tree_view/run-lottery.png'
          }
          : null,
      (props) =>
        props.allowSuggestions
          ? {
            title: 'View suggestions',
            href: '/suggestion/list?id=' + `${parseInt(props.id) / 2}` + '&type=Assignment',
            src: '/assets/tree_view/view-suggestion-24.png'
          }
          : null
    ],
    getActions: function (props) {
      if (props.isAvailable) {
        return nodeAttributes.assignment.actions.filter((i) => i(props)).map((val, i, arr) => {
          let ret = val(props)
          /** every five provide a break */
          if (i % 5 == 0) {
            return (
              <span key={ret.src}>
                <a title={ret.title} href={ret.href}>
                  <img src={ret.src} />
                </a>
                <br />
              </span>
            )
          } else {
            return (
              <span>
                <a title={ret.title} href={ret.href}>
                  <img src={ret.src} />
                </a>
              </span>
            )
          }
        })
      } else {
        let ret = nodeAttributes.assignment.actions[0](props)
        return (
          <span>
            <a title={ret.title} href={ret.href}>
              <img src={ret.src} />
            </a>
          </span>
        )
      }
    }
  },
  course: {
    plural: 'course',
    actions: [
      {
        title: 'Add TA',
        href: '/course/view_teaching_assistants?model=Course&id=',
        src: '/assets/tree_view/add-ta-24.png'
      },
      {
        title: 'Create assignment',
        href: '/assignments/new?parent_id=',
        src: '/assets/tree_view/add-assignment-24.png'
      },
      {
        title: 'Add participants',
        href: '/participants/list?model=Course&id=',
        src: '/assets/tree_view/add-participant-24.png'
      },
      {
        title: 'Create teams',
        href: '/teams/list?type=Course&id=',
        src: '/assets/tree_view/create-teams-24.png'
      },
      {
        title: 'View grade summary by student',
        href: '/assessment360/course_student_grade_summary?course_id=',
        src: '/assets/tree_view/360-dashboard-24.png'
      },
      {
        title: 'Assign survey',
        href: '/survey_deployment/new?type=CourseSurveyDeployment&id=',
        src: '/assets/tree_view/assign-survey-24.png'
      },
      {
        title: 'View aggregated teammate & meta reviews',
        href: '/assessment360/all_students_all_reviews?course_id=',
        src: null,
        extra: <span style={{ fontSize: '22px', top: '8px' }} className="glyphicon glyphicon-list-alt" />
      }
    ],
    getActions: function (id) {
      return nodeAttributes.course.actions.map(
        (action) =>
          action.src ? (
            <a title={action.title} href={action.href + id}>
              {' '}
              <img src={action.src} />
            </a>
          ) : (
            <a title={action.title} href={action.href + id}>
              {' '}
              {action.extra}{' '}
            </a>
          )
      )
    }
  },
  questionnaire: {
    plural: 'questionnaires',
    colWidthArray: ['30%', '0%', '0%', '0%', '20%', '20%', '30%'],
    getActions: function (handleButtonClick, parent_name) {
      return (
        <span onClick={handleButtonClick}>
          <form
            style={{
              margin: 0,
              padding: 0,
              display: 'inline'
            }}
            action={'/questionnaires/new'}
            method="GET"
          >
            <input type="hidden" name="model" value={parent_name + 'Questionnaire'} />
            <input type="hidden" name="private" value={1} />
            <button type="submit" className="btn btn-primary questionnaire-button">
              <b>+</b>
            </button>
          </form>
        </span>
      )
    }
  }
}

/** make an object used to determine many of the logical params needed in this program */

// execute the grabbing of user id after the page is fully loaded
// helps to make sure that the react component is rendered for sure
// also avoid hindering the rendering steps
window.addEventListener('load', (e) => {
  // grab the data attribute

  let treeDisplayDiv = document.querySelector('#tree_display')
  // check if the html element is present requested in the query above
  if (treeDisplayDiv) {
    // set the userid for the current user
    app_variables.currentUserId = treeDisplayDiv.dataset.userId

  }
})

jQuery(document).ready(function () {
  // This preloadedImages function is refered from http://jsfiddle.net/slashingweapon/8jAeu/
  // Actually I am not using the values in preloadedImages, but image loading speed is indeed getting faster
  let treeDisplayDiv = document.querySelector('#tree_display');

  if (treeDisplayDiv) {
    // set the user preference to homeActionshowflag 
    app_variables.homeActionShowFlag = treeDisplayDiv.dataset.userShow;

  }
  var preloadedImages = []
  function preloadImages() {
    for (var idx = 0; idx < arguments.length; idx++) {
      var oneImage = new Image()
      oneImage.src = arguments[idx]
      preloadedImages.push(oneImage)
    }
  }


  var ContentTableDetailsRow = React.createClass({
    render: function () {
      var colSpan = '5'
      var colDisplayStyle = {
        display: ''
      }
      if (this.props.dataType === 'questionnaire') {
        colSpan = '6'
        colDisplayStyle = {
          display: 'none'
        }
      }
      var style
      if (this.props.children && this.props.children.length > 0) {
        style = {
          display: this.props.showElement
        }
      } else {
        style = {
          display: 'none'
        }
      }
      return (
        <tr style={style} className="active">
          <td style={colDisplayStyle} />
          <td colSpan={colSpan}>
            <InnerTable
              key={'innertable_' + this.props.id}
              data={this.props.children}
              dataType={this.props.dataType}
            />
          </td>
        </tr>
        /** no data is being passed in here after inspecting */
      )
    }
  })

  var TitleRow = React.createClass({
    render: function () {
      return (
        <tr className="active">
          <td colSpan="6">
            <b>{this.props.title}</b>
          </td>
        </tr>
      )
    }
  })

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

  var NewItemButton = React.createClass({
    render: function () {
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
  })

  var SortToggle = React.createClass({
    getInitialState: function () {
      return {
        order: this.props.order
      }
    },
    handleClick: function () {
      if (this.state.order === 'normal') {
        this.setState(
          {
            order: 'reverse'
          },
          function () {
            this.props.handleUserClick(this.props.colName, this.state.order)
          }
        )
      } else {
        this.setState(
          {
            order: 'normal'
          },
          function () {
            this.props.handleUserClick(this.props.colName, this.state.order)
          }
        )
      }
    },
    render: function () {
      return <span className="glyphicon glyphicon-sort" onClick={this.handleClick} />
    }
  })

  var ContentTable = React.createClass({
    getInitialState: function () {
      return {
        expandedRow: []
      }
    },
    handleExpandClick: function (id, expanded, newParams) {
      this.state.expandedRow.concat([id])
      if (expanded) {
        this.setState({
          expandedRow: this.state.expandedRow.concat([id])
        })
        // if(this.props.dataType!='assignment') {
        _this = this
        jQuery.post(
          '/tree_display/get_sub_folder_contents',
          {
            reactParams2: newParams
          },
          function (data) {
            _this.props.data[id.split('_')[2]]['children'] = data
            _this.forceUpdate()
          },
          'json'
        )
        // }
      } else {
        var index = this.state.expandedRow.indexOf(id)
        if (index > -1) {
          var list = this.state.expandedRow
          list.splice(index, 1)
          this.setState({
            expandedRow: list
          })
        }
      }
    },
    handleSortingClick: function (colName, order) {
      this.props.onUserClick(colName, order)
    },
    render: function () {
      var _rows = []
      var _this = this
      var colWidthArray = ['30%', '0%', '0%', '0%', '25%', '25%', '20%']
      var colDisplayStyle = {
        display: ''
      }
      if (this.props) {
        if (this.props.dataType === 'questionnaire') {
          colWidthArray = ['70%', '0%', '0%', '0%', '0%', '0%', '30%']
          colDisplayStyle = {
            display: 'none'
          }
        }
        if (this.props.dataType == 'course') {
          colWidthArray = ['20%', '0%', '0%', '20%', '20%', '20%', '20%']
          _rows.push(<TitleRow title="My Courses" />)
        } else if (this.props.dataType == 'assignment') {
          _rows.push(<TitleRow title="My Assignments" />)
        }
        jQuery.each(this.props.data, function (i, entry) {
          if (
            ((entry.name && entry.name.indexOf(_this.props.filterText) !== -1) ||
              (entry.creation_date && entry.creation_date.indexOf(_this.props.filterText) !== -1) ||
              (entry.institution && entry.institution.indexOf(_this.props.filterText) !== -1) ||
              (entry.updated_date && entry.updated_date.indexOf(_this.props.filterText) !== -1)) &&
            (entry.private == true || entry.type == 'FolderNode')
          ) {
            _rows.push(
              <ContentTableRow
                key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2).toString() + '_' + i}
                id={
                  entry.type +
                  '_' +
                  (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                  '_' +
                  i
                }
                name={entry.name}
                institution={entry.institution}
                creation_date={entry.creation_date}
                updated_date={entry.updated_date}
                actions={entry.actions}
                is_available={entry.is_available}
                course_id={entry.course_id}
                max_team_size={entry.max_team_size}
                is_intelligent={entry.is_intelligent}
                require_quiz={entry.require_quiz}
                dataType={_this.props.dataType}
                //this is just a hack. All current users courses are marked as private during fetch for display purpose.
                private={entry.private}
                allow_suggestions={entry.allow_suggestions}
                has_topic={entry.has_topic}
                rowClicked={_this.handleExpandClick}
                newParams={entry.newParams}
              />
            )
            _rows.push(
              <ContentTableDetailsRow
                key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2 + 1).toString() + '_' + i}
                id={
                  entry.type +
                  '_' +
                  (parseInt(entry.nodeinfo.node_object_id) * 2 + 1).toString() +
                  '_' +
                  i
                }
                // showElement={true}
                showElement={
                  _this.state.expandedRow.indexOf(
                    entry.type +
                    '_' +
                    (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                    '_' +
                    i
                  ) > -1 ? (
                    ''
                  ) : (
                    'none'
                  )
                }
                dataType={_this.props.dataType}
                children={entry.children}
              />
            )
          } else {
            return
          }
        })
        /** this was protecting an always null field, weird TODO */
        if (this.props.showPublic) {
          if (this.props.dataType == 'course') {
            _rows.push(<TitleRow title="Others' Public Courses" />)
            jQuery.each(this.props.data, function (i, entry) {
              if (
                ((entry.name && entry.name.indexOf(_this.props.filterText) !== -1) ||
                  (entry.creation_date &&
                    entry.creation_date.indexOf(_this.props.filterText) !== -1) ||
                  (entry.institution && entry.institution.indexOf(_this.props.filterText) !== -1) ||
                  (entry.updated_date &&
                    entry.updated_date.indexOf(_this.props.filterText) !== -1)) &&
                entry.private == false
              ) {
                _rows.push(
                  <ContentTableRow
                    key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2).toString() + '_' + i}
                    id={
                      entry.type +
                      '_' +
                      (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                      '_' +
                      i
                    }
                    name={entry.name}
                    institution={entry.institution}
                    creation_date={entry.creation_date}
                    updated_date={entry.updated_date}
                    actions={entry.actions}
                    is_available={entry.is_available}
                    course_id={entry.course_id}
                    max_team_size={entry.max_team_size}
                    is_intelligent={entry.is_intelligent}
                    require_quiz={entry.require_quiz}
                    dataType={_this.props.dataType}
                    private={entry.private}
                    allow_suggestions={entry.allow_suggestions}
                    has_topic={entry.has_topic}
                    rowClicked={_this.handleExpandClick}
                    newParams={entry.newParams}
                  />
                )
                _rows.push(
                  <ContentTableDetailsRow
                    key={
                      entry.type +
                      '_' +
                      (parseInt(entry.nodeinfo.id) * 2 + 1).toString() +
                      '_' +
                      i
                    }
                    id={
                      entry.type +
                      '_' +
                      (parseInt(entry.nodeinfo.node_object_id) * 2 + 1).toString() +
                      '_' +
                      i
                    }
                    showElement={
                      _this.state.expandedRow.indexOf(
                        entry.type +
                        '_' +
                        (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                        '_' +
                        i
                      ) > -1 ? (
                        ''
                      ) : (
                        'none'
                      )
                    }
                    dataType={_this.props.dataType}
                    children={entry.children}
                  />
                )
              } else {
                return
              }
            })
          } else if (this.props.dataType == 'assignment') {
            _rows.push(<TitleRow title="Others' Public Assignments" />)
            jQuery.each(this.props.data, function (i, entry) {
              if (
                ((entry.name && entry.name.indexOf(_this.props.filterText) !== -1) ||
                  (entry.creation_date &&
                    entry.creation_date.indexOf(_this.props.filterText) !== -1) ||
                  (entry.updated_date &&
                    entry.updated_date.indexOf(_this.props.filterText) !== -1)) &&
                entry.private == false
              ) {
                _rows.push(
                  <ContentTableRow
                    key={entry.type + '_' + (parseInt(entry.nodeinfo.id) * 2).toString() + '_' + i}
                    id={
                      entry.type +
                      '_' +
                      (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                      '_' +
                      i
                    }
                    name={entry.name}
                    creation_date={entry.creation_date}
                    updated_date={entry.updated_date}
                    actions={entry.actions}
                    is_available={entry.is_available}
                    course_id={entry.course_id}
                    max_team_size={entry.max_team_size}
                    is_intelligent={entry.is_intelligent}
                    require_quiz={entry.require_quiz}
                    dataType={_this.props.dataType}
                    private={entry.private}
                    allow_suggestions={entry.allow_suggestions}
                    has_topic={entry.has_topic}
                    rowClicked={_this.handleExpandClick}
                    newParams={entry.newParams}
                  />
                )
                _rows.push(
                  <ContentTableDetailsRow
                    key={
                      entry.type +
                      '_' +
                      (parseInt(entry.nodeinfo.id) * 2 + 1).toString() +
                      '_' +
                      i
                    }
                    id={
                      entry.type +
                      '_' +
                      (parseInt(entry.nodeinfo.node_object_id) * 2 + 1).toString() +
                      '_' +
                      i
                    }
                    showElement={
                      _this.state.expandedRow.indexOf(
                        entry.type +
                        '_' +
                        (parseInt(entry.nodeinfo.node_object_id) * 2).toString() +
                        '_' +
                        i
                      ) > -1 ? (
                        ''
                      ) : (
                        'none'
                      )
                    }
                    dataType={_this.props.dataType}
                    children={entry.children}
                  />
                )
              } else {
                return
              }
            })
          }
        }
      }
      if (this.props.dataType == 'course') {
        return (
          <table className="table table-hover" style={{ 'table-layout': 'fixed' }}>
            <thead>
              <tr>
                <th width={colWidthArray[0]}>
                  Name
                  <SortToggle
                    colName="name"
                    order="normal"
                    handleUserClick={this.handleSortingClick}
                  />
                </th>
                <th style={colDisplayStyle} width={colWidthArray[3]}>
                  Institution
                  <SortToggle
                    colName="institution"
                    order="normal"
                    handleUserClick={this.handleSortingClick}
                  />
                </th>
                <th style={colDisplayStyle} width={colWidthArray[4]}>
                  Creation Date
                  <SortToggle
                    colName="creation_date"
                    order="normal"
                    handleUserClick={this.handleSortingClick}
                  />
                </th>
                <th style={colDisplayStyle} width={colWidthArray[5]}>
                  Updated Date
                  <SortToggle
                    colName="updated_date"
                    order="normal"
                    handleUserClick={this.handleSortingClick}
                  />
                </th>
                <th width={colWidthArray[6]}>Actions</th>
              </tr>
            </thead>
            <tbody>{_rows}</tbody>
          </table>
        )
      } else {
        return (
          <table className="table table-hover" style={{ 'table-layout': 'fixed' }}>
            <thead>
              <tr>
                <th width={colWidthArray[0]}>
                  Name
                  <SortToggle
                    colName="name"
                    order="normal"
                    handleUserClick={this.handleSortingClick}
                  />
                </th>
                <th style={colDisplayStyle} width={colWidthArray[4]}>
                  Creation Date
                  <SortToggle
                    colName="creation_date"
                    order="normal"
                    handleUserClick={this.handleSortingClick}
                  />
                </th>
                <th style={colDisplayStyle} width={colWidthArray[5]}>
                  Updated Date
                  <SortToggle
                    colName="updated_date"
                    order="normal"
                    handleUserClick={this.handleSortingClick}
                  />
                </th>
                <th width={colWidthArray[6]}>Actions</th>
              </tr>
            </thead>
            <tbody>{_rows}</tbody>
          </table>
        )
      }
    }
  })

  /** beta branch isnt getting a prop related to the data to be displayed in the dropdown */
  var FilterableTable = React.createClass({
    getInitialState: function () {
      return {
        filterText: '',
        privateCheckbox: false,
        publicCheckbox: false,
        tableData: this.props.data
      }
    },
    handleUserInput: function (filterText) {
      this.setState({
        filterText: filterText
      })
    },
    handleUserClick: function (colName, order) {
      var tmpData = this.state.tableData
      tmpData.sort(function (a, b) {
        var a_val = eval('a.' + colName)
        var b_val = eval('b.' + colName)
        if (order === 'normal') {
          if (!a_val && b_val) {
            return 1
          }
          if (!b_val && a_val) {
            return -1
          }
          if (!a_val && !b_val) {
            return 0
          }
          return -a_val.localeCompare(b_val)
        } else {
          if (!a_val && b_val) {
            return -1
          }
          if (!b_val && a_val) {
            return 1
          }
          if (!a_val && !b_val) {
            return 0
          }
          return a_val.localeCompare(b_val)
        }
      })
      // this.setState({
      //   tableData: tmpData
      // })
    },
    componentWillReceiveProps: function (nextProps) {
      this.setState({
        tableData: nextProps.data
      })
    },
    handleUserFilter: function (name, checked) {
      var publicCheckboxStatus = this.state.publicCheckbox
      publicCheckboxStatus = checked
      var tmpData = this.props.data.filter(function (element) {
        if (publicCheckboxStatus) {
          return true
        } else return element.private === true
      })
      this.setState({
        tableData: tmpData,
        publicCheckbox: publicCheckboxStatus
      })
    },
    render: function () {
      return (
        <div className="filterable_table">
          <SearchBar
            filterText={this.state.filterText}
            onUserInput={this.handleUserInput}
            dataType={this.props.dataType}
          />
          <FilterButton
            filterOption="public"
            onUserFilter={this.handleUserFilter}
            inputCheckboxValue={this.state.publicCheckbox}
            dataType={this.props.dataType}
          />
          <NewItemButton dataType={this.props.dataType} private={true} />
          <ContentTable
            data={this.state.tableData}
            filterText={this.state.filterText}
            onUserClick={this.handleUserClick}
            dataType={this.props.dataType}
            showPublic={this.state.publicCheckbox}
          />
        </div>
      )
    }
  })

  var TabSystem = React.createClass({
    getInitialState: function () {
      return {
        tableContent: {
          Courses: {},
          Assignments: {},
          Questionnaires: {}
        },
        activeTab: '1'
      }
    },
    componentWillMount: function () {
      var _this = this
      preloadImages(
        '/assets/tree_view/edit-icon-24.png',
        '/assets/tree_view/delete-icon-24.png',
        '/assets/tree_view/lock-off-disabled-icon-24.png',
        '/assets/tree_view/lock-disabled-icon-24.png',
        '/assets/tree_view/Copy-icon-24.png',
        '/assets/tree_view/add-public-24.png',
        '/assets/tree_view/add-private-24.png',
        '/assets/tree_view/add-ta-24.png',
        '/assets/tree_view/add-assignment-24.png',
        '/assets/tree_view/add-participant-24.png',
        '/assets/tree_view/create-teams-24.png',
        '/assets/tree_view/360-dashboard-24.png',
        '/assets/tree_view/remove-from-course-24.png',
        '/assets/tree_view/assign-course-blue-24.png',
        '/assets/tree_view/run-lottery.png',
        '/assets/tree_view/assign-reviewers-24.png',
        '/assets/tree_view/assign-survey-24.png',
        '/assets/tree_view/view-survey-24.png',
        '/assets/tree_view/view-scores-24.png',
        '/assets/tree_view/view-review-report-24.png',
        '/assets/tree_view/view-suggestion-24.png',
        '/assets/tree_view/view-delayed-mailer.png',
        '/assets/tree_view/view-publish-rights-24.png'
      )
      jQuery.get('/tree_display/session_last_open_tab', function (data) {
        _this.setState({
          activeTab: data
        })
      })
      jQuery.get(
        '/tree_display/get_folder_contents',
        function (data2, status) {
          jQuery.each(data2, function (nodeType, outerNode) {
            jQuery.each(outerNode, function (i, node) {
              var newParams = {
                key: node.name + '|' + node.directory,
                nodeType: nodeType,
                child_nodes: node.nodeinfo
              }
              if (nodeType === 'Assignments') {
                node['children'] = null
                node[newParams] = newParams
              } else if (nodeType === 'Courses') {
                newParams['nodeType'] = 'CourseNode'
                node['newParams'] = newParams
              } else if (nodeType === 'Questionnaires') {
                newParams['nodeType'] = 'FolderNode'
                node['newParams'] = newParams
              }
            })
          })
          if (data2) {
            _this.setState({
              tableContent: data2
            })
          }
        },
        'json'
      )
    },
    handleTabChange: function (tabIndex) {
      jQuery.get('/tree_display/set_session_last_open_tab?tab=' + tabIndex.toString())
    },
    render: function () {
      return (
        <ReactSimpleTabs
          className="tab-system"
          tabActive={parseInt(this.state.activeTab)}
          onAfterChange={this.handleTabChange}
        >
          <ReactSimpleTabs.Panel title="Courses">
            <FilterableTable key="table1" dataType="course" data={this.state.tableContent.Courses} />
          </ReactSimpleTabs.Panel>
          <ReactSimpleTabs.Panel title="Assignments">
            <FilterableTable
              key="table2"
              dataType="assignment"
              data={this.state.tableContent.Assignments}
            />
          </ReactSimpleTabs.Panel>
          <ReactSimpleTabs.Panel title="Questionnaires">
            <FilterableTable
              key="table2"
              dataType="questionnaire"
              data={this.state.tableContent.Questionnaires}
            />
          </ReactSimpleTabs.Panel>
        </ReactSimpleTabs>
      )
    }
  })

  if (document.getElementById('tree_display')) {
    React.render(React.createElement(TabSystem), document.getElementById('tree_display'))
  }
})
