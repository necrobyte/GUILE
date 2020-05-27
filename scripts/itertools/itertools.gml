#region Iterator

/// @constructor
/// @func Iterator
///
/// @desc returns Iterator struct
///
/// @arg {Method()} next
/// @arg {Method()} [is_done]
///
/// @return {Iterator}

// TODO: convert to method
function Iterator( _data, _next ) constructor {
	is_done = ( argument_count < 3 ) ? function() { return false } : method( self, argument[ 2 ] );
	__next = method( self, _next );
	data = _data;
	
	__iter = function() {
		return method_get_self( __next ); // hack to return self
	}
	
	static next = function() {
		return is_done() ? undefined : __next();
	}
	
	static to_array = function() {
		var _a = [];
		var _n = 0;
		
		while( !is_done() ) {
			_a[ _n++ ] = next();
		}
		return _a;
	}
	
	static to_string = function( _separator ) {
		_separator = is_undefined( _separator ) ? "" : _separator;
		var _str = "";
		var _b = !is_done(); 
		
		while( _b ) {
			_str += string( next() );
			_b = !is_done();
			if ( _b ) {
				_str += _separator;
			}
		}

		return _str;
	}
	
}

#endregion

#region iter

/// @func IteratorDict
///
/// @desc Iterator for name-value keyed data structures
///
/// @arg {Any} data
/// @arg {Method()} next
/// @arg {Method()} is_done
///
/// @return {Iterator} - iterator struct

 IteratorDict = function ( _data, _next, _is_done ) : Iterator( _data, _next, _is_done ) constructor {
	static names = function() {
		var _iter = new Iterator( data, function() {
			++index;
			return next_key();
		}, function() {
			return index >= size;
		} );
	
		_iter.next_key = next_key;
		_iter.get = get;
		_iter.index = 0;
		_iter.size = size;

		return _iter;
	}
	
	static values = function() {
		var _iter = new Iterator( data, function() {
			++index;
			return get( next_key() );
		}, function() {
			return index >= size;
		} );
	
		_iter.next_key = next_key;
		_iter.get = get;
		_iter.index = 0;
		_iter.size = size;

		return _iter;
	}
	
	static to_map = function( _id ) {
		var _ds = is_undefined( _id ) ? ds_map_create() : _id;

		while( !is_done() ) {
			var _key = next_key();
			ds_map_add( _ds, _key, get( _key ) );
		}

		return _ds;
	}
	
	static to_struct = function( _id ) {
		var _ds = is_undefined( _id ) ? {} : _id;

		while( !is_done() ) {
			var _key = next_key();
			variable_struct_set( _ds, _key, get( _key ) );
		}

		return _ds;
	}
}

/// @func __iter_dict( object, next_key, get, is_done )
/// @desc helper function for creating IteratorDict
/// @arg {Any} object
/// @arg {Method} next_key
/// @arg {Method} get
/// @arg {Method} is_done

function __iter_dict( _object, _next_key, _get, _is_done ) {
	var _iter = new IteratorDict( _object, function() {
		var _key = next_key();
		return [ _key, get( _key ) ];
	}, _is_done );
	
	_iter.next_key = method( _iter, _next_key );
	_iter.get =	method( _iter, _get );
	
	return _iter;
}

/// @func IteratorCollection( )
/// @desc Returns reversible iterator

// TODO: Convert to method
function IteratorCollection( _data, _next, _is_done ) : Iterator( _data, _next, _is_done ) constructor {
	static reverse = function() {
		dir = -dir;
		index = size - index - 1;
		return method_get_self( __next );
	}
}

/// @func __iter_collection( _object, _get, _len )
/// @desc Helper function for building IteratorCollection
function __iter_collection( _object, _get, _len ) {
	var _iter = new IteratorCollection( _object, function() {
		var _result = get( index );
		index += dir;
		return _result;
	}, function() {
		return ( ( index >= size ) || ( index < 0 ) );
	} );
	
	_iter.index = 0;
	_iter.get = method( _iter, _get );
	_iter.len = method( _iter, _len );
	_iter.size = _iter.len();
	_iter.dir = 1;
	
	return _iter;
}

/// @func ds_list_iter
/// 
/// @desc Returns iterator object for ds_list data structure.
///
/// @arg {ds_list} list
///
/// @return {Iterator}

ds_list_iter = function( _list ) {
	return __iter_collection( _list, function( _n ) {
		return data[| _n];
	}, function() {
		return ds_list_size( data );	
	});
}

/// @func ds_stack_iter
/// 
/// @desc Returns iterator object for ds_list data structure.
///
/// @arg {ds_stack} stack
///
/// @return {Iterator}

ds_stack_iter = function( _stack ) {
	var _iter = new Iterator( _stack, function() {
		return ds_stack_pop( data );
	}, function() {
		return ds_stack_empty( data );
	} );
	
	return _iter;
}

/// @func ds_queue_iter( stack )
/// @arg queue

ds_queue_iter = function( _queue ) {
	var _iter = new Iterator( _queue, function() {
		return ds_queue_dequeue( data );
	}, function() {
		return ds_queue_empty( data );	
	} );
	
	return _iter;
}

/// @func ds_map_iter( map )
/// @arg map

ds_map_iter = function( _map ) {
	var _iter = __iter_dict( _map, function(){
			item = ( index++ > 0 ) ? ds_map_find_next( data, item ) : ds_map_find_first( data );
			return item;
		}, function( _key ) {
			return data[? _key ];
		}, function() { 
			return ( index >= size );
		} );
	
	_iter.index = 0;
	_iter.size = ds_map_size( _map );
	_iter.item = undefined;
	
	return _iter;
}

/// @func ds_priority_max_iter( stack )
/// @arg priority

ds_priority_max_iter = function( _priority ) {
	var _iter = new Iterator( _priority, function() {
		return ds_priority_delete_max( data );
	}, function() {
		return ds_priority_empty( data );
	} );
	
	return _iter;
}

/// @func ds_priority_min_iter( stack )
/// @arg priority

ds_priority_min_iter = function( _priority ) {
	var _iter = new Iterator( _priority, function() {
		return ds_priority_delete_min( data );
	}, function() {
		return ds_priority_empty( data );
	} );
	
	return _iter;
}

/// @func iter( object, [sentinel] )
/// @arg object
/// @arg [sentinel] used if object is method

// TODO: convert to method
function iter( _object ) {
	
	switch ( typeof( _object ) ) {
		case "string":
			return __iter_collection( _object, function( _n ) { 
					return string_char_at( data, _n + 1 );
				}, function() { 
					return string_length( data );
				} );
		
		case "array":
			return __iter_collection( _object, function( _n ) { 
					return data[ _n ];
				}, function() { 
					return array_length( data );
				} );
			
		case "struct":
			if ( variable_struct_exists( _object, "__iter" ) ) {
				return _object.__iter();
			}
			
			if ( variable_struct_exists( _object, "get" ) && ( variable_struct_exists( _object, "len" ) ) ) {
				return __iter_collection( _object, function( _n ) { 
					return data.get( n );
				}, function() { 
					return data.len();
				} );
			}
			
			var _iter = __iter_dict( _object, function() {
				return keys[ index++ ];
			}, function( _key ) {
				return variable_struct_get( data, _key );
			}, function() {
				return index >= size;
			} );
	
			_iter.keys = variable_struct_get_names( _object );
			_iter.index = 0;
			_iter.size = array_length( _iter.keys );

			return _iter;
			
		case "method":
			var _sentinel = ( argument_count > 1 ) ? argument[ 1 ] : "";
			
			var _iter = new Iterator( function() {
				check = true;
				return cache;
			}, function() {
				if ( check ) {
					cache = get();
					check = ( cache == data );
				}
				return check;
			} );
			
			_iter.get = _object;
			_iter.data = _sentinel;
			_iter.cache = undefined;
			_iter.check = true;
		
			
		default:
			return undefined;
	end;
}

#endregion

#region range

/// @constructor
/// @func Range
///
/// @desc range struct constructor
///
/// @arg {Number} [start=0]
/// @arg {Number} stop
/// @arg {Number} [step=1]
///
/// @return {Struct}

Range = function( _start, _stop, _step ) constructor {
	
	start = _start;
	stop = _stop;
	step = _step;
	
	static __iter = function() {
		return _irange( start, stop, step );
	}
	
	static reversed = function() {
		stop += ( ( start - stop ) % step + step ) % step;
		return new Range( stop - step, start - step, -step );	
	}
}

/// @func _range
///
/// @desc helper function for calling Range constructor
///
/// @arg {Number} [start=0]
/// @arg {Number} stop
/// @arg {Number} [step=1]
///
/// @return {Range} iterable Range struct

_range = function( _stop ) {
	var _start = argument_count > 1 ? _stop : 0;
	var _step = argument_count > 2 ? argument[ 2 ] : 1;
	_stop = ( argument_count > 1 ? argument[ 1 ] : _stop );
	
	var _result = new Range( _start, _stop, _step )
	
	return _result;
}

/// @func _irange
///
/// @desc returns range iterator
///
/// @arg {Number} [start=0]
/// @arg {Number} stop
/// @arg {Number} [step=1]
///
/// @return {Iterator}

/// TODO: convert to method
function _irange ( _stop ) {
	var _iter = new Iterator( undefined, function() {
			var _result = start;
			start += step;
			return _result;
	}, function() {
		return floor( ( start - stop ) / step ) >= 0;
	} );
	
	_iter.start = argument_count > 1 ? _stop : 0;
	_iter.step = argument_count > 2 ? argument[ 2 ] : 1;
	_iter.stop = ( argument_count > 1 ? argument[ 1 ] : _stop );
	
	_iter.reversed = method( _iter, function() {
		stop += ( ( start - stop ) % step + step ) % step;
		return _irange( stop - step, start - step, -step );
	} );
	
	return _iter;
}

#endregion

#region iterators

/// @func _accumulate
///
/// @desc Make an iterator that returns accumulated sums.
///
/// @arg {Iterable} iterable
/// @arg {Method} [func]
/// @arg {Any} [initial]
///
/// @yield {Any} accumulated sums

_accumulate = function ( _iterable ) {
	var _iter = new Iterator( iter( argument[ 0 ] ), function() {
		if ( data.is_done() ) {
			check = false;
			return sum;
		}
		
		var _result = data.next();
		if ( check ) {
			sum = _result;
			check = false;
		}  else {
			sum = func( sum, _result );
		}
		
		return sum;
	}, function() {
		return ( (!check) && data.is_done() );
	});
		
	if ( argument_count > 1 ) {
		if ( is_method( argument[ 1 ] ) ){
			_iter.func = argument[ 1 ];
			_iter.sum = ( argument_count > 2 ) ? argument[ 2 ] : undefined;
			_iter.check = ( argument_count <= 2 ) ^^ ( _iter.data.is_done() );
			
			return _iter;
		} else {
			_iter.sum = argument[ 1 ];
			_iter.check = _iter.data.is_done();
		}
	} else {
		_iter.sum = undefined;
		_iter.check = !_iter.data.is_done();
	}
	
	_iter.func = function( _a, _b ) { return _a + _b };
	
	return _iter;
}


/// @func _chain( [iter1], [iter2], ... )
/// @desc Make an iterator that returns elements from the first iterator until it is exhausted, then proceeds to the next iterator, until all of the iterators are exhausted.
/// @arg [iter1]

_chain = function() {
	var _iter = new Iterator( [ ], function() {
		return data[ index ].next();
	}, function() {
		while ( ( index < size ) && ( data[ index ].is_done() ) ) {
			index++;
		}
		return ( index == size );
	});
	
	_iter.size = argument_count;
	_iter.index = 0;
	
	for( var i = 0; i < _iter.size; i++ ) {
		_iter.data[ i ] = iter( argument[ i ] );
	}
	
	return _iter;
}

/// @func _chain_from_iterable( iterable )
/// @desc Make an iterator that returns chained elements from iterables returned by argument
/// @arg {Iterable} iterable

_chain_from_iterable = function( _iterable ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		return item.next();
	}, function() {
		while ( ( is_undefined( item ) || item.is_done() ) && ( !data.is_done() ) ) {
			item = iter( data.next() );	
		}
		return ( is_undefined( item ) || item.is_done() );
	});
	
	_iter.item = undefined;
	
	return _iter;
}

/// @func _compress( data, selectors )
/// @desc Make an iterator that filters elements from data returning only those that have a corresponding element in selectors that evaluates to True.
/// @arg {Iterable} data
/// @arg {Iterable} selectors

_compress = function( _data, _selectors ) {
	var _iter = new Iterator( iter( _data ), function() {
		ready = false;
		return data.next();
	}, function() {
		if ( !ready ) {
			while( !( selectors.is_done() || data.is_done() )) {
				if ( !selectors.next() ) {
					data.next();
				} else {
					ready = true;
					break;
				}
			}
		}
		return ( !ready );
	});
	
	_iter.selectors = iter( _selectors );
	_iter.ready = false;
	
	return _iter;
}

/// @func _count( [start], [step] )
/// @desc Make an iterator that returns evenly spaced values starting with number start.
/// @arg {number} [start=0]
/// @arg {number} [step=1]

_count = function() {
	var _iter = new Iterator( undefined, function() {
		var _result = start;
		start += step;
		return _result;
	} );
	
	_iter.start = argument_count > 0 ? argument[ 0 ] : 0;
	_iter.step = argument_count > 1 ? argument[ 1 ] : 1;
		
	return _iter;
}

/// @func _cycle( _iterable )
/// @desc Make an iterator returning elements from the iterable and saving a copy of each. When the iterable is exhausted, return elements from the saved copy. 
/// @arg {Iterable} iterable

_cycle = function( _iterable ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		if ( size > 0 ) {
			return cache[ index++ % size ];
		} else {
			var _result = data.next();
			cache[ index++ ] = _result;
			
			if ( data.is_done() ) {
				size = index;	
			}
			
			return _result;
		}
	}, function() {
		return ( size == 0 ) && ( data.is_done() );
	});
	
	_iter.cache = [];
	_iter.index = 0;
	_iter.size = 0;
	
	return _iter;
}

/// @func _drop( iterable, n )
/// @desc Helper function for partially consuming a long of infinite iterable
/// @arg {Number} n
/// @arg {Iterable} iterable

_drop = function( _n, _iterable ) {
	return _islice( _iterable, _n, undefined );	
}

/// @func _dropwhile( iterable, predicate )
/// @desc Returns elements from iterable from the element for which predicate is false
/// @arg {Iterable} iterable
/// @arg {Method} predicate

_dropwhile = function( _iterable, _predicate ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		var _result = cache;
		check = data.is_done();
		cache = data.next();
		return _result;
	}, function() {
		if ( check ) {
			while( !data.is_done() ) {
				var _cache = data.next();
				if ( !predicate( _cache ) ) {
					cache = _cache;
					check = false;
					return false;
				}
			}
		}
		return check;
	});
	
	_iter.cache = undefined; 
	_iter.predicate = _predicate;
	_iter.check = true;
	
	return _iter;
}

/// @func _enumerate( iterable, [start] )
/// @desc Returns [ count, element ] for each element from iterable
/// @arg {Iterable} iterable
/// @arg {Number} [start=0]

 _enumerate = function ( _iterable ) {
	return _zip( _count( ( argument_count > 1 ) ? argument[ 1 ] : 0 ), iter( _iterable ) );
}

/// @func _filter( iterable, [function] )
/// @desc Construct an iterator from those elements of iterable for which function returns true.
/// @arg {Iterable} iterable
/// @arg {Method} [function]

_filter = function( _iterable, _function ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		var _result = cache;
		check = true;
		cache = data.next();
		return _result;
	}, function() {
		if ( check ) {
			while( !data.is_done() ) {
				var _cache = data.next();
				if ( filter( _cache ) ) {
					cache = _cache;
					check = false;
					return false;
				}
			}
		}
		return check;
	});
	
	_iter.cache = undefined; 
	_iter.filter = is_undefined( _function ) ? function( _a ) { return bool( _a ); } : _function;
	_iter.check = true;
	
	return _iter;
}

/// @func _filter_false( iterable, [function] )
/// @desc Construct an iterator from those elements of iterable for which function returns false.
/// @arg {Iterable} iterable
/// @arg {Method} [function]

_filter_false = function ( _iterable, _function ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		var _result = cache;
		check = true;
		cache = data.next();
		return _result;
	}, function() {
		if ( check ) {
			while( !data.is_done() ) {
				var _cache = data.next();
				if ( !filter( _cache ) ) {
					cache = _cache;
					check = false;
					return false;
				}
			}
		}
		return check;
	} );
	
	_iter.cache = undefined; 
	_iter.filter = is_undefined( _function ) ? function( _a ) { return bool( _a ); } : _function;
	_iter.check = true;
	
	return _iter;
}

/// @func _group_by( iterator, [key] )
/// @desc Returns consecutive keys and groups from the iterable.
/// @arg {Iterable} iterable
/// @arg {Method} [key] function computing a key value for each element

_group_by = function ( _iterable ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		check = true;
		return cache;
	}, function() {
		if ( check ) {
			var _size = array_length( group );
			while( !data.is_done() ) {
				check = false;
				var _a = data.next();
				var _key = key_func( _a );
				
				if ( _size == 0 ) {
					key = _key;	
				}
					
				if ( ( _key != key ) || ( data.is_done() ) ) {
					cache = {};
					cache.key = key;
					cache.group = group;
					key = _key;
					group = [ _a ];
					break;
				} else {
					group[ _size++ ] = _a;	
				}
			}
		}
		return check;
	} );
	
	_iter.key_func = ( argument_count > 1 ) ? argument[ 1 ] : function( _x ) { return _x };
	_iter.group = [];
	_iter.cache = undefined;
	_iter.key = undefined;
	_iter.check = true;
	
	return _iter;
}

/// @func _imap( func, [...] )
/// @desc Return an iterator that applies function to every item of arguments, yielding the results. 
/// @arg {Method} func
/// @arg {Iterable} [...]

_imap = function( _function ) {
	var _iter = new Iterator( [ ], function() {
		var a = [];
		
		for ( var i = 0; i < size; i++ ) {
			a[i] = data[i].next();	
		}
		
		switch ( size ) {
			case 1: return func( a[0] );
			case 2: return func( a[0], a[1] );
			case 3: return func( a[0], a[1], a[2] );
			case 4: return func( a[0], a[1], a[2], a[3] );
			case 5: return func( a[0], a[1], a[2], a[3], a[4] );
			case 6: return func( a[0], a[1], a[2], a[3], a[4], a[5] );
			case 7: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6] );
			case 8: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7] );
			case 9: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8] );
			case 10: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9] );
			case 11: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10] );
			case 12: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11] );
			case 13: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12] );
			case 14: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13] );
			case 15: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14] );
			default:
				return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15] );
		}
	}, function( ) {
		for ( var i = 0; i < size; i++ ) {
			if ( data[ i ].is_done() ) {
				return true;	
			}
		}
		return false;
	} );
	
	_iter.func = _function;
	_iter.size = argument_count - 1;
	
	for( var i = 0; i < _iter.size; i++ ) {
		_iter.data[ i ] = iter( argument[ i + 1 ] );
	}
	
	return _iter;
}

/// @func _imap_from_iterable( func, iterable )
/// @desc Return an iterator that applies function to every item of iterable, yielding the results. 
/// @arg {Method} func
/// @arg {Iterable} iterable

_imap_from_iterable = function( _function, _iterable ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		
		var a = data.next();
		if ( is_undefined( size ) ) {
			size = array_length( a );
		}
		
		switch ( size ) {
			case 1: return func( a[0] );
			case 2: return func( a[0], a[1] );
			case 3: return func( a[0], a[1], a[2] );
			case 4: return func( a[0], a[1], a[2], a[3] );
			case 5: return func( a[0], a[1], a[2], a[3], a[4] );
			case 6: return func( a[0], a[1], a[2], a[3], a[4], a[5] );
			case 7: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6] );
			case 8: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7] );
			case 9: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8] );
			case 10: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9] );
			case 11: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10] );
			case 12: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11] );
			case 13: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12] );
			case 14: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13] );
			case 15: return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14] );
			default:
				return func( a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15] );
		}
	}, function( ) {
		return data.is_done();
	} );
	
	_iter.func = _function;
	_iter.size = undefined;
	
	return _iter;
}

/// @func _islice( iterable, [start], stop, [step] )
/// @desc Make an iterator that returns selected elements from the iterable.
/// @arg {Iterable} iterable
/// @arg {Number} [start=0]
/// @arg {Number} stop
/// @arg {Number} [step=1]

_islice = function( _iterable, _stop ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		start += step;
		index++;
		return data.next();
	}, function() {
		while(( index < start ) && !data.is_done() ) {
			data.next();
			index++;
		}
	
		return ( ( index >= stop ) || ( data.is_done() ) );
	});
	
	_iter.index = 0;
	
	_iter.start = argument_count > 2 ? _stop : 0;
	_iter.step = argument_count > 3 ? argument[ 3 ] : 1;
	_iter.stop = ( argument_count > 2 ? argument[ 2 ] : _stop );
	
	if ( is_undefined( _iter.stop ) ) {
		_iter.stop = infinity;	
	}
	
	return _iter;
}

/// @func _repeat( object, [n] )
/// @desc Iterator that returns object over and over again.
/// @arg {Any} elem
/// @arg {Number} [n] If specified, iterator executes this amount of times.

_repeat = function( _object ) {
	var _iter = new Iterator( _object, function() {
		--n;
		return data;
	}, function() {
		return ( n <= 0 );	
	});
	
	_iter.n = ( argument_count > 1 ) ? argument[ 1 ] : infinity;
		
	return _iter;
}

/// @func _take( iterable, n )
/// @desc Helper function for partially consuming a long of infinite iterable
/// @arg {Number} n
/// @arg {Iterable} iterable

_take = function( _n, _iterable ) {
	return _islice( _iterable, _n );	
}

/// @func _takewhile( iterable, predicate )
/// @desc Make an iterator that returns elements from the iterable as long as the predicate is true.
/// @arg {Iterable} iterable
/// @arg {Method} predicate

_takewhile = function( _iterable, _predicate ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		var _result = cache;
		check = true;
		return _result;
	}, function() {
		if ( check ) {
			if( !data.is_done() ) {
				cache = data.next();
				if ( predicate( cache ) ) {
					check = false;
					return false;
				}
			}
		}
		return check;
	});
	
	_iter.cache = undefined; 
	_iter.predicate = _predicate;
	_iter.check = true;
	
	return _iter;
}

/// @func _zip( [...] )
/// @desc Iterator that aggregates elements from each of the iterables until one of them is exhausted.
/// @arg {Iterable} [...]

_zip = function() {
	var _iter = new Iterator( [ ], function() {
		var _result = [];
		for ( var i = 0; i < size; i++ ) {
			_result[ i ] = data[ i ].next();	
		}
		return _result;
	}, function() {
		for ( var i = 0; i < size; i++ ) {
			if ( data[ i ].is_done() ) {
				return true;	
			}
		}
		return ( size == 0 );
	});
	
	_iter.size = argument_count;
	
	for( var i = 0; i < _iter.size; i++ ) {
		_iter.data[ i ] = iter( argument[ i ] );
	}
	
	return _iter;
}

/// @func _zip_longest( [...] , fill_value )
/// @desc Iterator that aggregates elements from each of the iterables until all of them are exhausted.
/// @arg {Iterable} [...]
/// @arg {Any} fill_value

_zip_longest = function() {
	var _iter = new Iterator( [ ], function() {
		var _result = [];
		for ( var i = 0; i < size; i++ ) {
			_result[ i ] = data[i].is_done() ? fill : data[ i ].next();
		}
		return _result;
	}, function() {
		for ( var i = 0; i < size; i++ ) {
			if ( !data[ i ].is_done() ) {
				return false;
			}
		}
		return true;
	});
	
	if ( argument_count == 1 ) {
		_iter.size = 1;
		_iter.data[ 0 ] = argument[ 0 ];
		_iter.fill = undefined;
	} else {
		_iter.size = argument_count - 1;
		_iter.fill = ( argument_count > 0 ) ? argument[ argument_count - 1 ] : undefined;
	}
	
	for( var i = 0; i < _iter.size; i++ ) {
		_iter.data[ i ] = iter( argument[ i ] );
	}
	
	return _iter;
}

#endregion