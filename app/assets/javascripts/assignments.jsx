jQuery(document).ready(function() {

    var TabSystem = React.createClass({
        getInitialState: function() {
            return {
                tableContent: {
                    General: {},
                    Topics: {},
                    Rubrics: {},
                    ReviewStrategy: {},
                    DueDates: {}
                },
                activeTab: "1"
            }
        },
        componentWillMount: function() {
            var _this = this;

            jQuery.get("/assignments/get_session_last_open_tab", function(data) {
                _this.setState({
                    activeTab: data
                })
            })

        },
        handleTabChange: function(tabIndex) {
            jQuery.get("/assignments/set_session_last_open_tab?tab="+tabIndex.toString())
        },
        render: function() {
            return (
                <ReactSimpleTabs
                    className="tab-system"
                    tabActive={parseInt(this.state.activeTab)}
                    onAfterChange={this.handleTabChange}
                >
                    <ReactSimpleTabs.Panel title="General">
                        <script src="assignments/edit/general"></script>
                    </ReactSimpleTabs.Panel>
                    <ReactSimpleTabs.Panel title="Topics">

                    </ReactSimpleTabs.Panel>
                    <ReactSimpleTabs.Panel title="Rubrics">
                        <script src="assignments/edit/rubrics"></script>
                    </ReactSimpleTabs.Panel>
                    <ReactSimpleTabs.Panel title="Review Strategy">
                        <script src="assignments/edit/review_strategy"></script>
                    </ReactSimpleTabs.Panel>
                    <ReactSimpleTabs.Panel title="DueDates">
                        <script src="assignments/edit/due_dates"></script>
                    </ReactSimpleTabs.Panel>
                </ReactSimpleTabs>
            )
        }
    })
    
    if (document.getElementById("assignments")) {
        React.render(
            React.createElement(TabSystem),
            document.getElementById("assignments")
        )
    }

})