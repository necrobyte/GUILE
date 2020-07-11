#region Graph

/// @func Graph( )
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
	directed =  false;
	
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
	/// @desc Map holding all incoming node-connection information.
	pred = adj;
	
	/*
		methods
	*/
	
	static __iter = function() {
		return node.items();
	}
	
	static to_string = function() {
		return "{ " + node.keys().to_string( ", " ) + " }";
	}
	
	/// @method add_edge
	/// @memberof Graph
	///
	/// @desc Add an edge between nodes a and b. If nodes are not in graph, nodes are added.
	///
	/// @arg {Any} a
	/// @arg {Any} b
	/// @arg {Number} [weight=1]
	/// @arg {Array} [attr]
	
	static add_edge = function( a, b ) {
		var _weight = ( argument_count > 2 ) ? argument[ 2 ] : undefined;
		var _attr = undefined;
		
		if ( is_array( _weight ) || is_struct( _weight ) ) {
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
			_edge = is_struct( _attr ) ? _attr : { };
			_edge.weight = is_undefined( _weight ) ? 1 : _weight;
		} else if ( !is_undefined( _weight ) ) {
			_edge.weight = _weight;
		}
		
		var n = is_array( _attr ) ? array_length( _attr ) : 0;
		for( var i = 0; i < n; i++ ) {
			variable_struct_set( _edge, _attr[ i ][ 0 ], _attr[ i ][ 1 ] );
		}
		
		_adj.set( b, _edge );
		_pred.set( a, _edge );
	}
	
	/// @method add_edges_from
	/// @memberof Graph
	///
	/// @desc Add an edges from iterable. If nodes are not in graph, nodes are added.
	///
	/// @arg {Any} a
	/// @arg {Any} b
	/// @arg {Number} [weight=1]
	/// @arg {Array} [attr]
	
	static add_edges_from = function( _iterable ) {
		var _weight = ( argument_count > 2 ) ? argument[ 2 ] : undefined;
		var _attr = undefined;
		
		if ( is_array( _weight ) || is_struct( _weight ) ) {
			_attr = _weight;
			_weight = undefined;
		} else if ( argument_count > 3 ){
			_attr = argument[ 3 ];
		}
		
		var _iter = iter( _iterable );
				
		while ( !_iter.is_done() ) {
			var _edge = _iter.next();
			var n = array_length( _edge );
			add_edge( _edge[ 0 ], _edge[ 1 ], ( n > 2 ) ? _edge[ 2 ] : _weight, ( n > 3 ) ? _edge[ 3 ] : _attr );
		}
	}
	
	/// @method add_node
	/// @memberof Graph
	///
	/// @desc add node. If node exists, update attributes.
	///
	/// @arg {Any} node
	/// @arg {Array} [attr] [key, value] pairs
	///
	/// @example
	/// g.add_node( 1, { text : "hello" } );
	///g.add_node( 2, [[ "text", "world" ]] );
	
	static add_node = function( _node ) {
		var _attr = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
		
		var _new_node = node.get( _node );
		
		if ( is_undefined( _new_node ) ) {
			_new_node = is_struct( _attr ) ? _attr : { };
			
			node.add( _node, _new_node );
			adj.add( _node, new Map() );
			
			if ( directed ) {
				pred.add( _node, new Map() );
			}
		}
		
		var n = is_array( _attr ) ? array_length( _attr ) : 0;
		for( var i = 0; i < n; i++ ) {
			variable_struct_set( _new_node, _attr[ i ][ 0 ], _attr[ i ][ 1 ] );
		}
	}
	
	/// @method add_nodes_from
	/// @memberof Graph
	///
	/// @desc Add nodes. If node exists, update attributes.
	///
	/// @arg {Iterable} iterable
	/// @arg {Array} [attr] [key, value] pairs
		
	static add_nodes_from = function ( _iterable ) {
		var _iter = iter( _iterable );
		var _attr = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
		
		while ( !_iter.is_done() ) {
			add_node( _iter.next(), _attr );	
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
		clear_edges();
	}
	
	/// @method clear_edges
	/// @memberof Graph
	///
	/// @desc Remove all edges leaving nodes untouched
	
	static clear_edges = function() {
		adj.clear();
	}
	
	/// @method degree
	/// @memberof Graph
	///
	/// @desc Returns node degree in Graph. If node is iterable, return Iterator of pairs [ node, degree ];
	///
	/// @arg {Any} [node]
	///
	/// @return {Number}
	
	static degree = function( ) {
		if ( argument_count > 0 ) {
			var _node = argument[ 0 ];
			
			if ( is_iterable( _node ) ) {
				var _iter = __iter_dict( _node, function( ) {
					var _result = cache;
					cache = undefined;
					return _result;
				}, function( _key ) {
					return adj.get( _key ).size;
				}, function() {
					while ( is_undefined( cache ) && ( !data.is_done() ) ) {
						cache = data.next();
						if ( is_undefined( adj.get( cache ) ) ) {
							cache = undefined;
						}
					}
					
					return is_undefined( cache );
				} );
						
				_iter.adj = adj;
				_iter.cache = undefined;
				
				return _iter;
			}
			
			var _adj = adj.get( _node );
			
			if ( is_undefined( _adj ) ) {
				throw "The node " + string( _node ) + " is not in the graph.";
			}
			
			return _adj.items().reduce( function( a, e ) { return a + ( e[ 1 ] ).weight; }, 0 );
		} else {
			return number_of_nodes();	
		}
	}
	
	/// @method edges
	/// @memberof Graph
	///
	/// @desc Returns iterator for all edges in graph
	///
	/// @arg {Bool} data If true, adds edge attribute struct to yield.
	///
	/// @return {Iterator} Yields array [ a, b, [edge] ]
	
	static edges = function( ) {
		var _data = ( argument_count > 0 ) ? argument[ 0 ] : false;
		var _iter = _imap( function( _adj, _data ) {
			if ( _data ) {
				return _imap( function( _node, _edge ) {
					return [ _node, _edge[ 0 ], _edge[ 1 ] ];
				}, _repeat( _adj[ 0 ] ), _adj[ 1 ].items() );
			}
			
			return _zip( _repeat( _adj[ 0 ] ), _adj[ 1 ].keys() );
		}, adj.items(), _repeat( _data ) );
		
		return _chain_from_iterable( _iter );
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
	
	/// @method get_from
	/// @memberof Graph
	///
	/// @desc Returns nodes in Graph. If node is iterable, return Iterator of nodes;
	///
	/// @arg {Any} [node]
	/// @arg {bool} [data=false] If true, adds node attribute struct .
	///
	/// @return {Number}
	
	static get_from = function( ) {
		if ( argument_count > 0 ) {
			var _node = argument[ 0 ];
			var _data = ( argument_count > 1 ) ? argument[ 1 ] : false;
			
			if ( is_iterable( _node ) ) {
				var _iter = __iter_dict( _node, function( ) {
					var _result = cache;
					cache = undefined;
					return _result;
				}, function( _key ) {
					return  node.get( _key );
				}, function() {
					while ( is_undefined( cache ) && ( !data.is_done() ) ) {
						cache = data.next();
						if ( is_undefined( node.get( cache ) ) ) {
							cache = undefined;
						}
					}
					
					return is_undefined( cache );
				} );
						
				_iter.node = node;
				_iter.cache = undefined;
				
				return _data ? _iter : _iter.names();
			}
			
			var _result = node.get( _node )
			return _data ? _result : ( is_undefined( _result ) ? undefined : _node );
		} else {
			return node.keys();
		}
	}
	
	/// @method get_edge
	/// @memberof Graph
	///
	/// @desc Returns edge atribute Struct associated with edge between a and b. If edge does not exist, return undefined.
	///
	/// @arg {Any} a
	/// @arg {Any} b
	///
	/// @return {Bool}
	
	static get_edge = function( a, b ) {
		return adj.get( a, b );
	}
	
	/// @method get_edges_from
	/// @memberof Graph
	///
	/// @desc Returns edges 
	///
	/// @arg {Iterable} iterable
	/// @arg {Bool} data
	///
	/// @return {Bool}
	
	static get_edges_from = function( ) {
		if ( argument_count > 0 ) {
			var _edge = argument[ 0 ];
			var _data = ( argument_count > 1 ) ? argument[ 1 ] : false;
			
			if ( is_iterable( _edge ) ) {
				var _iter = new Iterator( iter( _edge ), function( ) {
					var _result = [ cache, cacheb ];
					if ( edge ) {
						_result[ 2 ] = adj.get( cache, cacheb );	
					}
					cache = undefined;
					return _result;
				}, function() {
					while ( is_undefined( cache ) && ( !data.is_done() ) ) {
						cache = data.next();
						
						if ( is_array( cache ) ) {
							cacheb = cache[ 1 ];
							cache = cache[ 0 ];
						} else {
							cacheb = data.is_done() ? undefined : data.next();
						}
						
						if ( is_undefined( adj.get( cache, cacheb ) ) ) {
							cache = undefined;
						}
					}
					
					return is_undefined( cache );
				} );
				
				_iter.adj = adj;
				_iter.cache = undefined;
				_iter.cacheb = undefined;
				_iter.edge = _data;
				
				return _iter;
			}
			
			var _result = adj.get( _edge, _data );
			return ( ( argument_count > 2 ) ? argument[ 2 ] : false ) ? [ _edge, _data, _result ] : ( is_undefined( _result ) ? undefined : [ _edge, _data ] );
		} else {
			return edges();
		}
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
	
	static remove_edge = function( a ) {
		var b = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
		
		if ( is_array( a ) ) {
			b = a[ 1 ];
			a = a[ 0 ];
		}
		
		if ( is_undefined( adj.get( a, b ) ) ) {
			exit;
		}
		
		var _adj = adj.get( a );
		var _pred = pred.get( b );
			
		var _edge = _adj.get( b );
		
		if ( is_undefined( _edge ) ) {
			exit;	
		}
		
		_adj.remove( b );
		_pred.remove( a );
		
		delete _edge;
	}
	
	/// @method remove_edges_from
	/// @memberof Graph
	///
	/// @desc Remove nodes a from graph.
	///
	/// @arg {Iterable} edges
	
	static remove_edges_from = function( ) {
		if ( argument_count > 0 ) {
			var _edges = iter( argument[ 0 ] );
			while( !_edges.is_done() ) {
				var _edge = _edges.next();
				if is_array( _edge ) {
					remove_edge( _edge );	
				} else {
					if ( !_edges.is_done() ) {
						remove_edge( _edge, _edges.next() );	
					}
				}
			}
		} else {
			clear_edges();
		}
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
				
		while( !_adj_edges.is_done() ){
			var _edge = _adj_edges.next();
			delete _edge[ 1 ];
			_adj.remove( _edge[ 0 ] );
		}
			
		var _adj = pred.get( _node );
		_adj_edges = iter( _adj );
			
		while( !_adj_edges.is_done() ){
			var _edge = _adj_edges.next();
			delete _edge[ 1 ];
			_adj.remove( _edge[ 0 ] );
		}
				
		node.remove( _node );
	}
	
	/// @method remove_nodes_from
	/// @memberof Graph
	///
	/// @desc Remove nodes a from graph.
	///
	/// @arg {Iterable} nodes
	
	static remove_nodes_from = function( ) {
		if ( argument_count > 0 ) {
			var _nodes = iter( argument[ 0 ] );
			while( !_nodes.is_done() ) {
				remove_node( _nodes.next() );
			}
		} else {
			clear();
		}
	}
	
	/// @method size
	/// @memberof Graph
	///
	/// @desc Returns the number of nodes in the graph.
	///
	/// @return {Number}
	
	static size = number_of_nodes
}

/// @func GraphDirected( )
/// @name GraphDirected
/// @class
/// @extends Graph
///
/// @classdesc Directed graph
///
/// @return {GraphDirected} - Graph struct

function GraphDirected( ) constructor {
	directed =  true;
	pred = new Map( );
	
	static clear_edges = function() {
		adj.clear();
		pred.clear();
	}
}

#endregion