import React, { Component } from 'react';
import './App.css';
import Main from './components/MainComponent';
import {BrowserRouter } from 'react-router-dom';


class App extends Component {
  render() {
    return (
      <div>
          <BrowserRouter>
            <Main />
          </BrowserRouter>
      </div>
    );
  }
}

export default App;
