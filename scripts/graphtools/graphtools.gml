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
	directed = ( argument_count > 0 ) ? argument[ 0 ] : false;
	
	/// @member {StructMap} node
	/// @memberof Graph
	///
	/// @desc StructMap holding all nodes
	node = new StructMap();
	
	/// @member {StructMap} adj
	/// @memberof Graph
	///
	/// @desc StructMap holding all outgoing node-connection information
	adj = new StructMap();
	
	/// @member {StructMap} pred
	/// @memberof Graph
	///
	/// @desc StructMap holding all incoming node-connection information.
	pred = directed ? new StructMap() : adj;
	
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
	/// @arg {Array} [attr] If attr is Struct, replaces current edge data with attr.
	
	static add_edge = function( a, b ) {
		var _weight = ( argument_count > 2 ) ? argument[ 2 ] : undefined;
		var _attr = ( argument_count > 3 ) ? argument[ 3 ] : undefined;
		
		if ( is_undefined( node.get( a ) ) ) {
			add_node( a );
		}
		
		if ( is_undefined( node.get( b ) ) ) {
			add_node( b );
		}
		
		var _adj = adj.get( a );
		var _pred = pred.get( b );
		
		var _edge = edge_create( a, b, _adj.get( b ), _weight, _attr );
		
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
			if ( is_struct( _attr ) ) {
				_attr = iter( _attr ).to_array();	
			}
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
	/// @arg {Array} [attr] [key, value] pairs. If attr is Struct, replaces current node data with attr.
	///
	/// @example
	/// g.add_node( 1, { text : "hello" } );
	///g.add_node( 2, [[ "text", "world" ]] );
	
	static add_node = function( _node ) {
		var _attr = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
		
		var _old_node = node.get( _node );
		var _new_node = node_create( _node, _old_node, _attr );
		
		node.add( _node, _new_node );
				
		if ( is_undefined( _old_node ) ) {
			adj.add( _node, new StructMap() );
			
			if ( directed ) {
				pred.add( _node, new StructMap() );
			}
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
		
		if ( is_struct( _attr ) ) {
			_attr = iter( _attr ).to_array();	
		}
		
		while ( !_iter.is_done() ) {
			var _node = _iter.next();
			if ( is_array( _node ) ) {
				add_node( _node[ 0 ], _node[ 1 ] );
			} else {
				add_node( _node, _attr );
			}
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
		if ( directed ) {
			pred.clear();	
		}
	}
	
	/// @method copy
	/// @memberof Graph
	///
	/// @desc Returns copy of the graph
	///
	/// @arg {Bool} [deep=false] If false, node and edge data is referenced, not copied.
	///
	/// @return Graph
	
	static copy = function() {
		var _deep = ( argument_count > 0 ) ? argument[ 0 ] : false;
		
		return directed ? to_directed( _deep ) : to_undirected( _deep );
	}
	
	/// @method copy_methods
	/// @memberof Graph
	///
	/// @desc Copied node and edge specific methods into Graph
	///
	/// @arg {Graph} graph
	
	function copy_methods( _graph ) {
		_graph.edge_copy = edge_copy;
		_graph.edge_create = edge_create;
		_graph.edge_equal = edge_equal
		_graph.edge_weight = edge_weight;
		
		_graph.node_copy = node_copy;
		_graph.node_create = node_create;
		_graph.node_equal = node_equal;	
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
				var _iter = __iter_dict( iter( _node ), function( ) {
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
			
			return _adj.items().reduce( function( a, e ) { return a + edge_weight( e[ 1 ] ); }, 0 );
		} else {
			return number_of_nodes();	
		}
	}
	
	/// @method dijkstra
	/// @memberof Graph
	///
	/// @desc Find shortest weighted paths and lengths to a given set of destination nodes using Uses Dijkstra's algorithm.
	///
	/// @arg {Any} nodes
	/// @arg {Number} [cutoff=infinity] Depth to stop the search. Only return paths with length <= cutoff
	///
	/// @return Graph Graph node is struct \{ dist, succ, depth \}
	///dist is total distance to destination node
	///succ is next node
	///depth is number of edges to destination node
	
	static dijkstra = function ( _nodes ) {
		var _cutoff = ( argument_count > 1 ) ? argument[ 1 ] : infinity;
		
		var _result = new Graph( );
		var _heap = ds_priority_create( );
		
		_result.add_nodes_from( _imap( function( _node, _heap ) {
			ds_priority_add( _heap, _node, 0 );
			return [ _node, { depth : 0, dist: 0, succ : undefined } ];
		}, get_from( _nodes ), _repeat( _heap ) ) );
		
		var _iter = ds_priority_min_iter( _heap );
		
		while( !_iter.is_done( ) ) {
			var _node = _iter.next();
			var _depth = _result.get( _node ).depth;
			
			var _predecessors = predecessors( _node );
				
			while( !_predecessors.is_done() ) {
				var _pred = _predecessors.next();
				var _dist = get_weight( _pred, _node );
				var _dist_cum = _dist + _result.get( _node ).dist;
					
				if ( _dist_cum <= _cutoff ) {
					var _succ_node = _result.get( _pred );
					
					if ( is_undefined( _succ_node ) ) {
						_result.add_node( _pred, { depth : _depth + 1, dist : _dist_cum , succ: _node } );
						_result.add_edge( _node, _pred, _dist );
						ds_priority_add( _heap, _pred, _dist_cum );
					} else if ( ( _succ_node.dist > _dist_cum ) || ( ( _succ_node.dist > _dist_cum ) && ( _succ_node.depth > _depth + 1 ) ) ){
						if ( !is_undefined( _succ_node.succ ) ) {
							_result.add_edge( _succ_node.succ, _pred, undefined );
						}
						
						_result.add_edge( _node, _pred, _dist );
						
						_succ_node.dist = _dist_cum;
						_succ_node.succ = _node;
						_succ_node.depth = _depth + 1;
						
						if ( !is_undefined( ds_priority_find_priority( _heap, _pred ) ) ) {
							ds_priority_change_priority( _heap, _pred, _dist_cum );
						}
					}	
				}
			}
		}
		
		ds_priority_destroy( _heap );
		
		return _result;
	}
	
	/// @method dijkstra_from
	/// @memberof Graph
	///
	/// @desc Find shortest weighted paths and lengths to a given set of source nodes using Uses Dijkstra's algorithm.
	///
	/// @arg {Any} nodes
	/// @arg {Number} [cutoff=infinity] Depth to stop the search. Only return paths with length <= cutoff
	///
	/// @return Graph Graph node is struct \{ dist, pred, depth \}
	///dist is total distance to source node
	///pred is previous node
	///depth is number of edges to source node
	
	static dijkstra_from = function ( _nodes ) {
		var _cutoff = ( argument_count > 1 ) ? argument[ 1 ] : infinity;
		
		var _result = new Graph( );
		var _heap = ds_priority_create( );
		
		_result.add_nodes_from( _imap( function( _node, _heap ) {
			ds_priority_add( _heap, _node, 0 );
			return [ _node, { depth : 0, dist: 0, prev : undefined } ];
		}, get_from( _nodes ), _repeat( _heap ) ) );
		
		var _iter = ds_priority_min_iter( _heap );
		
		while( !_iter.is_done( ) ) {
			var _node = _iter.next();
			var _depth = _result.get( _node ).depth;
			
			var _successors = successors( _node );
				
			while( !_successors.is_done() ) {
				var _succ = _successors.next();
				var _dist = get_weight( _node, _succ );
				var _dist_cum = _dist + _result.get( _node ).dist;
					
				if ( _dist_cum <= _cutoff ) {
					var _pred_node = _result.get( _succ );
					
					if ( is_undefined( _pred_node ) ) {
						_result.add_node( _succ, { depth : _depth + 1, dist : _dist_cum , prev: _node } );
						_result.add_edge( _node, _succ, _dist );
						ds_priority_add( _heap, _succ, _dist_cum );
					} else if ( ( _pred_node.dist > _dist_cum ) || ( ( _pred_node.dist > _dist_cum ) && ( _pred_node.depth > _depth + 1 ) ) ){
						if ( !is_undefined( _pred_node.prev ) ) {
							_result.add_edge( _pred_node.prev, _succ, undefined );
						}
						
						_result.add_edge( _node, _succ, _dist );
						
						_pred_node.dist = _dist_cum;
						_pred_node.prev = _node;
						_pred_node.depth = _depth + 1;
						
						if ( !is_undefined( ds_priority_find_priority( _heap, _succ ) ) ) {
							ds_priority_change_priority( _heap, _succ, _dist_cum );
						}
					}	
				}
			}
		}
		
		ds_priority_destroy( _heap );
		
		return _result;
	}
	
	/// @member edge_create
	/// @memberof Graph
	///
	/// @desc Creates edge data
	///
	/// @arg {Any} a
	/// @arg {Any} b
	/// @arg {Edge} edge edge to be updated
	/// @arg {Number} weight
	/// @arg {Any} [attr]
	///
	/// @return {Edge}
	
	static edge_create = function( a, b, _edge, _weight ) {
		return is_undefined( _weight ) ? ( is_undefined( _edge ) ? 1 : _edge ) : _weight;
	}
	
	/// @member edge_equal
	/// @memberof Graph
	///
	/// @desc Checks if two edges are equal
	///
	/// @arg {Edge} a
	/// @arg {Edge} b
	///
	/// @return {Bool}
	
	static edge_equal = function( a, b ) {
		return ( edge_weight( a ) == edge_weight( b ) );
	}
	
	/// @member edge_copy
	/// @memberof Graph
	///
	/// @desc Copies edge data for deep copy
	///
	/// @arg {Edge} edge edge data to be copied
	///
	/// @return {Edge}
	
	static edge_copy = function( _edge ) {
		return is_struct( _edge ) ? iter( _edge ).to_struct() : _edge;
	}
	
	/// @member edge_weight
	/// @memberof Graph
	///
	/// @desc Returns edge weight
	///
	/// @arg {Edge} edge
	///
	/// @return {Number}
	
	static edge_weight = function( _edge ) {
		return _edge;
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
				var _iter = __iter_dict( iter( _node ), function( ) {
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
	/// @arg {Iterable} iterable If specified, return only edges from iterable
	/// @arg {Bool} data If true, include edge data Struct in the output
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
	
	/// @method get_weight
	/// @memberof Graph
	///
	/// @desc Returns weight of edge between nodes a and b.
	///
	/// @arg {Any} a
	/// @arg {Any} b
		
	static get_weight = function( a, b ) {
		return edge_weight( get_edge( a, b ) );
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
	
	/// @method has_path
	/// @memberof Graph
	///
	/// @desc Returns True if the graph has path between a and b.
	///
	/// @arg {Any} a
	/// @arg {Any} a
	///
	/// @return {Bool}
	
	static has_path = function( a, b ) {
		return dijkstra_from( a ).has_node( b );
	}
	
	/// @method in_degree
	/// @memberof Graph
	///
	/// @desc Returns node incoming degree in Graph. If node is iterable, return Iterator of pairs [ node, degree ];
	///
	/// @arg {Any} [node]
	///
	/// @return {Number}
	
	static in_degree = function( ) {
		if ( argument_count > 0 ) {
			var _node = argument[ 0 ];
			
			if ( is_iterable( _node ) ) {
				var _iter = __iter_dict( iter( _node ), function( ) {
					var _result = cache;
					cache = undefined;
					return _result;
				}, function( _key ) {
					return pred.get( _key ).size;
				}, function() {
					while ( is_undefined( cache ) && ( !data.is_done() ) ) {
						cache = data.next();
						if ( is_undefined( pred.get( cache ) ) ) {
							cache = undefined;
						}
					}
					
					return is_undefined( cache );
				} );
						
				_iter.pred = pred;
				_iter.cache = undefined;
				
				return _iter;
			}
			
			var _adj = pred.get( _node );
			
			if ( is_undefined( _adj ) ) {
				throw "The node " + string( _node ) + " is not in the graph.";
			}
			
			return _adj.items().reduce( function( a, e ) { return a + edge_weight( e[ 1 ] ); }, 0 );
		} else {
			return number_of_nodes();	
		}
	}
	
	/// @method in_edges
	/// @memberof Graph
	///
	/// @desc Returns edges 
	///
	/// @arg {Iterable} nodes return only edges to specified nodes
	/// @arg {Bool} data If true, include edge data Struct in the output
	///
	/// @return {Bool}
	
	static in_edges = function( _nodes ) {
		var _data = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		return get_edges_from( _chain_from_iterable( iter( get_from( _nodes ) ).map( function( _node ) {
			return _zip( pred.get( _node ).keys(), _repeat( _node ) );
		} ) ), _data );
	}
	
	/// @method is_subgraph
	/// @memberof Graph
	///
	/// @desc Returns true if graph is subgraph of supplied Graph
	///
	/// @arg {Graph} graph
	///
	/// @return {Bool}
	
	function is_subgraph( _graph ) {
		var _nodes = nodes( true );
		
		while( !_nodes.is_done( ) ) {
			var _node = _nodes.next();
			
			if ( is_undefined( _graph.get( _node[ 0 ] ) ) ) {
				return false;
			}
		}
		
		var _edges = edges( true );
		
		while( !_edges.is_done( ) ) {
			var _edge = _edges.next();
			
			if ( edge_weight( _edge[ 2 ] ) != _graph.get_weight( _edge[ 0 ], _edge[ 1 ] ) ) {
				return false;
			}
		}
		
		return true;
	}
	
	/// @method is_isomorphic
	/// @memberof Graph
	///
	/// @desc Returns true if graph is isomorphic to supplied Graph
	///
	/// @return {Bool}
	
	function is_isomorphic( _graph ) {
		return ( number_of_nodes == _graph.number_of_nodes ) && ( number_of_edges == _graph.number_of_edges ) && is_subgraph( _graph );
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
	
	/// @member node_create
	/// @memberof Graph
	///
	/// @desc Creates node data
	///
	/// @arg {Any} id
	/// @arg {Node} node node to be updated
	/// @arg {Any} attr
	///
	/// @return {Node}
	
	static node_create = function( _id, _node, _attr ) {
		return is_undefined( _attr ) ? ( is_undefined( _node ) ? _id : _node ) : _attr;
	}
	
	/// @member node_copy
	/// @memberof Graph
	///
	/// @desc Copies node data for deep copy
	///
	/// @arg {Node} node node data to be copied
	///
	/// @return {Node}
	
	static node_copy = edge_copy;
	
	/// @member node_equal
	/// @memberof Graph
	///
	/// @desc Checks if two nodes are equal
	///
	/// @arg {Node} a
	/// @arg {Node} b
	///
	/// @return {Bool}
	
	static node_equal = edge_equal;
	
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
	
	/// @method number_of_edges
	/// @memberof Graph
	///
	/// @desc Returns the number of edges in the graph.
	///
	/// @return {Number}
	
	static number_of_edges = function() {
		return adj.items().reduce( function( a, e ) { return a + e[ 1 ].size; }, 0 );
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
	
	/// @method order
	/// @memberof Graph
	///
	/// @desc Returns the number of nodes in the graph.
	///
	/// @return {Number}
	
	static order = number_of_nodes;
	
	/// @method out_degree
	/// @memberof Graph
	///
	/// @desc Returns node outgoing degree in Graph. If node is iterable, return Iterator of pairs [ node, degree ];
	///
	/// @arg {Any} [node]
	///
	/// @return {Number}
	
	static out_degree = degree;
	
	/// @method out_edges
	/// @memberof Graph
	///
	/// @desc Returns edges 
	///
	/// @arg {Iterable} nodes return only edges from specified nodes
	/// @arg {Bool} data If true, include edge data Struct in the output
	///
	/// @return {Bool}
	
	static out_edges = function( _nodes ) {
		var _data = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		return get_edges_from( _chain_from_iterable( iter( get_from( _nodes ) ).map( function( _node ) {
			return _zip( _repeat( _node ), adj.get( _node ).keys() );
		} ) ), _data );
	}
	
	/// @method predecessors
	/// @memberof Graph
	///
	/// @desc Returns an iterator over all predecessors of node.
	///
	/// @arg {Any} node
	/// @arg {Bool} [data=false] If false only keys would be returned.
	///
	/// @return {Iterator}
	
	static predecessors = function( _node ) {
		var _adj = pred.get( _node );
		
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
			_adj.remove( _edge[ 0 ] );
		}
			
		var _adj = pred.get( _node );
		_adj_edges = iter( _adj );
			
		while( !_adj_edges.is_done() ){
			var _edge = _adj_edges.next();
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
	
	/// @method reverse
	/// @memberof Graph
	///
	/// @desc Returns reversed copy of the graph
	///
	/// @arg {Bool} [deep=false] If false, node and edge data is referenced, not copied.
	///
	/// @return Graph
	
	static reverse = function() {
		var _deep = ( argument_count > 0 ) ? argument[ 0 ] : false;
		var _result = copy( _deep );
		
		var t =	_result.adj;
		_result.adj = _result.pred;
		_result.pred = t;
		
		return _result;
	}
	
	/// @method set_node_data
	/// @memberof Graph
	///
	/// @desc Set node data. Alias for add_node to avoid confusion.
	///
	/// @arg {Any} node
	/// @arg {Any} data
		
	static set_node_data = add_node;
	
	/// @method set_weight
	/// @memberof Graph
	///
	/// @desc Set weight of edge between nodes a and b.
	///
	/// @arg {Any} a
	/// @arg {Any} b
	/// @arg {Number} weight
	
	static set_weight = add_edge;
	
	/// @method shortest_path
	/// @memberof Graph
	///
	/// @desc Compute shortest path in Graph
	///
	/// @arg {Any} [source=undefined] If undefined, compute shortest paths for each possible starting node.
	/// @arg {Any} [dest] If not specified, compute shortest paths to all possible nodes.
	///
	/// @return {Array}
	
	static shortest_path = function() {
		var _source =  ( argument_count > 0 ) ? argument[ 0 ] : undefined;
		_source = iter( is_undefined( _source ) ? nodes() : _source ).to_array();
		var _dest = iter( ( argument_count > 1 ) ? argument[ 1 ] : nodes() ).to_array();
		
		var n = array_length( _dest );
		var _result = { };
		var _iter = iter( _source );
		
		if ( n == 1 ) {
			var _graph = dijkstra( _dest[ 0 ] );
						
			while( !_iter.is_done() ) {
				var _node = _iter.next();
				
				if ( _graph.has_node( _node ) ) {
					var _path = [ ];
					
					var _target = _node;
					var _depth = _graph.get( _node ).depth;
					
					for( var j = 0; j <= _depth; j++ ) {
						_path[ j ] = _target;
						_target = _graph.get( _target ).succ;
					}
					
					variable_struct_set( _result, _node, _path );
				} else {
					variable_struct_set( _result, _node, undefined );
				}
			}
		} else {
			while( !_iter.is_done() ) {
				var _node = _iter.next();
				
				if ( has_node( _node ) ) {
					var _graph = dijkstra_from( _node );
					var _path = { };
					
					for( var i = 0; i < n; i++ ) {
						if ( _graph.has_node( _dest[ i ] ) ) {
							var _target = _dest[ i ];
							var r = [ ];
							
							for( var j = _graph.get( _target ).depth; j >= 0; j-- ) {
								r[ j ] = _target;
								_target = _graph.get( _target ).prev;
							}
							
							variable_struct_set( _path, _dest[ i ], r );
						} else {
							variable_struct_set( _path, _dest[ i ], undefined );
						}
					}
				
					variable_struct_set( _result, _node, _path );
				} else {
					variable_struct_set( _result, _node, undefined );
				}
			}
		}
		
		if ( array_length( _source ) == 1 ) {
			_result = variable_struct_get( _result, _source[ 0 ] );
		}
		
		return _result;
	}
	
	/// @method shortest_path_length
	/// @memberof Graph
	///
	/// @desc Compute length of shortest path in Graph
	///
	/// @arg {Any} [source=undefined] If undefined, compute shortest paths length for each possible starting node.
	/// @arg {Any} [dest] If not specified, compute shortest paths length to all possible nodes.
	///
	/// @return {Array}
	
	static shortest_path_length = function() {
		var _source =  ( argument_count > 0 ) ? argument[ 0 ] : undefined;
		_source = iter( is_undefined( _source ) ? nodes() : _source ).to_array();
		var _dest = iter( ( argument_count > 1 ) ? argument[ 1 ] : nodes() ).to_array();
		
		var n = array_length( _dest );
		var _result = { };
		var _iter = iter( _source );
		
		if ( n == 1 ) {
			var _graph = dijkstra( _dest[ 0 ] );
						
			while( !_iter.is_done() ) {
				var _node = _iter.next();
				
				if ( _graph.has_node( _node ) ) {
					variable_struct_set( _result, _node, _graph.get( _node ).depth );
				} else {
					variable_struct_set( _result, _node, undefined );
				}
			}
		} else {
			while( !_iter.is_done() ) {
				var _node = _iter.next();
				
				if ( has_node( _node ) ) {
					var _graph = dijkstra_from( _node );
					var _path = { };
					
					for( var i = 0; i < n; i++ ) {
						if ( _graph.has_node( _dest[ i ] ) ) {
							variable_struct_set( _path, _dest[ i ], _graph.get( _dest[ i ] ).depth );
						} else {
							variable_struct_set( _path, _dest[ i ], undefined );
						}
					}
				
					variable_struct_set( _result, _node, _path );
				} else {
					variable_struct_set( _result, _node, undefined );
				}
			}
		}
		
		if ( array_length( _source ) == 1 ) {
			_result = variable_struct_get( _result, _source[ 0 ] );
		}
		
		return _result;
	}
	
	/// @method size
	/// @memberof Graph
	///
	/// @desc Returns total of all edge weight.
	///
	/// @return {Number}
	
	static size = function() {
		var _result =  edges( true ).reduce( function( a, e ) { return a + edge_weight( e[ 2 ] ); }, 0 );
		return directed ? _result : _result / 2;
	}
	
	/// @method subgraph
	/// @memberof Graph
	///
	/// @desc Returns subgraph induced on nodes. The induced subgraph of the graph contains the nodes in interable and the edges between those nodes.
	///
	/// @arg {Iterable} nodes
	/// @arg {Bool} [copy=false]
	///
	/// @return Graph
	
	static subgraph = function( _nodes ) {
		var _result = new Graph( directed );
		var _deep = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		copy_methods( _result );
		
		_result.update_nodes( get_from( _nodes, true ), _deep );
		_result.update_edges( get_edges_from( directed ? _result.nodes().permutations( 2 ) : _result.nodes().combinations( 2 ), true ), _deep );
		
		return _result;
	}
	
	/// @method subgraph_edges
	/// @memberof Graph
	///
	/// @desc Returns subgraph induced on edges. The induced subgraph of the graph contains the edges in interable and the edges between those nodes.
	///
	/// @arg {Iterable} edges
	/// @arg {Bool} [copy=false]
	///
	/// @return Graph
	
	static subgraph_edges = function( _edges ) {
		var _result = new Graph( directed );
		var _deep = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		copy_methods( _result );
		
		_result.update_edges( get_edges_from( _edges, true ), _deep );
		_result.update_nodes( get_from( _result.nodes(), true ), _deep );
		
		return _result;
	}
	
	/// @method successors
	/// @memberof Graph
	///
	/// @desc Returns an iterator over all successors of node.
	///
	/// @arg {Any} node
	/// @arg {Bool} [data=false] If false only keys would be returned.
	///
	/// @return {Iterator}
	
	static successors = neighbors;
	
	/// @method to_directed
	/// @memberof Graph
	///
	/// @desc Returns directed copy of the graph
	///
	/// @arg {Bool} [deep=false] If false, node and edge data is referenced, not copied.
	///
	/// @return Graph
	
	static to_directed = function() {
		var _result = new Graph( true );
		var _deep = ( argument_count > 0 ) ? argument[ 0 ] : false;
		
		copy_methods( _result );
		
		_result.update_nodes( nodes( true ), _deep );
		_result.update_edges( edges( true ), _deep );
		
		return _result;
	}
	
	/// @method to_undirected
	/// @memberof Graph
	///
	/// @desc Returns undirected copy of the graph
	///
	/// @arg {Bool} [deep=false] If false, node and edge data is referenced, not copied.
	///
	/// @return Graph
	
	static to_undirected = function() {
		var _result = new Graph();
		
		copy_methods( _result );
		
		var _deep = ( argument_count > 0 ) ? argument[ 0 ] : false;
		
		_result.update_nodes( nodes( true ), _deep );
		_result.update_edges( edges( true ), _deep );
		
		return _result;
	}
	
	/// @method update
	/// @memberof Graph
	///
	/// @desc Update graph nodes and edges from another graph
	///
	/// @arg {Graph} nodes
	/// @arg {Bool} [copy=false]
	
	static update = function( _graph ) {
		var _deep = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		update_nodes( _graph.nodes( true ), _deep );		
		update_edges( _graph.edges( true ), _deep );
	}
	
	/// @method update_edges
	/// @memberof Graph
	///
	/// @desc Update the graph edges from iterable.
	///
	/// @arg {Iterable} iterable
	/// @arg {Bool} copy=false
	
	static update_edges = function( _iterable ) {
		var _edges = iter( _iterable );
		var _deep = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		if ( _deep ) {
			add_edges_from( _edges.map( function( _edge ) {
				return [ _edge[ 0 ], _edge[ 1 ], edge_copy( _edge[ 2 ] ) ];
			} ) );
		} else {
			add_edges_from( _edges );
		}
	}
	
	/// @method update_nodes
	/// @memberof Graph
	///
	/// @desc Update the graph nodes from iterable.
	///
	/// @arg {Iterable} iterable
	/// @arg {Bool} copy=false
	
	static update_nodes = function( _iterable ) {
		var _nodes = iter( _iterable );
		var _deep = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		if ( _deep ) {
			add_nodes_from( _nodes.map( function( _node ) {
				return [ _node[ 0 ], node_copy( _node[ 1 ] ) ];
			} ) );
		} else {
			add_nodes_from( _nodes );
		}
	}
}

/// @func GraphStructs( )
/// @name GraphStructs
/// @class
///
/// @classdesc Graph with structs for nodes and edges.
///
/// @arg {Bool} [directed=false]
///
/// @return {GraphStructs} - GraphStructs struct

function GraphStructs( ) : Graph( ) constructor {
	static edge_create = function( a, b, _edge, _weight ) {
		var _attr;
		
		if ( is_array( _weight ) || is_struct( _weight ) ) {
			_attr = _weight;
			_weight = undefined;
		} else if ( argument_count > 4 ) {
			_attr = argument[ 4 ];
		}
		
		var _result = is_struct( _attr ) ? _attr : ( is_undefined( _edge ) ? { } : _edge);
		
		if ( !variable_struct_exists( _result, "weight" ) ) {
			_result.weight = is_undefined( _weight ) ? 1 : _weight;
		}
		
		var n = is_array( _attr ) ? array_length( _attr ) : 0;
		for( var i = 0; i < n; i++ ) {
			variable_struct_set( _result, _attr[ i ][ 0 ], _attr[ i ][ 1 ] );
		}
		
		return _result;
	}
	
	static edge_weight = function( _edge ) {
		return _edge.weight;
	}
	
	static node_create = function( _id, _node, _attr ) {
		var _result = is_struct( _attr ) ? _attr : undefined;
		
		if ( is_undefined( _result ) ) {
			_result = is_undefined( _node ) ? { } : _node;
		}
		
		var n = is_array( _attr ) ? array_length( _attr ) : 0;
		for( var i = 0; i < n; i++ ) {
			variable_struct_set( _result, _attr[ i ][ 0 ], _attr[ i ][ 1 ] );
		}
		
		return _result;
	}
}

#endregion

#region constructors

/// @func graph_complete
///
/// @desc returns graph complete graph
///
/// @arg {Iterable} [nodes=0] If integer supplied, nodes are taken from Range( n )
/// @arg {Bool} [directed=false]
///
/// @return {Graph}
///
/// @example
/// g = graph_complete( 9 );
///g.number_of_nodes() --> 9
///g.size() --> 36
/// @example
/// g = graph_complete( _irange( 11, 14 ) );
///g.number_of_nodes() --> 3
///g.nodes().sorted() --> 11, 12, 13

function graph_complete( ) {
	var _nodes = ( argument_count > 0 ) ? argument[ 0 ] : 0;
	_nodes = is_numeric( _nodes ) ? _irange( _nodes ) : iter( _nodes );
	var _directed = ( argument_count > 1 ) ? argument[ 1 ] : false;
	
	var _result = is_struct( _directed ) ? _directed : new Graph( _directed );
	_result.add_edges_from( _directed ? _nodes.permutations( 2 ) : _nodes.combinations( 2 ) );
	
	return _result;
}

/// @func graph_cycle
///
/// @desc returns cyclically connected graph
///
/// @arg {Iterable} [nodes=0] If integer supplied, nodes are taken from Range( n )
/// @arg {Bool} [directed=false]
///
/// @return {Graph}

function graph_cycle( ) {
	var _nodes = ( argument_count > 0 ) ? argument[ 0 ] : 0;
	_nodes = is_numeric( _nodes ) ? _irange( _nodes ) : iter( _nodes );
	var _directed = ( argument_count > 1 ) ? argument[ 1 ] : false;
	
	var _head = _take( 2, _nodes ).to_array();
	var _tail = _head;
	
	var _iter = _accumulate( _nodes, function( a, e ) { return [ a[ 1 ], e ]; }, _tail );
	var _result = is_struct( _directed ) ? _directed : new Graph( _directed );
	
	while( !_iter.is_done() ) {
		_tail = _iter.next();
		_result.add_edge( _tail[ 0 ], _tail[ 1 ] );
	}
	
	if ( _head != _tail ) {
		_result.add_edge( _tail[ 1 ], _head[ 0 ] );
	}
	
	return _result;
}

/// @func graph_empty
///
/// @desc returns graph with no edges
///
/// @arg {Iterable} [nodes=0] If integer supplied, nodes are taken from Range( n )
/// @arg {Bool} [directed=false]
///
/// @return {Graph}
///
/// @example
/// g = graph_empty( 10 );
///g.number_of_nodes() --> 10
///g.number_of_edges() --> 0
/// @example
/// g = graph_empty( "abc" );
///g.number_of_nodes() --> 3
///g.nodes().sorted() --> "a", "b", "c"

function graph_empty( ) {
	var _nodes = ( argument_count > 0 ) ? argument[ 0 ] : 0;
	_nodes = is_numeric( _nodes ) ? _irange( _nodes ) : iter( _nodes );
	var _directed = ( argument_count > 1 ) ? argument[ 1 ] : false;
	
	var _result = is_struct( _directed ) ? _directed : new Graph( _directed );
	_result.add_nodes_from( _nodes );
	
	return _result;
}

/// @func graph_path
///
/// @desc returns linearly connected graph
///
/// @arg {Iterable} [nodes=0] If integer supplied, nodes are taken from Range( n )
/// @arg {Bool} [directed=false]
///
/// @return {Graph}

function graph_path( ) {
	var _nodes = ( argument_count > 0 ) ? argument[ 0 ] : 0;
	_nodes = is_numeric( _nodes ) ? _irange( _nodes ) : iter( _nodes );
	var _directed = ( argument_count > 1 ) ? argument[ 1 ] : false;
	
	var _result = is_struct( _directed ) ? _directed : new Graph( _directed );
	
	_result.add_edges_from( _accumulate( _nodes, function( a, e ) { return [ a[ 1 ], e ]; }, _take( 2, _nodes ).to_array() ) );
	
	return _result;
}

/// @func graph_star
///
/// @desc returns graph where all nodes are connected to the center node
///
/// @arg {Iterable} [nodes=0] If integer supplied, nodes are taken from Range( nodes + 1 )
/// @arg {Bool} [directed=false]
///
/// @return {Graph}

function graph_star( ) {
	var _nodes = ( argument_count > 0 ) ? argument[ 0 ] : -1;
	_nodes = is_numeric( _nodes ) ? _irange( _nodes + 1 ) : iter( _nodes );
	var _directed = ( argument_count > 1 ) ? argument[ 1 ] : false;
	
	var _result = is_struct( _directed ) ? _directed : new Graph( _directed );
	
	if ( !_nodes.is_done() ) {
		var _head = _nodes.next();
		_result.add_nodes_from( _head );
		_result.add_edges_from( _zip( _repeat( _head ), _nodes ) );
	}
	
	return _result;
}

#endregion