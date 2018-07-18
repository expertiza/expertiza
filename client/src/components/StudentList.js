import { Table } from 'reactstrap';
import React, { Component } from 'react';
import PublishingRights from './PublishingRights'

class StudentList extends Component {
    constructor(props) {
        super(props);
        this.state = {
            studentsTeamedWith: this.props.studentsTeamedWith.studentsTeamedWith,
            studentTasks: this.props.studentTasks.studentTasks
        };
        
        console.log(this.state.studentsTeamedWith.length);
        console.log(this.state.studentTasks.studentTasks);
    }
    render(){
        const students = this.state.studentsTeamedWith;
        // const student = this.state.studentsTeamedWith.map((d) => <li>{d}</li>);
        return(
            
            <div className="main_content">
                <h2>Assignments</h2>
                
                <PublishingRights></PublishingRights>
                
            <div>
                <div class="taskbox">
                    <strong>&nbsp;&nbsp;<span class="tasknum">&nbsp;&nbsp;</span> Tasks not yet started<br/></strong><br/>
                    <li>
                        {this.state.studentsTeamedWith[0]}<br></br>
                        {this.state.studentsTeamedWith[1]}<br></br>
                        {this.state.studentsTeamedWith[2]}<br></br>
                       </li> 
                        

                    
                </div>
            </div>
            <div class="topictable">
            <Table class=" table table-striped" cellpadding="2" >
                <thead>
                    <tr class = "taskheader">
                    <th>Assignment</th>
                    <th>Course</th>
                    <th>Topic</th>
                    <th>Current Stage</th>
                    <th>Review Grade</th>
                    <th>Badges</th>
                    <th>Stage Deadline<img src='assets/images/info.png' 
                     title="You can change 'Prefered time Zone' in 'Profile' in the banner. ">
                    </img></th>  
                    <th>Publishing Rights</th>                  
                    </tr>
                </thead>
                {
                    this.state.studentTasks.studentTasks == undefined
                    ? 'Loading.....'
                    :this.state.studentTasks.studentTasks.map(studentTask =>(
                        <tr>
                            <td key={studentTask.assignment.id}>{studentTask.assignment.name}</td>
                            <td key={studentTask.assignment.id}> {studentTask.assignment.course_id== null ? "" : studentTask.assignment.course_id}</td>
                            <td key={studentTask.assignment.id}> {studentTask.topic == null ? "-" : studentTask.topic}</td>
                            <td key={studentTask.assignment.id}> {studentTask.current_stage}</td>
                            <td key={studentTask.assignment.id}> {"N/A"}</td>
                            <td key={studentTask.assignment.id}> {""}</td>
                            <td key={studentTask.assignment.id}> {studentTask.stage_deadline}</td>
                            <td key={studentTask.assignment.id}> {""}</td>
                        </tr>
                            
                    ))

                }
            </Table>
            </div>
                
            </div>
        );
    }
}
export default StudentList;