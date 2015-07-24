jQuery(".tree_display.list").ready(function() {
  var data = {
    courses: [
      {id:'1', name: 'Sample Course 1', directory: 'd1', created_date: '12:00pm', updated_date: '20:00pm', type: 'course', actions: "empty"},
      {id:'2', name: 'Sample Course 2', directory: 'd2', created_date: '13:00pm', updated_date: '21:00pm', type: 'course', actions: "empty"},
      {id:'3', name: 'Sample Course 3', directory: 'd3', created_date: '14:00pm', updated_date: '22:00pm', type: 'course', actions: "empty"},
      {id:'4', name: 'Sample Course 4', directory: 'd4', created_date: '15:00pm', updated_date: '23:00pm', type: 'course', actions: "empty"}
    ],
    assignments: [
      {id: '1', name: 'Sample Assignment 1', directory: 'd1', created_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"},
      {id: '2', name: 'Sample Assignment 2', directory: 'd2', created_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"},
      {id: '3', name: 'Sample Assignment 3', directory: 'd3', created_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"},
      {id: '4', name: 'Sample Assignment 4', directory: 'd4', created_date: '12:00pm', updated_date: '1:00pm', type: 'assignment', actions: "empty"}
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

  var ContentTableRow = React.createClass({
    getInitialState: function() {
      return {
        expanded: false
      }
    },
    handleClick: function() {
      this.setState({
        expanded: !this.state.expanded
      }, function() {
        // console.log(this.state.expanded)
        this.props.rowClicked(this.props.id, this.state.expanded)
      })
    },
    render: function () {
      return (
          <tr onClick={this.handleClick} id={this.props.id}>
            <td>{this.props.name}</td>
            <td>{this.props.directory}</td>
            <td>{this.props.created_date}</td>
            <td>{this.props.updated_date}</td>
            <td>
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
      var style = {
        display: this.props.showElement
      }
      return (
        <tr style={style}>
          <td colSpan="5">
          {this.props.id}
          {this.props.showElement.toString()}
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
        // console.log(id)
        // console.log(expanded)
        // console.log("originally: ")
        // console.log(this.state.expandedRow)
        if (expanded) {
          this.setState({ 
            expandedRow: this.state.expandedRow.concat([id])
          // }, function() {
          //   console.log("After insert: ")
          //   console.log(this.state.expandedRow)
          })
        } else {
          var index = this.state.expandedRow.indexOf(id)
          if (index > -1) {
            this.setState({
              expandedRow: React.addons.update(this.state.expandedRow, {$splice: [[index, 1]]})
            // }, function() {
            //   console.log("After delete: ")
            //   console.log(this.state.expandedRow)
            })
          }
        }

      },
      handleSortingClick: function(colName, order) {
        this.props.onUserClick(colName, order)
      },
      render: function() {
        var _rows = []
        this.props.data.forEach(function(entry, i) {
          if (entry.name.indexOf(this.props.filterText) !== -1 ||
              entry.directory.indexOf(this.props.filterText) !== -1 ||
              entry.created_date.indexOf(this.props.filterText) !== -1 ||
              entry.updated_date.indexOf(this.props.filterText) !== -1) {
                _rows.push(<ContentTableRow
                            key={entry.type+'_'+(parseInt(entry.id)*2).toString()}
                            id={entry.type+'_'+(parseInt(entry.id)*2).toString()}
                            name={entry.name}
                            directory={entry.directory}
                            created_date={entry.created_date}
                            updated_date={entry.updated_date}
                            actions={entry.actions}
                            rowClicked={this.handleExpandClick}
                            />)
                _rows.push(<ContentTableDetailsRow
                            key={entry.type+'_'+(parseInt(entry.id)*2+1).toString()}
                            id={entry.type+'_'+(parseInt(entry.id)*2+1).toString()}
                            showElement={this.state.expandedRow.indexOf(entry.type+'_'+(parseInt(entry.id)*2).toString()) > -1 ? "block" : "none"}
                            />)
          } else {
            return;
          }
        }.bind(this))
        return (
          <table className="table table-striped table-hover">
            <thead>
              <tr>
                <th>
                  Name <SortToggle
                          colName="name"
                          order="normal"
                          handleUserClick={this.handleSortingClick} />
                </th>
                <th>
                  Directory <SortToggle
                          colName="directory"
                          order="normal"
                          handleUserClick={this.handleSortingClick} />
                </th>
                <th>
                  Creation Date <SortToggle
                          colName="created_date"
                          order="normal"
                          handleUserClick={this.handleSortingClick} />
                </th>
                <th>
                  Updated Date <SortToggle
                          colName="updated_date"
                          order="normal"
                          handleUserClick={this.handleSortingClick} />
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

  var FilterableTable = React.createClass({
    getInitialState: function() {
      return {
        filterText: '',
        data: this.props.data
      }
    },
    handleUserInput: function(filterText) {
      this.setState({
        filterText: filterText
      })
    },
    handleUserClick: function(colName, order) {
      this.setState({
        data: this.state.data.reverse()
      })
    },
    render: function() {
      return (
        <div className="filterable_table">
          <SearchBar
            filterText={this.state.filterText}
            onUserInput={this.handleUserInput}
          />
          <ContentTable
            data={this.state.data}
            filterText={this.state.filterText}
            onUserClick={this.handleUserClick}
          />
        </div>
      )
    }
  })

  var TabSystem = React.createClass({
    render: function() {
      return (
        <ReactSimpleTabs className="tab-system">
          <ReactSimpleTabs.Panel title="Courses">
            <FilterableTable key="table1" data={data.courses}/>
          </ReactSimpleTabs.Panel>
          <ReactSimpleTabs.Panel title="Assignments">
            <FilterableTable key="table2" data={data.assignments}/>
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
    document.getElementById("reactjs")
  )

})