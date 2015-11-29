jQuery(document).ready(function() {


    
    if (document.getElementById("assignments")) {
        React.render(
            React.createElement(TabSystem),
            document.getElementById("assignments")
        )
    }

})