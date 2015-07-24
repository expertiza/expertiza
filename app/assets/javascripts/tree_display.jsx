jQuery(".tree_display.list").ready(function() {

  var data = {
    courses: [
      {name: 'Sample Course 1', directory: 'd1', created_date: '12:00pm', updated_date: '20:00pm', actions: "empty"},
      {name: 'Sample Course 2', directory: 'd2', created_date: '13:00pm', updated_date: '21:00pm', actions: "empty"},
      {name: 'Sample Course 3', directory: 'd3', created_date: '14:00pm', updated_date: '22:00pm', actions: "empty"},
      {name: 'Sample Course 4', directory: 'd4', created_date: '15:00pm', updated_date: '23:00pm', actions: "empty"}
    ],
    assignments: [
      {name: 'Sample Assignment 1', directory: 'd1', created_date: '12:00pm', updated_date: '1:00pm', actions: "empty"},
      {name: 'Sample Assignment 2', directory: 'd2', created_date: '12:00pm', updated_date: '1:00pm', actions: "empty"},
      {name: 'Sample Assignment 3', directory: 'd3', created_date: '12:00pm', updated_date: '1:00pm', actions: "empty"},
      {name: 'Sample Assignment 4', directory: 'd4', created_date: '12:00pm', updated_date: '1:00pm', actions: "empty"}
    ]
  }

  var RowAction = React.createClass({
    render: function() {
      return (
        <div>
        {this.props.actions}
        </div>
      )
    }
  })

  var ContentTableRow = React.createClass({
    render: function () {
      return (
        <tr>
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
      handleClick: function(colName, order) {
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
                            key={entry.name+i.toString()}
                            name={entry.name}
                            directory={entry.directory}
                            created_date={entry.created_date}
                            updated_date={entry.updated_date}
                            actions={entry.actions}
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
                          handleUserClick={this.handleClick} />
                </th>
                <th>
                  Directory <SortToggle
                          colName="directory"
                          order="normal"
                          handleUserClick={this.handleClick} />
                </th>
                <th>
                  Creation Date <SortToggle
                          colName="created_date"
                          order="normal"
                          handleUserClick={this.handleClick} />
                </th>
                <th>
                  Updated Date <SortToggle
                          colName="updated_date"
                          order="normal"
                          handleUserClick={this.handleClick} />
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
    render: function() {
      return (
        <ReactSimpleTabs className="tab-system">
          <ReactSimpleTabs.Panel title="Courses">
            <FilterableTable data={data.courses}/>
          </ReactSimpleTabs.Panel>
          <ReactSimpleTabs.Panel title="Assignments">
            <FilterableTable data={data.assignments}/>
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