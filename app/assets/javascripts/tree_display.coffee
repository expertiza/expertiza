jQuery(".tree_display.list").ready ->
  console.log('here')
  DOM = React.DOM
  headers = ["a", "b", "c"]

  TestBox = React.createClass
    render: ->
      DOM.label
        className: "col-lg-2"
        "here"

  outerTable = React.createClass
    render: ->
      DOM.table
        className: "table table-striped"
        DOM.thead null,
          DOM.th null,
            "a"
          DOM.th null,
            "b"
          DOM.th null,
            "c"

  OuterTable = React.createFactory(outerTable)

  React.render(
    OuterTable(),
    document.getElementById("reactjs")
  )

