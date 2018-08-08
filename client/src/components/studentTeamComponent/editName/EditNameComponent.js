import React from 'react'

const editNameComponent = (props) => {
    return (
        <div className="container text-center">
          <form onSubmit={props.submitEditName}>
             <h1>Edit Team Name</h1>
            <div className="form-group text-left">
              {/* <label for="team_name" className="text-left">team name</label> */}
              <input
                type="text"
                className="form-control"
                placeholder="Team Name"
                value={props.value}
                onChange={props.team_name}
              />
            </div>
            <button type="submit" className="btn btn-primary" > Save </button>
            <button type="button" className="btn btn-danger ml-4" onClick={props.backButton}> Back </button>
          </form>
        </div>
    )
}
export default editNameComponent;

// <%= form_for '/student_teams/update', method: :put do %>
//   <%= hidden_field_tag 'team_id', @team.id %>
//   <%= hidden_field_tag 'student_id', @student.id %>
