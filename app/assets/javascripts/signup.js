function showHideTeamAndMembers(){
    var element = document.getElementById('teamsAndMembers');
    var show = element.innerHTML == 'Hide all teams';
    if (show){
        element.innerHTML='Show all teams';
    }else{
        element.innerHTML='Hide all teams';
    }
    toggleTeamsAndMembers();
}

function toggleTeamsAndMembers(numTeams) {
    for(var i=1; i<=numTeams; i++){
        var elem = document.getElementById(i.toString() + "_myDiv");
        if (elem.style.display == 'none') {
            elem.style.display = '';
        } else {
            elem.style.display = 'none';
        }
    }
}

function toggleSingleTeamAndMember(i) {
    var elem = document.getElementById(i.toString() + "_myDiv");
    if (elem.style.display == 'none') {
        elem.style.display = '';
    } else {
        elem.style.display = 'none';
    }
}