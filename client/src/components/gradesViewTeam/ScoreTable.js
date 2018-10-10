import React, {Component} from 'react';
import  { UnmountClosed as Collapse } from 'react-collapse';
import { Table } from 'react-bootstrap';
import { Loading } from './../UI/spinner/LoadingComponent';
import { NavLink } from 'react-router-dom';

class Scoretable extends Component {

    constructor(props){
        super(props);
        this.state={};
        this.toggle = this.toggle.bind(this)
    }
    toggle(tableindex, index) {
        var row ="collapse"+tableindex+"_"+index;
          if(this.state[row] === undefined){
              this.setState({ 
                  [row] : true
              })
          }
         else{
             this.setState({
                 [row] : !this.state[row]
             })
         }
         console.log(this.state);
    }
    toggleQuestions(tableindex) {
        var index = "collapseQuestions"+tableindex;
        if(this.state[index] === undefined){
            this.setState({ 
                [index] : true
            })
        }
       else{
           this.setState({
               [index] : !this.state[index]
           })
       }
    }
    componentWillReceiveProps = (newProps)=>{
        this.setState({
            vm: newProps.vm
        })
    }
    render(){   
            if((this.state.vm !== null && this.state.vm!== undefined && this.state.vm.length>0)){
                return(
                    <div className="overflow-container">
                                {this.state.vm.filter((q) => (q.questionnaire_type==='ReviewQuestionnaire'
                                                              && q.list_of_reviewers.length>0))
                                .map((rq, tableindex)=>
                                    <div key={`tableindex${tableindex}`} className="row mt-5">
                                        <div className="col-12">
                                            <Collapse isOpened={this.state[`collapseQuestions${tableindex}`]===undefined?false:this.state[`collapseQuestions${tableindex}`]}>
                                                <table class="table">
                                                    <tbody>
                                                        <tr>
                                                            <td>#</td>
                                                            <td>Question</td>
                                                        </tr>
                                                        {rq.list_of_rows.map((row, index)=>
                                                            <tr key={`Questions_of_review${index+1}`}style={{backgroundColor: '#ffffff'}}>
                                                                <td>{index+1}</td>
                                                                <td>{row.question_text}</td>
                                                            </tr>
                                                        )}
                                                    </tbody>
                                                </table>
                                            </Collapse>
                                            <h5 style={{display : 'inline-block'}}>Review (Round: {rq.round} of {rq.rounds})</h5>
                                            <span className="spn_qsttog" onClick={()=>this.toggleQuestions(tableindex)} title="Click to display/hide questions">toggle question list</span>
                                            <span class="spn_tooltip" data-toggle="tooltip" data-placement="right" title="Colors are scaled from poor to excellent in the following order: red, orange, yellow, light-green, dark-green">color legend</span>
                                            <span class="spn_tooltip" data-toggle="tooltip" data-placement="right" title="Click a row to see the comments for the respective question. Click 'Review Total' row to see Add'l Comments. Useful tip: decreasing your browser's zoom to 75% or 90% many improve your experience.">interaction legend</span>
                                            <table className="mt-1 scoresTable tbl_heat tablesorter">
                                                <thead>
                                                    <tr>
                                                        <th class="sorter-true">    Criterion </th>
                                                        {  
                                                            rq.list_of_reviews.map((i, index) =>
                                                            <th>
                                                             <NavLink to={`/response/view/${i.id}`}> Review {index+1} </NavLink>
                                                             {/* <th key={`reviewer${index}`}> Review {index+1} { i.id} */}
                                                            </th>
                                                        )}

                                                        <th class="sorter-true"> Avg </th>
                                                        <th class="sorter-true"> metric-1 </th>
                                                    </tr>
                                                </thead>
                                                {rq.list_of_rows.map((row, index)=>
                                                    <tbody key={`Review${index+1}`}>
                                                        <tr onClick={()=>this.toggle(tableindex, index+1)}>
                                                            <td>
                                                                {index+1}
                                                            </td>
                                                            {row.score_row.map((s,index)=>
                                                            <td key={`score${index+1}`} className={s.color_code} align="center" title={s.comment}>
                                                               {s.comment.length>0?<span className="underlined"> {s.score_value}</span>:
                                                               <span>{s.score_value}</span>}
                                                            </td>
                                                            )}
                                                            <td>
                                                                {(row.score_row.reduce( ( p, c ) => p + c.score_value, 0)/ row.score_row.length).toFixed(2)}
                                                            </td>
                                                            <td>
                                                                {row.countofcomments}
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colSpan={row.score_row.length+2}>
                                                                <Collapse isOpened={this.state[`collapse${tableindex}_${index+1}`]===undefined?false:this.state[`collapse${tableindex}_${index+1}`]}>
                                                                    <div>{row.question_text}</div>
                                                                    <div>
                                                                        <Table>
                                                                            <tbody>
                                                                                <tr >
                                                                                    <th>Review </th>
                                                                                    <th>Score</th>
                                                                                    <th>Comment</th>
                                                                                </tr>
                                                                                {row.score_row.map((s,index) => 
                                                                                <tr key ={`scorerow${index+1}`} colSpan={3}>
                                                                                    <td>
                                                                                        {`Review ${index+1}`}
                                                                                    </td>
                                                                                    <td className={s.color_code} align="center">
                                                                                        {s.score_value}
                                                                                    </td>
                                                                                    <td>
                                                                                        {s.comment}
                                                                                    </td>
                                                                                </tr>
                                                                                )}
                                                                            </tbody>
                                                                        </Table>
                                                                    </div>
                                                                </Collapse>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                )}
                                            </table>
                                        </div>
                                    </div>
                                )}
                    </div>
                );
            }   
            else{
                return(
                    <div>
                            <Loading />
                    </div>    
                );
            }  
    }
        
}

export default Scoretable;