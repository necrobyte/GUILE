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
	
	/// @member {Struct} nodes
	/// @memberof Graph
	///
	/// @desc Struct holding all nodes
	nodes = new Map();
	
	/// @member {Struct} adj
	/// @memberof Graph
	///
	/// @desc Struct holding all outgoing node-connection information
	adj = new Map();
	
	/// @member {Struct} pred
	/// @memberof Graph
	///
	/// @desc Struct holding all incoming node-connection information. Only for directed graphs.
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
		
		if ( is_undefined( nodes.get( a ) ) ) {
			add_node( a );
		}
		
		if ( is_undefined( nodes.get( b ) ) ) {
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
		
		var _new_node = nodes.get( _node );
		
		if ( is_undefined( _new_node ) ) {
			_new_node = { };
			
			nodes.add( _node, _new_node );
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
	
	/// @method clear
	/// @memberof Graph
	///
	/// @desc Remove all nodes and edges
		
	static clear = function() {
		delete( nodes );
		delete( adj );
		delete( pred );
		
		nodes = { };
		adj = { };
		pred = { };
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
		if ( is_undefined( nodes.get( a ) ) ) {
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
		return nodes.exists( _node );
	}
	
	/// @method number_of_nodes
	/// @memberof Graph
	///
	/// @desc Returns the number of nodes in the graph.
	///
	/// @return {Number}
	
	static number_of_nodes = function() {
		return data.size();
	}
	
	/// @method remove_edge
	/// @memberof Graph
	///
	/// @desc Remove the edge connection between a and b.
	///
	/// @arg {Any} a
	/// @arg {Any} b
	
	static remove_edge = function( a, b ) {
		if ( is_undefined( nodes.get( a ) ) || is_undefined( nodes.get( b ) ) ) {
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
		if ( is_undefined( nodes.get( _node ) ) ) {
			exit;	
		}
		
		var _adj = adj.get( _node );
		var _adj_edges = variable_struct_get_names( _adj );
		var n = array_length( _adj_edges );
		
		if ( directed ) {
			var _pred = variable_struct_get( directed ? pred : adj, _node );	
		} else {
			for( var i = 0; i < n; i++ ) {
				var _edge = variable_struct_get( _adj, _adj_edges[ i ] );
				if ( !is_undefined( _adj ) ) {
					
				}
			}
		}
	}
	
}

#endregion