import React, { Component} from 'react'

class Hyperlinks extends Component {

    render () {
        if(this.props.show)
            return (
                <div>
                    {this.props.team.submitted_hyperlinks.split("\n").map((element, index) =>
                    (index !== 0)?
                    <div style={{paddingLeft:20}}>
                        <a href={element.substring(1)}>{element.substring(1)}</a>
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