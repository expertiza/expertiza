DOM = React.DOM

TestBox = React.createClass
  render: ->
    DOM.label
      className: "col-lg-2"
      "here"

testBox = React.createFactory(TestBox)

jQuery ->
  console.log "Hey"
  React.render(
    testBox(),
    document.getElementById("reactjs")
  )