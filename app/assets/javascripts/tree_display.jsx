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

  if (document.getElementById('tree_display')) {
    React.render(React.createElement(TabSystem), document.getElementById('tree_display'))
  }
})
