import React, { Component } from 'react';

class ResponseTable extends Component {
    render(){
        var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',hour: 'numeric', minute: 'numeric', second: 'numeric'  };
        return(
            <div className="row" style={{paddingTop: 20, paddingLeft: 20}}>
            <table width="100%">
                <tbody>
                    <tr>
                        <td align="left" width="70%"><b>{this.props.title}</b></td>
                        <td align="left"><b>Last Reviewed: </b><span>
                        {(!this.props.response.updated_at)?'Not Available':
                          new Date(this.props.response.updated_at.split('T')).toLocaleString("en-US", options)}
                    </span></td> 
                    {/* {console.log(this.props.response.updated_at)} */}
                    </tr>
                </tbody>
            </table>
            <table className="table">
                <tbody>
                    {this.props.questions.map((i, index) =>
                        <tr className={(index%2)==0?"table_warning":"table_info"}>
                            <tbody>
                                <tr key={"question_"+this.props.type+"_"+index}>
                                    <td ><span style={{"fontWeight":"bold"}}>{index+1 +". "+i.txt}</span></td>
                                </tr>
                                <table>
                                    <tbody>
                                        <tr key={"answer_"+this.props.type+"_"+index} className={(index%2)==0?"table_warning":"table_info"}>
                                                <td>
                                                    <div className={"c"+this.props.answers[index].answer}
                                                        style={{"width":"30px",
                                                                "height":"30px",
                                                                "borderRadius":"50%",
                                                                "fontSize":"15px",
                                                                "color":"black",
                                                                "lineHeight":"30px",
                                                                "textAlign":"center"}
                                                                }> 
                                                        {this.props.answers[index].answer}
                                                    </div>
                                                </td>
                                                <td style={{"paddingLeft":"10px"}}>
                                                    {this.props.answers[index].comments}            
                                                </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </tbody> 
                        </tr>
                )}
                <tr>
                    <td>Additional Comments: {this.props.response.additional_comment}</td>
                </tr>
                </tbody>
            </table>
            </div>
        );
    }
};

export default ResponseTable;