import { Table } from 'reactstrap';
import React, { Component } from 'react'
import {NavLink} from 'react-router-dom'
import { Loading } from '../UI/spinner/LoadingComponent';

class StudentList extends Component {
    state = {
            studentsTeamedWith: this.props.studentsTeamedWith,
            studentTasks: this.props.studentTasks
        };
    
    render(){
        return(
            
            <div className="main_content">
                <h2>Assignments</h2>
                {/* <PublishingRights></PublishingRights> */}
                
            <div>
                <div class="taskbox" style={{margin: '20px'}}>
                    <strong>&nbsp;&nbsp;<span class="tasknum">&nbsp;&nbsp;</span> Tasks not yet started<br/></strong><br/>
                    <li>{this.state.studentsTeamedWith[0]}<br></br></li> 
                    <li>{this.state.studentsTeamedWith[1]}<br></br></li>
                    <li>{this.state.studentsTeamedWith[2]}<br></br></li> 
                </div>
            </div>
            <div className="container">
                <div className="row">
                <div className="col-md-12">
                    <div className="topictable">
                        <Table className="table table-striped" cellpadding="2" >
                            <thead>
                                <tr class = "taskheader">
                                <th>Assignment</th>
                                <th>Topic</th>
                                <th>Current Stage</th>
                                <th>Review Grade</th>
                                <th>Badges</th>
                                <th>Stage Deadline<img src='assets/images/info.png' 
                                title="You can change 'Prefered time Zone' in 'Profile' in the banner. " alt="img">
                                </img></th>  
                                {/* <th>Publishing Rights</th>                   */}
                                </tr>
                            </thead>
                            {
                                this.state.studentTasks === undefined ? <Loading /> :
                                this.state.studentTasks.map(studentTask =>(
                                    <tr>
                                        <td key={studentTask.assignment.id}><NavLink to={`/studentTaskView/${studentTask.assignment.id}`}>{studentTask.assignment.name}</NavLink> <br /> {studentTask.assignment.course_id== null ? "" : studentTask.course_name}</td>
                                        <td key={studentTask.assignment.id}> {studentTask.topic == null ? "-" : studentTask.topic}</td>
                                        <td key={studentTask.assignment.id}> {studentTask.current_stage}</td>
                                        <td key={studentTask.assignment.id}> {"N/A"}</td>
                                        <td key={studentTask.assignment.id}> {""}</td>
                                        <td key={studentTask.assignment.id}> {studentTask.stage_deadline}</td>
                                        {/* <td key={studentTask.assignment.id}> {(studentTask.participant.permission_granted) ? "allowed":"denied"}</td> */}
                                    </tr>
                                ))
                            }
                        </Table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        );
    }
}
export default StudentList;