import React, { Component } from 'react' 
import request from "superagent";
import ReactDropzone from 'react-dropzone'

class StudentTaskUpload extends Component {

    onDrop = (files) => {
        const req = request.post('');
    
        files.forEach(file => {
          req.attach(file.name, file);
        });
    
        req.end();
      }

      constructor(props){
          super(props);
          this.state={files:[]}
      }
  
      render() {
          return(
            <div style={{marginTop: '10px', padding: '5px'}}>
                <h1> Submit work for { this.props.match.params.id} </h1>
                
                <ReactDropzone onDrop={this.onDrop}>
                Submit your files here
                </ReactDropzone>
                </div>
          )
    }
}
export default StudentTaskUpload;