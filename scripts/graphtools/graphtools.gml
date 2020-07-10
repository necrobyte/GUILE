#region Graph

/// @func Graph( _object )
/// @name Graph
/// @class
///
/// @classdesc Generic graph
///
/// @arg {Bool} [directed=false]
///
/// @return {Graph} - Graph struct

function Graph( ) constructor {
	/// @member {Bool} directed
	/// @memberof Graph
	///
	/// @desc If true, Graph is directed
	directed = ( argument_count > 0 ) ? argument[ 0 ] : false;
	
	/// @member {Map} node
	/// @memberof Graph
	///
	/// @desc Map holding all nodes
	node = new Map();
	
	/// @member {Map} adj
	/// @memberof Graph
	///
	/// @desc Map holding all outgoing node-connection information
	adj = new Map();
	
	/// @member {Map} pred
	/// @memberof Graph
	///
	/// @desc Map holding all incoming node-connection information. Only for directed graphs.
	pred = new Map();
	
	/*
		methods
	*/
	
	/// @method add_edge
	/// @memberof Graph
	///
	/// @desc Add an edge between nodes a and b. If nodes are not in graph, nodes are added.
	///
	/// @arg {Any} a
	/// @arg {Any} b
	/// @arg {Array} [attr]
	
	static add_edge = function( a, b ) {
		var _weight = ( argument_count > 2 ) ? argument[ 2 ] : undefined;
		var _attr = undefined;
		
		if ( is_array( _weight ) ) {
			_attr = _weight;
			_weight = undefined;
		} else if ( argument_count > 3 ){
			_attr = argument[ 3 ];
		}
		
		if ( is_undefined( node.get( a ) ) ) {
			add_node( a );
		}
		
		if ( is_undefined( node.get( b ) ) ) {
			add_node( b );
		}
		
		var _adj = adj.get( a );
		var _pred = directed ? pred.get( b ) : adj.get( b );
		
		var _edge = _adj.get( b );
		
		if ( is_undefined( _edge ) ) {
			_edge = { };
			_edge.weight = is_undefined( _weight ) ? 1 : _weight;
		} else if ( !is_undefined( _weight ) ) {
			_edge.weight = _weight;
		}
		
		var n = is_undefined( _attr ) ? 0 : array_length( _attr );
		for( var i = 0; i < n; i++ ) {
			variable_struct_set( _edge, _attr[ i ][ 0 ], _attr[ i ][ 1 ] );
		}
		
		_adj.set( b, _edge );
		_pred.set( a, _edge );
	}
	
	/// @method add_node
	/// @memberof Graph
	///
	/// @desc add node. If node exists, update attributes.
	///
	/// @arg {Any} node
	/// @arg {Array} [attr] [key, value] pairs
	
	static add_node = function( _node ) {
		var _attr = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
		
		var _new_node = node.get( _node );
		
		if ( is_undefined( _new_node ) ) {
			_new_node = { };
			
			node.add( _node, _new_node );
			adj.add( _node, new Map() );
			
			if ( directed ) {
				pred.add( _node, new Map() );
			}
		}
		
		var n = is_undefined( _attr ) ? 0 : array_length( _attr );
		for( var i = 0; i < n; i++ ) {
			variable_struct_set( _new_node, _attr[ i ][ 0 ], _attr[ i ][ 1 ] );
		}
	}
	
	/// @method adjacency
	/// @memberof Graph
	///
	/// @desc Returns an iterator over [ node, adjacency struct ] for all nodes
	///
	/// @return {IteratorDict}
	
	static adjacency = function() {
		var _iter = __iter_dict( adj, function() {
			return key_iter.next();
		}, function( _key ) {
			return data.get( _key ).items().to_struct();
		}, function() {
			return key_iter.is_done();
		} );
		
		_iter.key_iter = adj.keys();
		
		return _iter;
	}
	
	/// @method clear
	/// @memberof Graph
	///
	/// @desc Remove all nodes and edges
		
	static clear = function() {
		node.clear();
		adj.clear();
		pred.clear();
	}
	
	/// @method degree
	/// @memberof Graph
	///
	/// @desc Returns node degree in Graph.
	///
	/// @arg {Any} node
	///
	/// @return {Number}
	
	static degree = function( _node ) {
		var _adj = adj.get( _node );
		if ( is_undefined( _adj ) ) {
			throw "The node " + string( _node ) + " is not in the graph.";
		}
		
		return _adj.items().reduce( function( a, e ) { return a + ( e[ 1 ] ).weight; }, 0 );
	}
	
	/// @method get
	/// @memberof Graph
	///
	/// @desc Return node from Graph. If node is absent, return undefined.
	///
	/// @arg {Any} node
	///
	/// @return {Struct}
	
	static get = function( _node ) {
		return node.get( _node );
	}
	
	/// @method get_edge
	/// @memberof Graph
	///
	/// @desc Returns edge atribute Struct associated with edge between a and b. If edge does not exist, return undefined.
	///
	/// @arg {Any} a
	/// @arg {Any} a
	///
	/// @return {Bool}
	
	static get_edge = function( a, b ) {
		var _adj = adj.get( a );
		return is_undefined( _adj ) ? undefined : _adj.get( b );
	}
	
	/// @method has_edge
	/// @memberof Graph
	///
	/// @desc Returns True if the graph has edge between a and b.
	///
	/// @arg {Any} a
	/// @arg {Any} a
	///
	/// @return {Bool}
	
	static has_edge = function( a, b ) {
		if ( is_undefined( node.get( a ) ) ) {
			return false;
		}
		
		return !is_undefined( adj.get( a ).get( b ) );
	}
	
	/// @method has_node
	/// @memberof Graph
	///
	/// @desc Returns True if the graph contains the node n
	///
	/// @arg {Any} node
	///
	/// @return {Bool}
	
	static has_node = function( _node ) {
		return node.exists( _node );
	}
	
	/// @method neighbors
	/// @memberof Graph
	///
	/// @desc Returns an iterator over all neighbors of node.
	///
	/// @arg {Any} node
	/// @arg {Bool} [data=false] If false only keys would be returned.
	///
	/// @return {Iterator}
	
	static neighbors = function( _node ) {
		var _adj = adj.get( _node );
		if ( is_undefined( _adj ) ) {
			throw "The node " + string( _node ) + " is not in the graph.";
		}
		var _data = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		if ( _data ) {
			var _iter = __iter_dict( _adj.keys(), function() {
				return data.next();
			}, function( _key ) {
				return node.get( _key );
			}, function() {
				return data.is_done();
			} );
	
			_iter.node = node;
		
			return _iter;
		}
		
		return _adj.keys();
	}
	
	/// @method nodes
	/// @memberof Graph
	///
	/// @desc Returns Iterator of nodes
	///
	/// @arg {Bool} [data=false] If false only keys would be returned.
	///
	/// @return Iterator
	
	static nodes = function( ) {
		var _data = ( argument_count > 0 ) ? argument[ 0 ] : false;
		return _data ? node.items() : node.keys();
	}
	
	/// @method number_of_nodes
	/// @memberof Graph
	///
	/// @desc Returns the number of nodes in the graph.
	///
	/// @return {Number}
	
	static number_of_nodes = function() {
		return node.size;
	}
	
	/// @method remove_edge
	/// @memberof Graph
	///
	/// @desc Remove the edge connection between a and b.
	///
	/// @arg {Any} a
	/// @arg {Any} b
	
	static remove_edge = function( a, b ) {
		if ( is_undefined( node.get( a ) ) || is_undefined( nodes.get( b ) ) ) {
			exit;	
		}
		
		var _adj = adj.get( a );
		var _pred = directed ? pred.get( b ) : adj.get( b );
			
		var _edge = _adj.get( b );
		
		if ( is_undefined( _edge ) ) {
			exit;	
		}
		
		_adj.remove( b );
		_pred.remove( a );
		
		delete _edge;
	}
	
	/// @method remove_node
	/// @memberof Graph
	///
	/// @desc Remove node a from graph.
	///
	/// @arg {Any} node
	
	static remove_node = function( _node ) {
		if ( is_undefined( node.get( _node ) ) ) {
			exit;	
		}
		
		var _adj = adj.get( _node );
		var _adj_edges = iter( _adj );
				
		if ( directed ) {
			while( !_adj_edges.is_done() ){
				var _edge = _adj_edges.next();
				delete _edge[ 1 ];
				_adj.remove( _edge[ 0 ] );
			}
			
			var _adj = pred.get( _node );
			
			while( !_adj_edges.is_done() ){
				var _edge = _adj_edges.next();
				delete _edge[ 1 ];
				_adj.remove( _edge[ 0 ] );
			}
		} else {
			while( !_adj_edges.is_done() ){
				var _edge = _adj_edges.next();
				delete _edge[ 1 ];
				_adj.remove( _edge[ 0 ] );
				adj.get( _edge[ 0 ] ).remove( _node );
			}
		}
		
		node.remove( _node );
	}
	
	/// @method size
	/// @memberof Graph
	///
	/// @desc Returns the number of nodes in the graph.
	///
	/// @return {Number}
	
	static size = number_of_nodes
}

#endregion