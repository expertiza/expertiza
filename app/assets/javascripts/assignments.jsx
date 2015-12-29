jQuery(document).ready(function() {

    var TabSystem = React.createClass({
        getInitialState: function() {
            return {
                tabs: [
                    {title: 'General', content: <script src="assignments/edit/general"></script>},
                    {title: 'Topics', content: 'Content 2'},
                    {title: 'Rubrics', content: 'Content 1'},
                    {title: 'ReviewStrategy', content: 'Content 2'},
                    {title: 'DueDates', content: 'Content 2'}
                ],
                active: 1
            };
        },
        render: function() {
            return <div>
                <TabsSwitcher items={this.state.tabs} active={this.state.active} onTabClick={this.handleTabClick}/>
                <TabsContent items={this.state.tabs} active={this.state.active}/>
            </div>;
        },
        handleTabClick: function(index) {
            this.setState({active: index})
        }
    });

    var TabsSwitcher = React.createClass({
        render: function() {
            var active = this.props.active;
            var items = this.props.items.map(function(item, index) {
                return <a href="#" className={'tab ' + (active === index ? 'tab_selected' : '')} onClick={this.onClick.bind(this, index)}>
				{item.title}
                </a>;
            }.bind(this));
            return <div>{items}</div>;
        },
        onClick: function(index) {
            this.props.onTabClick(index);
        }
    });

    var TabsContent = React.createClass({
        render: function() {
            var active = this.props.active;
            var items = this.props.items.map(function(item, index) {
                return <div className={'tabs-panel ' + (active === index ? 'tabs-panel_selected' : '')}>{item.content}</div>;
            });
            return <div>{items}</div>;
        }
    });

    //    getInitialState: function() {
    //        return {
    //            tableContent: {
    //                General: {},
    //                Topics: {},
    //                Rubrics: {},
    //                ReviewStrategy: {},
    //                DueDates: {}
    //            },
    //            activeTab: "1"
    //        }
    //    },
    //    componentWillMount: function() {
    //        var _this = this;
    //
    //        jQuery.get("/assignments/get_session_last_open_tab", function(data) {
    //            _this.setState({
    //                activeTab: data
    //            })
    //        })
    //
    //    },
    //    handleTabChange: function(tabIndex) {
    //        jQuery.get("/assignments/set_session_last_open_tab?tab="+tabIndex.toString())
    //    },
    //    render: function() {
    //        return (
    //            <ReactSimpleTabs
    //                className="tab-system"
    //                tabActive={parseInt(this.state.activeTab)}
    //                onAfterChange={this.handleTabChange}
    //            >
    //                <ReactSimpleTabs.Panel title="General">
    //                    <script src="assignments/edit/general"></script>
    //                </ReactSimpleTabs.Panel>
    //                <ReactSimpleTabs.Panel title="Topics">
    //
    //                </ReactSimpleTabs.Panel>
    //                <ReactSimpleTabs.Panel title="Rubrics">
    //                    <script src="assignments/edit/rubrics"></script>
    //                </ReactSimpleTabs.Panel>
    //                <ReactSimpleTabs.Panel title="Review Strategy">
    //                    <script src="assignments/edit/review_strategy"></script>
    //                </ReactSimpleTabs.Panel>
    //                <ReactSimpleTabs.Panel title="DueDates">
    //                    <script src="assignments/edit/due_dates"></script>
    //                </ReactSimpleTabs.Panel>
    //            </ReactSimpleTabs>
    //        )
    //    }
    //})
    
    if (document.getElementById("assignments")) {
        React.render(
            React.createElement(TabSystem),
            document.getElementById("assignments")
        )
    }

})