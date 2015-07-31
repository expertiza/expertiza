jQuery(".tree_display.list").ready(function() {

  // This preloadedImages function is refered from http://jsfiddle.net/slashingweapon/8jAeu/
  // Actually I am not using the values in preloadedImages, but image loading speed is indeed getting faster
  var preloadedImages = []
  function preloadImages() {
    for (var idx = 0; idx < arguments.length; idx++) {
        var oneImage = new Image()
        oneImage.src = arguments[idx];
        preloadedImages.push(oneImage);
    }
  }

  var RowAction = React.createClass({
    getInitialState: function() {
      return {
        showDetails: false
      }
    },
    handleButtonClick: function(e) {
      e.stopPropagation()
      if (e.target.type === 'button') {
        if (e.target.name === 'more') {
          this.setState({
            showDetails: true
          })
        }
      }
    },
    render: function() {
      var moreContent = []
      var moreButtonStyle = {
        display: ""
      }
      if (this.state.showDetails) {
        moreButtonStyle.display = "none"
        moreContent.push(
          <span>
            <a title="Edit" href={"/"+this.props.nodeType+"/"+(parseInt(this.props.id)/2).toString()+"/edit"}><img src="/assets/tree_view/edit-icon-24.png" /></a>
            <a title="Delete" href={"/"+this.props.nodeType+"/delete?id="+(parseInt(this.props.id)/2).toString()}><img src="/assets/tree_view/delete-icon-24.png" /></a>
            <a title={this.props.private? "Make public" : "Make private"} href={"/"+this.props.nodeType+"/toggle_access?id="+(parseInt(this.props.id)/2).toString()}><img src={"/assets/tree_view/lock-"+(this.props.private? "off-" : "")+"disabled-icon-24.png"} /></a>
            <a title="Copy" href={"/"+this.props.nodeType+"/copy?assets=course&id="+(parseInt(this.props.id)/2).toString()}><img src="/assets/tree_view/Copy-icon-24.png" /></a>
            <br/>
          </span>
        )
        if (this.props.nodeType === 'course') {
          console.log(this.props.private)
          moreContent.push(
            <span>
              <img src="/assets/tree_view/add-ta-24.png" />
              <img src="/assets/tree_view/add-assignment-24.png" />
              <img src="/assets/tree_view/add-participant-24.png" />
              <br/>
              <img src="/assets/tree_view/create-teams-24.png" />
              <img src="/assets/tree_view/360-dashboard-24.png" />
            </span>
          )
        } else if (this.props.nodeType === 'assignment') {
          var urlText = "/"+this.props.nodeType+"/"+(parseInt(this.props.id)/2).toString()+"/edit"
          moreContent.push(
            <span>
              <img src="/assets/tree_view/create-teams-24.png" />
              <img src="/assets/tree_view/360-dashboard-24.png" />
            </span>
          )
        } else {
        }
      }
      return (
        <div onClick={this.handleButtonClick}>
          <button style={moreButtonStyle} name="more" type="button" className="glyphicon glyphicon-option-horizontal"></button>
          {moreContent}
        </div>
      )
    }
  })

  var SimpleTableRow = React.createClass({
    render: function () {
      var creation_date;
      var updated_date;
      if (this.props.creation_date && this.props.updated_date) {
        creation_date = this.props.creation_date.replace("T", "<br/>")
        updated_date = this.props.updated_date.replace("T", "<br/>")
      }
      var nodeTypeRaw = this.props.id.split("_")[0]
      var nodeType = nodeTypeRaw.substring(0, nodeTypeRaw.length-4).toLowerCase()
      var id = this.props.id.split("_")[1]
      return (
          <tr id={this.props.id}>
            <td width="21%">{this.props.name}</td>
            <td width="21%">{this.props.directory}</td>
            <td width="21%" dangerouslySetInnerHTML={{__html: creation_date}}></td>
            <td width="21%" dangerouslySetInnerHTML={{__html: updated_date}}></td>
            <td width="16%">
              <RowAction
                  actions={this.props.actions}
                  key={"simpleTable_"+this.props.id}
                  nodeType={nodeType}
                  private={this.props.private}
                  id={id}
              />
            </td>
          </tr>
      )
    }
  })

  var SimpleTable = React.createClass({
    render: function() {
      var _rows = []
      var _this = this
      if (this.props.data) {
        this.props.data.forEach(function(entry, i){
          _rows.push(<SimpleTableRow
                      key={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2).toString()+'_'+i}
                      id={entry.type+'_'+(parseInt(entry.nodeinfo.node_object_id)*2).toString()+'_'+i}
                      name={entry.name}
                      directory={entry.directory}
                      creation_date={entry.creation_date}
                      updated_date={entry.updated_date}
                      private={entry.private}
                      actions={entry.actions}
                      />)
        })
      }
      return (
        <table className="table table-hover">
          <thead>
            <tr>
              <th>
                Assignment Name
              </th>
              <th>
                Directory
              </th>
              <th>
                Creation Date
              </th>
              <th>
                Updated Date
              </th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {_rows}
          </tbody>
        </table>
      )
    }
  })

  var ContentTableRow = React.createClass({
    getInitialState: function() {
      return {
        expanded: false
      }
    },
    handleClick: function(event) {
      if (event.target.type != 'button') {
        this.setState({
          expanded: !this.state.expanded
        }, function() {
          this.props.rowClicked(this.props.id, this.state.expanded)
        })
      } else {
        event.stopPropagation()
      }
    },
    render: function () {
      var creation_date;
      var updated_date;
      if (this.props.creation_date && this.props.updated_date) {
        creation_date = this.props.creation_date.replace("T", "<br/>")
        updated_date = this.props.updated_date.replace("T", "<br/>")
      }
      var nodeTypeRaw = this.props.id.split("_")[0]
      var nodeType = nodeTypeRaw.substring(0, nodeTypeRaw.length-4).toLowerCase()
      var id = this.props.id.split("_")[1]
      return (
          <tr onClick={this.handleClick} id={this.props.id}>
            <td width="21%">{this.props.name}</td>
            <td width="21%">{this.props.directory}</td>
            <td width="21%" dangerouslySetInnerHTML={{__html: creation_date}}></td>
            <td width="21%" dangerouslySetInnerHTML={{__html: updated_date}}></td>
            <td width="16%">
              <RowAction
                actions={this.props.actions}
                key={this.props.id}
                nodeType={nodeType}
                private={this.props.private}
                id={id}
              />
            </td>
          </tr>
      )
    }
  })

  var ContentTableDetailsRow = React.createClass({
    render: function() {
      var style;
      if (this.props.children && this.props.children.length > 0) {
        style = {
          display: this.props.showElement
        }
      } else {
        style = {
          display: "none"
        }
      }
      return (
        <tr style={style}>
          <td>
          </td>
          <td colSpan='4'>
            <SimpleTable
             key={"simpletable_"+this.props.id}
             data={this.props.children}
            />
          </td>
        </tr>
      )
    }
  })

  var SearchBar = React.createClass({
    handleChange: function() {
        this.props.onUserInput(
            this.refs.filterTextInput.getDOMNode().value
        );
    },
    render: function() {
        return (
            <span>
                <input
                    type="text"
                    placeholder="Search..."
                    value={this.props.filterText}
                    ref="filterTextInput"
                    onChange={this.handleChange}
                />
            </span>
        );
    }
  })

  var FilterButton = React.createClass({
    handleChange: function() {
      this.props.onUserFilter(this.props.filterOption,
                              this.refs.filterCheckbox.getDOMNode().checked)
    },
    render: function() {
      return (
         <span>
           <input type="checkbox"
                  checked={this.props.inputCheckboxValue}
                  ref="filterCheckbox"
                  onChange={this.handleChange}>
             {"Show " + this.props.filterOption+" items?"}
           </input>
         </span> 
      )
    }
  })

  var SortToggle = React.createClass({
    handleClick: function() {
      if (this.props.order === "normal") {
        this.props.order = "reverse" 
      } else {
        this.props.order = "normal" 
      }
      this.props.handleUserClick(this.props.colName, this.props.order)
    },
    render: function() {
      return (
        <span className="glyphicon glyphicon-sort" onClick={this.handleClick}></span>
      )
    }
  })

  var ContentTable = React.createClass({
    getInitialState: function() {
      return {
        expandedRow: []
      }
    },
    handleExpandClick: function(id, expanded) {
      if (expanded) {
        this.setState({ 
          expandedRow: this.state.expandedRow.concat([id])
        })
      } else {
        var index = this.state.expandedRow.indexOf(id)
        if (index > -1) {
          this.setState({
            expandedRow: React.addons.update(this.state.expandedRow, {$splice: [[index, 1]]})
          })
        }
      }
    },
    handleSortingClick: function(colName, order) {
      this.props.onUserClick(colName, order)
    },
    render: function() {
      var _rows = []
      var _this = this
      if (this.props) {
        jQuery.each(this.props.data, function(i, entry){
          if ((entry.name && entry.name.indexOf(_this.props.filterText) !== -1) ||
              (entry.directory && entry.directory.indexOf(_this.props.filterText) !== -1) ||
              (entry.creation_date && entry.creation_date.indexOf(_this.props.filterText) !== -1) ||
              (entry.updated_date && entry.updated_date.indexOf(_this.props.filterText) !== -1)) {
                _rows.push(<ContentTableRow
                            key={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2).toString()+'_'+i}
                            id={entry.type+'_'+(parseInt(entry.nodeinfo.node_object_id)*2).toString()+'_'+i}
                            name={entry.name}
                            directory={entry.directory}
                            creation_date={entry.creation_date}
                            updated_date={entry.updated_date}
                            actions={entry.actions}
                            private={entry.private}
                            rowClicked={_this.handleExpandClick}
                            />)
                _rows.push(<ContentTableDetailsRow
                            key={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2+1).toString()+'_'+i}
                            id={entry.type+'_'+(parseInt(entry.nodeinfo.node_object_id)*2+1).toString()+'_'+i}
                            showElement={_this.state.expandedRow.indexOf(entry.type+'_'+(parseInt(entry.nodeinfo.node_object_id)*2).toString()+'_'+i) > -1 ? "" : "none"}
                            children={entry.children}
                            />)
          } else {
            return;
          }
        })
      }
      return (
        <table className="table table-striped table-hover">
          <thead>
            <tr>
              <th width="21%">
                Name <SortToggle
                        colName="name"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="21%">
                Directory <SortToggle
                        colName="directory"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="21%">
                Creation Date <SortToggle
                        colName="creation_date"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="21%">
                Updated Date <SortToggle
                        colName="updated_date"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="16%">Actions</th>
            </tr>
          </thead>
          <tbody>
            {_rows}
          </tbody>
        </table>
      )
    }
  })

  var FilterableTable = React.createClass({
    getInitialState: function() {
      return {
        filterText: '',
        privateCheckbox: true,
        publicCheckbox: true,
        tableData: this.props.data
      }
    },
    handleUserInput: function(filterText) {
      this.setState({
        filterText: filterText
      })
    },
    handleUserClick: function(colName, order) {
      this.setState({
        tableData: this.state.tableData.reverse()
      })
    },
    componentWillReceiveProps: function(nextProps) {
      this.setState({
        tableData: nextProps.data
      })
    },
    handleUserFilter: function(name, checked) {
      var privateCheckboxStatus = this.state.privateCheckbox
      var publicCheckboxStatus = this.state.publicCheckbox
      if (name === 'private') {
        privateCheckboxStatus = checked
      } else {
        publicCheckboxStatus = checked
      }
      var tmpData = this.props.data.filter(function(element) {
        if (!privateCheckboxStatus && publicCheckboxStatus) {
        // if private is false, and public is true, display public ONLY
          return element.private === false
        } else if (privateCheckboxStatus && publicCheckboxStatus) {
        // if private is true, and public is true, display all data
          return true
        } else if (!privateCheckboxStatus && !publicCheckboxStatus) {
        // if private is false, and public is false, display nothing  
          return false
        } else {
        // if private is true, and public is false, display private ONLY 
          return element.private === true
        }
      })
      if (name === 'private') {
        this.setState({
          tableData: tmpData,
          privateCheckbox: privateCheckboxStatus
        })
      } else {
        this.setState({
          tableData: tmpData,
          publicCheckbox: publicCheckboxStatus
        })
      }
    },
    render: function() {
      return (
        <div className="filterable_table">
          <SearchBar
            filterText={this.state.filterText}
            onUserInput={this.handleUserInput}
          />
          <FilterButton
            filterOption="private"
            onUserFilter={this.handleUserFilter}
            inputCheckboxValue={this.state.privateCheckbox}
          />
          <FilterButton
            filterOption="public"
            onUserFilter={this.handleUserFilter}
            inputCheckboxValue={this.state.publicCheckbox}
          />
          <ContentTable
            data={this.state.tableData}
            filterText={this.state.filterText}
            onUserClick={this.handleUserClick}
          />
        </div>
      )
    }
  })

  var TabSystem = React.createClass({
    getInitialState: function() {
      return {
        tableContent: {
          Courses: {},
          Assignments: {},
          Questionnaires: {}
        }
      }
    },
    componentWillMount: function() {
      var _this = this
      preloadImages('/assets/tree_view/edit-icon-24.png',
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
                    '/assets/tree_view/view-scheduled-tasks.png',
                    '/assets/tree_view/view-publish-rights-24.png'
                    )
      jQuery.get("/tree_display/get_folder_node_ng", function(data, status) {
        jQuery.post("/tree_display/get_children_node_ng",
          {
            reactParams: {
              child_nodes: data,
              nodeType: 'FolderNode'
            }
          }, function(data2, status) {
            jQuery.each(data2, function(nodeType, outerNode) {
              jQuery.each(outerNode, function(i, node) {
                var newParams = {
                  key: node.name + "|" + node.directory,
                  nodeType: nodeType,
                  child_nodes: node.nodeinfo
                }
                if (nodeType === 'Assignments') {
                  newParams["nodeType"] = 'AssignmentNode'
                } else if (nodeType === 'Courses') {
                  newParams["nodeType"] = 'CourseNode'
                } else if (nodeType === 'Questionnaires') {
                  newParams["nodeType"] = 'FolderNode'
                }
                jQuery.post('/tree_display/get_children_node_2_ng',
                  {
                    reactParams2: newParams
                  },
                  function(data3) {
                    node["children"] = data3
                  },
                  'json'
                )

              }) 
            })
            console.log(data2)
            if (data2) {
              _this.setState({
                tableContent: data2
              })
            }
          },
          'json')
      })
      
    },
    render: function() {
      return (
        <ReactSimpleTabs className="tab-system">
          <ReactSimpleTabs.Panel title="Courses">
            <FilterableTable key="table1" data={this.state.tableContent.Courses}/>
          </ReactSimpleTabs.Panel>
          <ReactSimpleTabs.Panel title="Assignments">
            <FilterableTable key="table2" data={this.state.tableContent.Assignments}/>
          </ReactSimpleTabs.Panel>
          <ReactSimpleTabs.Panel title="Questionnaires">
            <FilterableTable key="table2" data={this.state.tableContent.Questionnaires}/>
          </ReactSimpleTabs.Panel>
        </ReactSimpleTabs>
      )
    }
  })


  React.render(
    React.createElement(TabSystem),
    document.getElementById("tree_display")
  )

})