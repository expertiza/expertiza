import React, { Component} from 'react'

class Hyperlinks extends Component {

    render () {
        if(this.props.show)
            return (
                <div style={{marginTop: '10px', padding: '5px'}}>
                    {this.props.team.submitted_hyperlinks.split("\n").map((element, index) =>
                    (index !== 0 && element.substring(1) !== "")?
                    <div className="radio" style={{paddingLeft:20}}>
                        <label>
                        <input type="radio" value={element.substring(1)} checked={false} />
                        {element.substring(1)}
                        </label>
                    </div>: <div> </div>
                    )
                }
                </div>
            )
        else{
            return(
                <div>
                </div>
            )
        }
    }
}

export default Hyperlinks;