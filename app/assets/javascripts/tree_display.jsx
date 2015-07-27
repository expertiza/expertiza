jQuery(".tree_display.list").ready(function() {
  var testData = {
    Courses: [
      {id:'1', name: 'Sample Course 1', directory: 'd1', creation_date: '12:00pm', updated_date: '20:00pm', type: 'course', actions: "empty"},
      {id:'2', name: 'Sample Course 2', directory: 'd2', creation_date: '13:00pm', updated_date: '21:00pm', type: 'course', actions: "empty"},
      {id:'3', name: 'Sample Course 3', directory: 'd3', creation_date: '14:00pm', updated_date: '22:00pm', type: 'course', actions: "empty"},
      {id:'4', name: 'Sample Course 4', directory: 'd4', creation_date: '15:00pm', updated_date: '23:00pm', type: 'course', actions: "empty"}
    ],
    Assignments: [
      {id: '1', name: 'Sample Assignment 1', directory: 'd1', creation_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"},
      {id: '2', name: 'Sample Assignment 2', directory: 'd2', creation_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"},
      {id: '3', name: 'Sample Assignment 3', directory: 'd3', creation_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"},
      {id: '4', name: 'Sample Assignment 4', directory: 'd4', creation_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"}
    ]
  }

  var RowAction = React.createClass({
    render: function() {
      return (
        <div>
        <button type="button" className="glyphicon glyphicon-edit"></button>
        </div>
      )
    }
  })


  var SimpleTableRow = React.createClass({
    render: function () {
      var creation_date;
      var updated_date;
      if (this.props.creation_date && this.props.updated_date) {
        creation_date = this.props.creation_date.replace("T", " || ")
        updated_date = this.props.updated_date.replace("T", " || ")
      }
      return (
          <tr id={this.props.id}>
            <td width="23%">{this.props.name}</td>
            <td width="23%">{this.props.directory}</td>
            <td width="23%">{creation_date}</td>
            <td width="23%">{updated_date}</td>
            <td width="8%">
              <RowAction
                actions={this.props.actions}
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
                      key={entry.type+'_'+(i).toString()}
                      id={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2).toString()}
                      name={entry.name}
                      directory={entry.directory}
                      creation_date={entry.creation_date}
                      updated_date={entry.updated_date}
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
                Creation
              </th>
              <th>
                Updated
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
      console.log(event.target)
      this.setState({
        expanded: !this.state.expanded
      }, function() {
        this.props.rowClicked(this.props.id, this.state.expanded)
      })
    },
    render: function () {
      var creation_date;
      var updated_date;
      if (this.props.creation_date && this.props.updated_date) {
        creation_date = this.props.creation_date.replace("T", " || ")
        updated_date = this.props.updated_date.replace("T", " || ")
      }
      return (
          <tr onClick={this.handleClick} id={this.props.id}>
            <td width="23%">{this.props.name}</td>
            <td width="23%">{this.props.directory}</td>
            <td width="23%">{creation_date}</td>
            <td width="23%">{updated_date}</td>
            <td width="8%">
              <RowAction
                actions={this.props.actions}
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
          <td colSpan="5">
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
            <form>
                <input
                    type="text"
                    placeholder="Search..."
                    value={this.props.filterText}
                    ref="filterTextInput"
                    onChange={this.handleChange}
                />
            </form>
        );
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
                            key={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2).toString()}
                            id={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2).toString()}
                            name={entry.name}
                            directory={entry.directory}
                            creation_date={entry.creation_date}
                            updated_date={entry.updated_date}
                            actions={entry.actions}
                            rowClicked={_this.handleExpandClick}
                            />)
                _rows.push(<ContentTableDetailsRow
                            key={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2+1).toString()}
                            id={entry.type+'_'+(parseInt(entry.nodeinfo.id)*2+1).toString()}
                            showElement={_this.state.expandedRow.indexOf(entry.type+'_'+(parseInt(entry.nodeinfo.id)*2).toString()) > -1 ? "block" : "none"}
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
              <th width="23%">
                Name <SortToggle
                        colName="name"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="23%">
                Directory <SortToggle
                        colName="directory"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="23%">
                Creation Date <SortToggle
                        colName="creation_date"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="23%">
                Updated Date <SortToggle
                        colName="updated_date"
                        order="normal"
                        handleUserClick={this.handleSortingClick} />
              </th>
              <th width="8%">Actions</th>
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
      }
    },
    handleUserInput: function(filterText) {
      this.setState({
        filterText: filterText
      })
    },
    handleUserClick: function(colName, order) {
      this.props.data = this.props.data.reverse()
      this.forceUpdate()
    },
    render: function() {
      return (
        <div className="filterable_table">
          <SearchBar
            filterText={this.state.filterText}
            onUserInput={this.handleUserInput}
          />
          <ContentTable
            data={this.props.data}
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
            Tab 3 here
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