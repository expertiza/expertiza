import React, {Component} from 'react';
import { Table } from 'react-bootstrap';
import { Loading } from './../UI/spinner/LoadingComponent';

class Summary extends Component {
    render () {
    
        return(
            (this.props.vm!==null && this.props.vm!==undefined && this.props.vm.length>0)?
                    <div>
                        <h4>Summary</h4>
                        <Table className="table_summary">
                            <tr>
                                <th></th>
                                <th colspan="2" className="table_summary_header">Submitted Work</th>
                                <th colspan="2" className="table_summary_header">Author Feedback</th>
                                <th colspan="2">Teammate Review</th>
                                <th></th>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Average</td>
                                <td>Range</td>
                                <td>Average</td>
                                <td>Range</td>
                                <td>Average</td>
                                <td>Range</td>
                                <td></td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>94%</td>
                                <td>70-100</td>
                                <td>95%</td>
                                <td>88-100</td>
                                <td>100%</td>
                                <td>100-100</td>
                                <td></td>
                            </tr>
                        </Table>
                        <br/>
                    </div>
                    :
                    <div>
                        <Loading />
                    </div>
            );
    }
}

export default Summary;