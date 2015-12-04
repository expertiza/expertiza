var TreeView = React.createClass({

  propTypes: {
    levels: React.PropTypes.number,

    expandIcon: React.PropTypes.string,
    collapseIcon: React.PropTypes.string,
    emptyIcon: React.PropTypes.string,
    nodeIcon: React.PropTypes.string,

    color: React.PropTypes.string,
    backColor: React.PropTypes.string,
    borderColor: React.PropTypes.string,
    onhoverColor: React.PropTypes.string,
    selectedColor: React.PropTypes.string,
    selectedBackColor: React.PropTypes.string,

    enableLinks: React.PropTypes.bool,
    highlightSelected: React.PropTypes.bool,
    showBorder: React.PropTypes.bool,
    showTags: React.PropTypes.bool,

    nodes: React.PropTypes.arrayOf(React.PropTypes.number)
  },

  getDefaultProps: function () {
    return {
      levels: 2,

      expandIcon: 'glyphicon glyphicon-plus',
      collapseIcon: 'glyphicon glyphicon-minus',
      emptyIcon: 'glyphicon',
      nodeIcon: 'glyphicon glyphicon-stop',

      color: undefined,
      backColor: undefined,
      borderColor: undefined,
      onhoverColor: '#F5F5F5', // TODO Not implemented yet, investigate radium.js 'A toolchain for React component styling'
      selectedColor: '#FFFFFF',
      selectedBackColor: '#428bca',

      enableLinks: false,
      highlightSelected: true,
      showBorder: true,
      showTags: false,

      nodes: []
    }
  },

  setNodeId: function(node) {

    if (!node.nodes) return;

    var _this = this;
    node.nodes.forEach(function checkStates(node) {
      node.nodeId = _this.props.nodes.length;
      _this.props.nodes.push(node);
      _this.setNodeId(node);
    });
  },

  render: function() {

    this.setNodeId({ nodes: data });

    var children = [];
    if (data) {
      var _this = this;
      data.forEach(function (node) {
        children.push(<TreeNode node={node}
                                level={1}
                                visible={true}
                                options={_this.props} />);
      });
    }

    return (
      <div id='treeview' className='treeview'>
        <ul className='list-group'>
          {children}
        </ul>
      </div>
    );
  }
});


var TreeNode = React.createClass({

  getInitialState: function() {
    var node = this.props.node;
    return {
      expanded: (node.state && node.state.hasOwnProperty('expanded')) ?
                  node.state.expanded :
                    (this.props.level < this.props.options.levels) ?
                      true :
                      false,
      selected: (node.state && node.state.hasOwnProperty('selected')) ? 
                  node.state.selected :
                  false
    }
  },

  toggleExpanded: function(id, event) {
    this.setState({ expanded: !this.state.expanded });
    event.stopPropagation();
  },

  toggleSelected: function(id, event) {
    this.setState({ selected: !this.state.selected });
    event.stopPropagation();
  },

  render: function() {

    var node = this.props.node;
    var options = this.props.options;

    var style;
    if (!this.props.visible) {

      style = { 
        display: 'none' 
      };
    }
    else {

      if (options.highlightSelected && this.state.selected) {
        style = {
          color: options.selectedColor,
          backgroundColor: options.selectedBackColor
        };
      }
      else {
        style = {
          color: node.color || options.color,
          backgroundColor: node.backColor || options.backColor
        };
      }

      if (!options.showBorder) {
        style.border = 'none';
      }
      else if (options.borderColor) {
        style.border = '1px solid ' + options.borderColor;
      }
    } 

    var indents = [];
    for (var i = 0; i < this.props.level-1; i++) {
      indents.push(<span className='indent'></span>);
    }

    var expandCollapseIcon;
    if (node.nodes) {
      if (!this.state.expanded) {
        expandCollapseIcon = (
          <span className={options.expandIcon}
                onClick={this.toggleExpanded.bind(this, node.nodeId)}>
          </span>
        );
      }
      else {
        expandCollapseIcon = (
          <span className={options.collapseIcon}
                onClick={this.toggleExpanded.bind(this, node.nodeId)}>
          </span>
        );
      }
    }
    else {
      expandCollapseIcon = (
        <span className={options.emptyIcon}></span>
      );
    }

    var nodeIcon = (
      <span className='icon'>
        <i className={node.icon || options.nodeIcon}></i>
      </span>
    );

    var nodeText;
    if (options.enableLinks) {
      nodeText = (
        <a href={node.href} /*style="color:inherit;"*/>
          {node.text}
        </a>
      );
    }
    else {
      nodeText = (
        <span>{node.text}</span>
      );
    }

    var badges;
    if (options.showTags && node.tags) {
      badges = node.tags.map(function (tag) {
        return (
          <span className='badge'>{tag}</span>
        );
      });
    }

    var children = [];
    if (node.nodes) {
      var _this = this;
      node.nodes.forEach(function (node) {
        children.push(<TreeNode node={node}
                                level={_this.props.level+1}
                                visible={_this.state.expanded && _this.props.visible}
                                options={options} />);
      });
    }

    return (
      <li className='list-group-item'
          style={style}
          onClick={this.toggleSelected.bind(this, node.nodeId)}
          key={node.nodeId}>
        {indents}
        {expandCollapseIcon}
        {nodeIcon}
        {nodeText}
        {badges}
        {children}
      </li>
    );
  }
});