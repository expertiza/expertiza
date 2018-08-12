import React, {Component} from 'react';
import  { UnmountClosed as Collapse } from 'react-collapse';
import { Table } from 'react-bootstrap';
// import './../../assets/stylesheets/layout_2.css';

class Scoretable extends Component {

    constructor(props){
        super(props);
        this.state={
            vm: null,
        }
        this.toggle = this.toggle.bind(this)
    }
    toggle(index) {
        var row ="collapse"+index;
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
    componentDidMount(){
        this.setState({
            vm: this.props.vm
        })
    }
    render(){   
            if(this.state.vm!==undefined && this.state.vm!==null){
                return(
                    <div className="overflow-container">
                        <table className="scoresTable tbl_heat tablesorter">
                            <thead>
                                <tr>
                                    <th class="sorter-true">    Criterion </th>
                                    {this.state.vm[0].list_of_reviewers.map((i, index) =>
                                         <th key={`reviewer${index}`}> Review {index+1}
                                         </th>
                                    )}
                                </tr>
                            </thead>
                            {this.state.vm[0].list_of_rows.map((row, index)=>
                                <tbody key={`Review${index+1}`}>
                                    <tr onClick={()=>this.toggle(index+1)}>
                                        <td>
                                            {index+1}
                                        </td>
                                        {row.score_row.map((s,index)=>
                                        <td key={`score${index+1}`}className={s.color_code} align="center">
                                            {s.score_value}
                                        </td>
                                        )}
                                    </tr>
                                    <tr colSpan={3}>
                                        <td colSpan={3}>
                                            <Collapse isOpened={this.state[`collapse${index+1}`]===undefined?false:this.state[`collapse${index+1}`]}>
                                                    <div>{row.question_text}</div>
                                                    <div colSpan={3}>
                                                        <Table>
                                                            <tr >
                                                                <th>Review </th>
                                                                <th>Score</th>
                                                                <th>Comment</th>
                                                            </tr>
                                                            {row.score_row.map((s,index) => 
                                                                <tr colSpan={3}>
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
                                                        </Table>
                                                    </div>
                                            </Collapse>
                                        </td>
                                    </tr>
                                </tbody>
                            )}
                        </table>
                    </div>
                );
            }
            
            else{
                return(
                    <div>

                    </div>    
                );
            }  
    }
        
}

export default Scoretable;