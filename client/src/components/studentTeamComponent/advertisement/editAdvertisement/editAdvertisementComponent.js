import React, { Component } from 'react'

class EditAdvertisementComponent extends Component {
    state = { 
        comments_for_advertisement: "",
        updateSuccess : false
    }

    componentDidMount () {
        this.setState({comments_for_advertisement: this.props.ad_content})
    }   

    changeCommentForAdvertisement = e => {
        e.preventDefault();
        this.setState({comments_for_advertisement: e.target.value})
    }

    submitCommentForAdvertisement = e => {
        e.preventDefault();
        this.props.updateCommentForAdvertisement(this.state.comments_for_advertisement)
    }
     
    render () {
        return  (
            <div>
             <h1>Edit Teammate Advertisement</h1>sendInvitaion = (
              <form onSubmit={this.submitCommentForAdvertisement}>
                <h3>Name team </h3>
                <div className="form-group">
                    <p><label for="comments_for_advertisement" >Please describe the qualifications you are looking for in a teammate.</label><br/>  
                    <input
                        type="text"
                        className="form-control"
                        placeholder="comments_for_advertisement"
                        value={this.state.comments_for_advertisement}
                        onChange={this.changeCommentForAdvertisement} />
                    </p>
                </div>
                <button type="submit" className="btn btn-primary"> Update </button>
              </form>
            </div>
        )
    }
    

}

export default EditAdvertisementComponent;