/** @jsx React.DOM */
'use strict';

var Tabs = ReactSimpleTabs;
var App = React.createClass({
  onMount: function(selectedIndex, $selectedPanel, $selectedTabMenu) {
    console.log('on mount, showing tab ' + selectedIndex);
  },
  onBeforeChange: function(selectedIndex, $selectedPanel, $selectedTabMenu) {
    console.log('before the tab ' + selectedIndex);
  },
  onAfterChange: function(selectedIndex, $selectedPanel, $selectedTabMenu) {
    console.log('after the tab ' + selectedIndex);
  },
  render: function() {
    return (
      <Tabs tabActive={2} onBeforeChange={this.onBeforeChange} onAfterChange={this.onAfterChange} onMount={this.onMount}>
        <Tabs.Panel title='Tab #1'>
          <h2>Content #1</h2>
        </Tabs.Panel>
        <Tabs.Panel title='Tab #2'>
          <h2>Content #2</h2>
        </Tabs.Panel>
        <Tabs.Panel title='Tab #3'>
          <h2>Content #3</h2>
        </Tabs.Panel>
      </Tabs>
    );
  }
});

React.renderComponent(<App />, document.getElementById('tabs'));
