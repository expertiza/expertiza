import React, { Component, Fragment } from 'react'
import {FormGroup, Radio, RadioButton} from 'react-bootstrap'
import request from "superagent";
import { connect } from 'react-redux'
import ReactDropzone from 'react-dropzone'
import Aux from '../../hoc/Aux/Aux'
import { Loading } from '../UI/spinner/LoadingComponent';
import { SubmitURL, DeleteURL } from '../../redux/actions/StudentUploadTask'
import Hyperlinks from '../gradesViewTeam/Hyperlinks';

class StudentTaskUpload extends Component {


    constructor(props){
        super(props);
        this.state={files:[],
      input_value: 'http://',
      urls:[], current_url:'',
      deleteURL_i: 0};
      this.handleChange = this.handleChange.bind(this);
      this.submittedURL = this.submittedURL.bind(this);
      this.onDrop = this.onDrop.bind(this);
      this.onPreviewDrop = this.onPreviewDrop.bind(this);
      this.handleOptionChange = this.handleOptionChange.bind(this);
      this.deleteURL = this.deleteURL.bind(this);
    }

    onDrop = () => {
        const req = request.post('');
    
        this.state.files.forEach(file => {
          req.attach(file.name, file);
        });
    
        req.end();
      }

    onPreviewDrop = (files) => {
        this.setState({
          files: this.state.files.concat(files),
         });
      }
      
    handleChange(event) {
        this.setState({current_url: event.target.value});
      }
    
    handleOptionChange(index, event) {
        this.setState({
            deleteURL_i: index - 1
        });
      }

    submittedURL(event) {
        this.props.SubmitURL(this.props.participant.id, this.state.current_url);
        event.preventDefault();
      }

    deleteURL(event)
    {
        alert('idex '+ this.state.deleteURL_i)
        console.log(this.state.deleteURL_i);
        this.props.DeleteURL(this.props.participant.id, this.state.deleteURL_i)
        event.preventDefault();
    }

      onPreviewDrop = (files) => {
        this.setState({
          files: this.state.files.concat(files),
         });
      }
  
    render() {
          let drag_drop;
          let urls;
          let submit_url;
          let assign_name;
          let loading;
          let previewStyle;
          let hyperLinkActions;
          let submittedFiles;

          if(this.props.loaded){
            submit_url = <div style={{marginTop: '10px', padding: '5px'}}>
                <form onSubmit={this.submittedURL}>
                <label>
                <ul><li><h5>Submit Hyperlink's</h5></li></ul>
                <input type="text" defaultValue={this.state.input_value} onChange={this.handleChange}/>
                <input type="submit" value="Upload Link" />
                </label>
            </form>
          </div>

            previewStyle = {
                display: 'inline',
                width: 50,
                height: 50,
            };

            hyperLinkActions = 
                <div style={{marginTop: '10px', padding: '5px'}}>
                        <form onSubmit={this.deleteURL}>
                        <input type="submit" value="Delete Hyperlink" />
                        <div style={{marginTop: '10px', padding: '5px'}}>
                        <div className="radio" style={{paddingLeft:20}}>
                            {this.props.team.submitted_hyperlinks.split("\n").map((element, index) =>
                            (index !== 0 && element.substring(1) !== "")?
                            <div>
                                <label>
                                <input type="radio" value={element.substring(1)} key={index} onChange={(e) => this.handleOptionChange(index, e)} />
                                {element.substring(1)}
                                </label>
                                </div>: <div> </div>
                            )
                        }
                        </div>
                        </div>
                    </form>
                </div>
          

            drag_drop = <div style={{marginTop: '10px', padding: '5px'}}>
            <ul><li><h5>Drag & Drop</h5></li></ul>
              <ReactDropzone onDrop={this.onPreviewDrop}></ReactDropzone>
              {this.state.files.length > 0 &&
                    <Fragment>
                        <h3>Previews</h3>
                        {this.state.files.map((file) => (
                        <img
                            alt="Preview"
                            key={file.preview}
                            src={file.preview}
                            style={previewStyle}
                        />
                        ))}
                        <form onSubmit={this.onDrop}>
                            <label>
                            <input type="submit" value="Upload link" />
                            </label>
                        </form>
                    </Fragment>
                    }
                    
              </div>
        
            submittedFiles = <div style={{marginTop: '10px', padding: '5px'}}>
            
            
            </div>

            assign_name = (this.props.assignment.name !== null|| this.props.assignment.name.length!==0) ?
                <div style={{marginTop: '10px', padding: '5px'}}>
                <h1> Submit or Review work for { this.props.assignment.name} </h1> 
                </div> : <h1> Submit or Review work for  link_to @assignment.name, @assignment.spec_location </h1>

          }
          else{
            loading = <Loading/>
          }
        return (
            <Aux>
                <div className="container">
                    {loading}
                </div>
                <div className="container-fluid left">
                
                    {assign_name}
                    {submit_url}
                    {hyperLinkActions}
                    {drag_drop}
                </div>
            </Aux>
        )
    }
}

const mapStateToProps = state => {
    return {
        participant: state.studentTaskView.participant,
        can_submit : state.studentTaskView.can_submit,
        can_review: state.studentTaskView.can_review,
        can_take_quiz: state.studentTaskView.can_take_quiz,
        authorization: state.studentTaskView.authorization,
        team : state.studentTaskView.team,
        denied: state.studentTaskView.denied,
        assignment: state.studentTaskView.assignment,
        can_provide_suggestions: state.studentTaskView.can_provide_suggestions,
        topic_id: state.studentTaskView.topic_id,
        topics: state.studentTaskView.topics,
        timeline_list: state.studentTaskView.timeline_list,
        loaded: state.studentTaskView.loaded,
        submission_allowed: state.studentTaskView.submission_allowed,
        check_reviewable_topics: state.studentTaskView.check_reviewable_topics,
        metareview_allowed: state.studentTaskView.metareview_allowed,
        get_current_stage: state.studentTaskView.get_current_stage
    }
}

const mapDispatchToProps = dispatch => (
{
    SubmitURL:  (id, submission) => {dispatch(SubmitURL(id,submission))},
    DeleteURL: (id, chk_links) => {dispatch(DeleteURL(id, chk_links))}
});

export default connect(mapStateToProps, mapDispatchToProps)(StudentTaskUpload);