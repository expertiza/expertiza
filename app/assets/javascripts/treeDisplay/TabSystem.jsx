class TabSystem extends React.Component {

    constructor(props) {
        super(props)
        this.state = {
            allItemsDisplayed: {
                Courses: {},
                Assignments: {},
                Questionnaires: {}
            },
            activeTab: '1'
        }
    }

    componentWillMount() {
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

        getSessionLastOpenTab().then(function (response) {
            this.setState({
                activeTab: response
            })
        }.bind(this))

        getFolderResults().then(function (response) {
            jQuery.each(response, function (nodeType, outerNode) {
                Array.prototype.forEach.call(outerNode, function (node, i) {
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
            this.setState({
                allItemsDisplayed: response
            })
        }.bind(this))
    }

    handleTabChange(tabIndex) {
        setSessionLastOpenTab(tabIndex)
    }

    render() {
        return (
            <ReactSimpleTabs
                className="tab-system"
                tabActive={parseInt(this.state.activeTab)}
                onAfterChange={this.handleTabChange}
            >
                <ReactSimpleTabs.Panel title="Courses">
                    <FilterableTable key="table1" dataType="course" itemsDisplayed={this.state.allItemsDisplayed.Courses} />
                </ReactSimpleTabs.Panel>
                <ReactSimpleTabs.Panel title="Assignments">
                    <FilterableTable
                        key="table2"
                        dataType="assignment"
                        itemsDisplayed={this.state.allItemsDisplayed.Assignments}
                    />
                </ReactSimpleTabs.Panel>
                <ReactSimpleTabs.Panel title="Questionnaires">
                    <FilterableTable
                        key="table2"
                        dataType="questionnaire"
                        itemsDisplayed={this.state.allItemsDisplayed.Questionnaires}
                    />
                </ReactSimpleTabs.Panel>
            </ReactSimpleTabs>
        )
    }
}
