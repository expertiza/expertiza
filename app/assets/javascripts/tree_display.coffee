jQuery(".tree_display.list").ready ->
  console.log('here')
  DOM = React.DOM
  headers = ["a", "b", "c"]

  TestBox = React.createClass
    render: ->
      DOM.label
        className: "col-lg-2"
        "here"

  tree = [
    {
      text: "Parent 1",
      icon: "glyphicon glyphicon-stop",
      nodes: [
        {
          text: "Child 1",
          nodes: [
            {
              text: "Grandchild 1"
            },
            {
              text: "Grandchild 2"
            }
          ]
        },
        {
          text: "Child 2"
        }
      ]
    },
    {
      text: "Parent 2"
    },
    {
      text: "Parent 3"
    },
    {
      text: "Parent 4"
    },
    {
      text: "Parent 5"
    }
  ];


  contentTable = React.createClass
    render: ->
      DOM.table
        className: "table table-striped"
        DOM.thead null,
          DOM.th null, "a"
          DOM.th null, "b"
          DOM.th null, this.props.name

  tabSystem = React.createClass
    render: ->
      React.createElement(ReactSimpleTabs, className: "whatever",
        React.createElement(ReactSimpleTabs.Panel, {"title": "Tab #1"},
          React.createElement(TestBox)
        ),
        React.createElement(ReactSimpleTabs.Panel, {"title": "Tab #2"},
          DOM.h2 null, "Content #2 here"
        ),
        React.createElement(ReactSimpleTabs.Panel, {"title": "Tab #3"},
          DOM.h2 null, "Content #3 here"
        )
      )

  TabSystem = React.createFactory(tabSystem)

  React.render(
    TabSystem(),
    document.getElementById("reactjs")
  )

