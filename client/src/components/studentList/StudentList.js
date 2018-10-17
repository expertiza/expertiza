import { Table } from 'reactstrap';
import React, { Component } from 'react'
import {NavLink} from 'react-router-dom'
import { Loading } from '../UI/spinner/LoadingComponent';

class StudentList extends Component {
    constructor(props){
        super(props);
        var arr = []
        var len = this.props.studentsTeamedWith.length;
        for(var i=0; i<len; i++)
            arr.push(this.props.studentsTeamedWith[i])

        this.state = {
            studentsTeamedWith: arr,
            studentTasks: this.props.studentTasks,
            teamCourse: this.props.teamCourse,
            tasks_not_started: this.props.tasks_not_started,
            hasTopics: this.props.hasTopics,
            hasBadges: this.props.hasBadges
        };
        console.log(this.state.hasTopics)
        console.log(this.state.teamCourse[0])
        if(this.state.taskrevisions== undefined){

        }
        else
            console.log(this.state.taskrevisions.length)


    }
    
    render(){
        return(
            
            <div className="main_content">
                <h2>Assignments</h2>
                
            <div>
                <div className="taskbox" style={{margin: '20px'}}>
                
                    
                    <div>
                        <strong>&nbsp;&nbsp;<span class="tasknum">&nbsp;{this.state.tasks_not_started == undefined ? "" : this.state.tasks_not_started.length}&nbsp;</span> Tasks not yet started<br/></strong>
                        {this.state.tasks_not_started == undefined ? <Loading/> : 
                            this.state.tasks_not_started.map(task =>
                                <div><NavLink to={`/submitted_content/${task.participant.id}/edit`}>
                                        <span>&nbsp; &raquo;{task.assignment.name} {task.current_stage} ({task.relative_deadline}) left </span>
                                    </NavLink><br></br>
                                </div>
                                
                            )
                        }
                    </div><br/>

                    <div>
                        <strong>&nbsp;&nbsp;<span class="tasknum">&nbsp;0&nbsp;</span> Revisions<br/></strong>
                        {/* {this.state.taskrevisions == undefined ? <Loading/> : 
                            this.state.taskrevisions.map(revision =>
                                <span>&nbsp; &raquo; {revision.assignment} {revision.stage}
                                        {revision.time_to_go} left
                                </span>
                            )
                        } */}
                        {/* {this.state.taskrevisions == undefined ? "" : this.state.taskrevisions.length} */}
                    </div><br/>
                        
                    <strong><span>Students who have teamed with you</span></strong>
                    <br/>
                    <br/>
                    <div>
                    {this.state.studentsTeamedWith.map((students, index) =>
                        <div>                            
                            <strong>&nbsp;&nbsp;<span className="tasknum">&nbsp;{students.length}&nbsp;</span>
                                {this.state.teamCourse[index] == null ? " assignments not associated with any course" : this.state.teamCourse[index]}
                            </strong><br/><br/>
                            { 
                                students.map(student => 
                                    <div><span className="notification">&nbsp; &raquo; {student}</span><br></br></div>
                                )
                            }
                            
                        </div>
                    )}
                    </div>
                </div>
            </div>
            {
                this.state.studentTasks === undefined || this.state.studentTasks === null ? 
                <Loading/> :
                <div className="container">
                <div className="row">
                <div className="col-md-12">
                    <div className="topictable">
                        <Table className="table table-striped" cellpadding="2" >
                            
                            <thead>
                                <tr className = "taskheader">
                                <th>Assignment</th>
                                {this.state.hasTopics == true ? <th>Topic</th> : <th hidden></th>}
                                <th>Current Stage</th>
                                <th>Review Grade</th>
                                {this.state.hasBadges == true ? <th>Badges</th> : <th hidden></th>}
                                <th>Stage Deadline<img src='assets/images/info.png' 
                                title="You can change 'Prefered time Zone' in 'Profile' in the banner. " alt="img">
                                </img></th>  
                                {/* <th>Publishing Rights</th>                   */}
                                </tr>
                            </thead>
                            {
                                this.state.studentTasks.map(studentTask =>(
                                    <tr>
                                        <td><NavLink to={`/studentTaskView/${studentTask.participant.id}`}>{studentTask.assignment.name}</NavLink> <br /> {studentTask.assignment.course_id== null ? "" : studentTask.course_name}</td>
                                        {this.state.hasTopics == true ?
                                            <td>{studentTask.topic == null ? '-' : studentTask.topic}</td> : 
                                            <td hidden></td> }
                                        <td> {studentTask.current_stage}</td>
                                        <td> {studentTask.review_grade}</td>
                                        {this.state.hasBadges == true ? <td> {studentTask.badges}</td> : <td hidden></td>}
                                        <td>{studentTask.stage_deadline.replace('T','\n').substring(0, studentTask.stage_deadline.lastIndexOf('.'))}</td>
                                        {/* <td key={studentTask.assignment.id}> {(studentTask.participant.permission_granted) ? "allowed":"denied"}</td> */}
                                    </tr>
                                ))
                            }
                        </Table>
                        </div>
                    </div>
                </div>
            </div>

            }
            
        </div>
        );
    }
}
export default StudentList;