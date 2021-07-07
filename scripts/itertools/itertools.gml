/// @fileOverview This is the base definition of main Iterator types
/// @module itertools

#region Iterator

/// @func Generator( data, next )
/// @alias Generator
/// @class
///
/// @classdesc Iterator that can never be exhausted
///
/// @arg {Any} data
/// @arg {Method()} next
///
/// @return {Generator}

function Generator( _data, _next ) constructor {
	/// @method is_done
	/// @memberof Generator
	///
	/// @desc Returns true when Iterator is exhausted.
	///
	/// @return {Bool}
	
	is_done = function() {
		return false;
	};
	
	__next = method( self, _next );
	data = _data;
	
	/// @method __iter
	/// @memberof Generator
	///
	/// @desc Return self
	/// @see iter
	///
	/// @return {Iterator}
	
	__iter = function() {
		return self;
	}
	
	/// @method next
	/// @memberof Generator
	///
	/// @desc returns the next yielded element. If Iterator is exhausted, returns undefined.
	///
	/// @return {Any}
	///
	/// @example
	/// var data = iter( "ABCD" );
	///while( !data.is_done() {
	///    data.next(); --> "A", "B", "C", "D"
	///}
	
	static next = function() {
		return is_done() ? undefined : __next();
	}
 }

/// @func Iterator( data, next, [is_done] )
/// @exports Iterator
/// @name Iterator
/// @class
/// @memberof module:itertools
/// @extends Generator
///
/// @classdesc An object representing a stream of data. Repeated calls to the iterator’s next() method return successive items in the stream.
/// When no more data are available returns undefined. At this point, the iterator object is exhausted and any further calls to its next() method just return undefined again.
/// Iterators are required to have an __iter() method that returns the iterator object itself so every iterator is also iterable and may be used in most places where other iterables are accepted.
/// One notable exception is code which attempts multiple iteration passes. A container object (such as a list) produces a fresh new iterator each time you pass it to the iter() function or use it in a for loop.
/// Attempting this with an iterator will just return the same exhausted iterator object used in the previous iteration pass, making it appear like an empty container.
///
/// @arg {Any} data
/// @arg {Method()} next
/// @arg {Method()} is_done
///
/// @return {Iterator}

function Iterator( _data, _next, _is_done ) : Generator( _data, _next ) constructor {
	
	/// @method is_done
	/// @memberof Iterator
	///
	/// @desc Returns true when Iterator is exhausted.
	///
	/// @return {Bool}
	
	is_done = method( self, _is_done );
	
	/// @method combinations
	/// @memberof Iterator
	///
	/// @desc Make an iterator that yields r length subsequences of elements from the iterable.
	///
	/// @arg {Number} [r]
	///
	/// @return {Iterator}
	///
	/// @example
	/// _irange( 4 ).combinations( 3 ) --> [ 0, 1, 2 ], [ 0, 1, 3 ], [ 0, 2, 3 ], [ 1, 2, 3 ]
	
	static combinations = function() {
		var _iter = new Iterator( to_array(), function() {
			var _result = [ ];
			
			for( var i = 0; i < repeats; i++ ) {
				_result[ i ] = data[ index[ i ] ];
			}
			
			var i = repeats;
			while( --i >= 0 ) {
				if ( index[ i ] != i + size - repeats ) {
					break;
				}
			}
			
			if ( i < 0 ) {
				size = 0;
			} else {
				++index[ i ];
				
				for( var j = i + 1; j < repeats; j++ ) {
					index[ j ] = index[ j - 1 ] + 1;
				}
			}
			
			return _result;
		}, function() {
			return ( size == 0 );
		} );
		
		_iter.size = array_length( _iter.data );
		_iter.repeats = ( argument_count > 0 ) ? argument[ 0 ] : undefined;
		
		if ( is_undefined( _iter.repeats ) ) {
			_iter.repeats = _iter.size;
		}
		
		if ( _iter.size < _iter.repeats ) {
			_iter.size = 0;
			return _iter;
		}
		
		_iter.index = _arange( _iter.repeats );
		
		return _iter;
	}
	
	/// @method combinations_with_replacements
	/// @memberof Iterator
	///
	/// @desc Make an iterator that yields r length subsequences of the iterable allowing individual elements to be repeated more than once.
	///
	/// @arg {Number} [r]
	///
	/// @return {Iterator}
	///
	/// @example
	/// _irange( 3 ).combinations_with_replacements( 2 ) --> [ 0, 0 ], [ 0, 1 ], [ 0, 2 ], [ 1, 1 ], [ 1, 2 ], [ 2, 2 ]
	
	static combinations_with_replacements = function() {
		var _iter = new Iterator( to_array(), function() {
			var _result = [ ];
			
			for( var i = 0; i < repeats; i++ ) {
				_result[ i ] = data[ index[ i ] ];
			}
			
			var i = repeats;
			while( --i >= 0 ) {
				if ( index[ i ] != size - 1 ) {
					break;
				}
			}
				
			if ( i < 0 ) {
				size = 0;
			} else {
				++index[ i ];
				
				for( var j = i + 1; j < repeats; j++ ) {
					index[ j ] = index[ i ];
				}
			}
			
			return _result;
		}, function() {
			return ( size == 0 );
		} );
		
		_iter.size = array_length( _iter.data );
		_iter.repeats = ( argument_count > 0 ) ? argument[ 0 ] : undefined;
		
		if ( is_undefined( _iter.repeats ) ) {
			_iter.repeats = _iter.size;
		}
		
		if ( _iter.repeats == 0 ) {
			_iter.size = 0;	
		}
		
		_iter.index = [ ];
		array_resize( _iter.index, _iter.repeats );
		
		return _iter;
	}
	
	/// @method compress
	/// @memberof Iterator
	/// 
	/// @desc Make an iterator that filters elements from iterable returning only those that have a corresponding element in selectors that evaluates to True.
	/// Stops when either the data or selectors iterables has been exhausted.
	///
	/// @arg {Iterable} [selectors]
	///
	/// @return {Iterator} Yields matching elements.
	///
	/// @example
	/// iter( "ABCDEF" ).compress( [ 1, 0, 1, 0, 1, 1 ] ) --> "A", "C", "E", "F"

	static compress = function( _selectors ) {
		var _iter = new Iterator( self, function() {
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
	
	/// @method filter
	/// @memberof Iterator
	///
	/// @desc Construct an iterator from those elements of iterable for which function returns true.
	///
	/// @arg {Method(e)} [function]
	///
	/// @return {Iterator} Yields elements from iterable for which function returns true.
	///
	/// @example
	/// _irange( 10 ).filter( function( x ) { return x % 2 } ) --> 1, 3, 5, 7, 9
	
	static filter = function() {
		var _iter = new Iterator( self, function() {
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
		_iter.filter = ( argument_count > 0 ) ? argument[ 0 ] : _truth;
		_iter.check = true;
		
		return _iter;
	}
	
	/// @method filter_false
	/// @memberof Iterator
	///
	/// @desc Construct an iterator from those elements of iterable for which function returns false.
	///
	/// @arg {Method} [function]
	///
	/// @return {Iterator} Yields elements from iterable for which function returns false.
	///
	/// @example
	/// _irange( 10 ).filter_false( function( x ) { return x % 2 } ) --> 0, 2, 4, 6, 8
	
	static filter_false = function( ) {
		var _iter = new Iterator( self, function() {
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
		_iter.filter = ( argument_count > 0 ) ? argument[ 0 ] : _truth;
		_iter.check = true;
	
		return _iter;
	}
	
	/// @method group_by
	/// @memberof Iterator
	///
	/// @desc Make an iterator that returns consecutive keys and groups from the iterable.
	///
	/// @arg {Method} [key] Function computing a key value for each element. If not specified or is undefined, key defaults to an identity function and returns the element unchanged.
	/// Generally, the iterable needs to already be sorted on the same key function.
	///
	/// @return {Iterator} Yields struct with key and array group for each group.
	///
	/// @example
	/// _take( 2, iter( "AAAABBBCCDAABBB" ).group_by() ) --> { key: "A", group: [ "A", "A", "A", "A" ] }, { key: "B", group: [ "B", "B", "B" ] }
	
	static group_by = function() {
		var _iter = new Iterator( self, function() {
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
					
					if ( ( _key != key ) ) {
						cache = { key: key, group: group };
						key = _key;
						group = [ _a ];
						return false;
					} else {
						group[ _size++ ] = _a;	
					}
				}
				cache = { key: key, group: group };
			}
			return check;
		} );
	
		_iter.key_func = ( argument_count > 0 ) && ( !is_undefined( argument[ 0 ] ) ) ? argument[ 0 ] : _identity;
		_iter.group = [];
		_iter.cache = undefined;
		_iter.key = undefined;
		_iter.check = true;
	
		return _iter;
	}
	
	/// @method map
	/// @memberof Iterator
	///
	/// @desc Return an iterator that applies function to every item of iterable, yielding the results.
	///
	/// @arg {Method} function
	/// @arg {Iterable} [...]
	///
	/// @return {Iterator} Yields result of passing an emement of every argument into a function.
	///
	/// @example
	/// iter( [ 2, 3, 10 ] ).map( function( x ) { return x * x; } ) --> 4, 9, 100

	static map = function( _function ) {
		return _imap( _function, self );
	}
	
	/// @method permutations
	/// @memberof Iterator
	///
	/// @desc Return an iterator that yields r length permutations.
	///
	/// @arg {Number} [r] If r is not specified or is indefined, then r defaults to the length of the iterable and all possible full-length permutations are generated.
	///
	/// @return {Iterator}
	///
	/// @example
	/// _irange( 3 ).permutations( 2 ) -->  [ 0,1 ], [ 0,2 ], [ 1,0 ], [ 1,2 ], [ 2,0 ], [ 2,1 ]
	
	static permutations = function( ) {
		var _iter = new Iterator( to_array(), function() {
			var _result = [ ];
			
			for( var i = 0; i < repeats; i++ ) {
				_result[ i ] = data[ index[ i ] ];
			}
			
			var i = repeats;
			while( --i >= 0 ) {
				if ( --cycles[ i ] == 0 ) {
					var t = index[ i ];
					for( var j = i; j < size - 1; j++ ) {
						index[ j ] = index[ j + 1 ];
					}
					index[ size - 1 ] = t;
					cycles[ i ] = size - i;
				} else {
					array_swap( index, i, size - cycles[ i ] );
					break;
				}
			}
			
			if ( i < 0 ) {
				size = 0;
			}
			
			return _result;
		}, function() {
			return ( size == 0 );
		} );
		
		_iter.size = array_length( _iter.data );
		_iter.repeats = ( argument_count > 0 ) ? argument[ 0 ] : undefined;
		
		if ( is_undefined( _iter.repeats ) ) {
			_iter.repeats = _iter.size;
		}
		
		if ( _iter.size < _iter.repeats ) {
			_iter.size = 0;
			return _iter;
		}
		
		_iter.index = _arange( _iter.size );
		_iter.cycles = _arange( _iter.size, _iter.size - _iter.repeats, -1 );
		
		return _iter;
	}
	
	/// @method product
	/// @memberof Iterator
	///
	/// @desc Return an iterator that yields Cartesian product of items from this Iterator with itself repeats times.
	///
	/// @arg {Number} repeats
	///
	/// @return {Iterator}
	///
	/// @example
	/// iter( [ 0, 1 ] ).product( 3 ) --> [ 0, 0, 0 ], [ 0, 0, 1 ], [ 0, 1, 0 ], [ 0, 1, 1 ], [ 1, 0, 0 ] ...
	
	static product = function( _repeats ) {
		var _iter = new Iterator( self, function() {
			var _result = [ ];
			
			for( var i = 0; i < size; i++ ) {
				_result[ i ] = buffer[ index[ i ] ];
			}
			
			++index[ size - 1 ];
			
			return _result;
		}, function() {
			for( var i = size - 1; i >= 0; i-- ) {
				if ( index[ i ] >= array_length( buffer ) ) {
					if ( data.is_done() ) {
						if ( i > 0 ) {
							index[ i ] = 0;
							++index[ i - 1 ];
						} else {
							size = 0;
						}
					} else {
						buffer[ index[ i ] ] = data.next();
					}
				} else {
					return false;
				}
			}
		
			return ( size == 0 );
		} );
		
		_iter.size = _iter.data.is_done() ? 0 : _repeats;
		_iter.buffer = [ ];
		_iter.index = [ ];
		array_resize( _iter.index, _iter.size );
		
		return _iter;
	}
	
	/// @method reduce
	/// @memberof Iterator
	///
	/// @desc Apply function of two arguments cumulatively to the items of Iterator, from left to right, so as to reduce it to a single value.
	///
	/// @arg {Method(a,x)} function
	/// @arg [Any] initializer
	///
	/// @return {Any}
	///
	/// @example
	/// iter( [ 1, 2, 3, 4 ] ).reduce( function( _a, _x ) { return _a + _x; } ) --> 10
	
	static reduce = function( _function ) {
		var _f = is_method( _function ) ? _function : method( undefined, _function );
		var _acc = ( argument_count > 1 ) ? argument[ 1 ] : ( is_done() ? undefined : next() );
		
		while( !is_done() ) {
			_acc = _f( _acc, next() );
		}
		
		return _acc;
	}
	
	/// @method slice
	/// @memberof Iterator
	///
	/// @desc Make an iterator that returns selected elements from the iterable. If start is non-zero, then elements from the iterable are skipped until start is reached. Afterward, elements are returned consecutively unless step is set higher than one which results in items being skipped. If stop is undefined, then iteration continues until the iterator is exhausted, if at all; otherwise, it stops at the specified position.
	///
	/// @arg {Iterable} iterable
	/// @arg {Number} [start=0]
	/// @arg {Number} stop
	/// @arg {Number} [step=1]
	///
	/// @return {Iterator} Yields only elements from range.
	///
	/// @example
	/// iter( "ABCDEFG" ).slice( 2 ) --> "A", "B"
	///iter( "ABCDEFG" ).slice( 2, 4 ) --> "C", "D"
	///iter( "ABCDEFG" ).slice( 2, undefined ) --> "C", "D", "E", "F", "G"
	///iter( "ABCDEFG" ).slice( 0, undefined, 2 ) --> "A", "C", "E", "G"
	
	static slice = function( _stop ) {
		var _iter = new Iterator( self, function() {
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
	
		_iter.start = argument_count > 1 ? _stop : 0;
		_iter.step = argument_count > 2 ? argument[ 2 ] : 1;
		_iter.stop = ( argument_count > 1 ? argument[ 1 ] : _stop );
	
		if ( is_undefined( _iter.stop ) ) {
			_iter.stop = infinity;	
		}
	
		return _iter;
	}
	
	/// @method sorted
	/// @memberof Iterator
	///
	/// @desc Returns a new Iterator that yields items in iterable sorted
	///
	/// @arg {Method} [key=undefined]
	/// @arg {Bool} [_reverse=false]
	///
	/// @example
	/// iter( [ 5, 2, 3, 1, 4 ] ).sorted() --> 1, 2, 3, 4, 5
	
	static sorted = function( ) {
		var _key = ( argument_count > 0 ) ? argument[ 0 ] : undefined;
		var _reverse = ( argument_count > 1 ) ? argument[ 1 ] : false;
		
		return iter( array_sort( to_array(), _key, _reverse ) );
	}
	
	/// @method to_array
	/// @memberof Iterator
	///
	/// @desc Exhausts iterator and combines all of its elements into an array
	///
	/// @return {Array}
	///
	/// @example
	/// iter( "1234" ).to_array() --> [ "1", "2", "3", "4" ]
	
	static to_array = function() {
		var _a = [];
		var _n = 0;
		
		while( !is_done() ) {
			_a[ _n++ ] = next();
		}
		return _a;
	}
	
	/// @method to_string
	/// @memberof Iterator
	///
	/// @desc Exhausts iterator and combines all of its elements into a string.
	///
	/// @arg {String} [separator]
	///
	/// @return {String}
	///
	/// @example
	/// iter( [ 1, 2, 3, 4 ] ).to_string() --> "1234"
	
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
	
	/// @method unique
	/// @memberof Iterator
	///
	/// @desc Returns a new Iterator that yields non-repeating items from sorted iterable
	///
	/// @arg {Method} [key=undefined]
	///
	/// @return {Iterator}
	///
	/// @example
	/// iter( "abcacbacbacbac" ).unique().to_string() --> "abc"
	
	static unique = function() {
		var _key = ( argument_count > 0 ) ? argument[ 0 ] : undefined;
		return sorted( _key ).group_by( _key ).map( function( e ) { return e.group[ 0 ]; } );
	}
}

/// @func IteratorDict( data, next, [is_done] )
/// @name IteratorDict
/// @class
/// @memberof module:itertools
/// @extends Iterator
///
/// @classdesc Iterator for key-value styled data structures
/// @see __iter_dict
///
/// @arg {Any} data
/// @arg {Method()} next
/// @arg {Method()} is_done
///
/// @return {Iterator} - iterator struct

function IteratorDict( _data, _next, _is_done ) : Iterator( _data, _next, _is_done ) constructor {

	/// @method names
	/// @memberof IteratorDict
	///
	/// @desc return Iterator of names
	///
	/// @return {Iterator}
	
	static names = function() {
		return map( function( e ) { return e[ 0 ]; } );
	}
	
	/// @method values
	/// @memberof IteratorDict
	///
	/// @desc return Iterator of names
	///
	/// @return {Iterator}
	
	static values = function() {
		return map( function( e ) { return e[ 1 ]; } );
	}
	
	/// @method to_map
	/// @memberof IteratorDict
	///
	/// @desc return ds_map of key-value pairs
	///
	/// @return {ds_map}
	
	static to_map = function( _id ) {
		var _ds = is_undefined( _id ) ? ds_map_create() : _id;

		while( !is_done() ) {
			var _key = next_key();
			ds_map_add( _ds, _key, get( _key ) );
		}

		return _ds;
	}
	
	/// @method to_struct
	/// @memberof IteratorDict
	///
	/// @desc return ds_map of key-value pairs
	///
	/// @return {Struct}
	
	static to_struct = function( _id ) {
		var _ds = is_undefined( _id ) ? {} : _id;

		while( !is_done() ) {
			var _key = next_key();
			variable_struct_set( _ds, _key, get( _key ) );
		}

		return _ds;
	}
}

/// @func __iter_dict
///
/// @desc Helper function for creating IteratorDict
///
/// @arg {Any} object
/// @arg {Method} next_key
/// @arg {Method} get
/// @arg {Method} is_done
///
/// @return {IteratorDict}

function __iter_dict( _object, _next_key, _get, _is_done ) {
	var _iter = new IteratorDict( _object, function() {
		var _key = next_key();
		return [ _key, get( _key ) ];
	}, _is_done );
	
	_iter.next_key = method( _iter, _next_key );
	_iter.get =	method( _iter, _get );
	
	return _iter;
}

/// @func IteratorCollection( data, next, is_done )
/// @name IteratorCollection
/// @class
/// @extends Iterator
///
/// @classdesc Reversible Iterator
/// @see __iter_collection
///
/// @arg {Any} data
/// @arg {Method()} next
/// @arg {Method()} is_done
///
/// @return {Iterator} - iterator struct

function IteratorCollection( _data, _next, _is_done ) : Iterator( _data, _next, _is_done ) constructor {
	
	/// @method get
	/// @memberof IteratorCollection
	///
	/// @desc returns element by key
	///
	/// @arg {Any} key
	///
	/// @return {Iterator}
	
	/// @method len
	/// @memberof IteratorCollection
	///
	/// @desc returns amount of elements in iterable
	///
	/// @return {Iterator}
	
	/// @method reverse
	/// @memberof IteratorCollection
	///
	/// @desc reverses iterator
	///
	/// @return {Iterator}
	
	static reverse = function() {
		dir = -dir;
		index = size - index - 1;
		return method_get_self( __next );
	}
}

/// @func __iter_collection
///
/// @desc Helper function for building IteratorCollection
///
/// @arg {Any} object
/// @arg {Method(key)} get
/// @arg {Method()} len
///
/// @return {IteratorCollection}

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

/// @func _tee
///
/// @desc returns n independent iterators from single iterable. Once _tee() has made a split, the original iterable should not be used anywhere else; otherwise, the iterable could get advanced without the tee objects being informed.
///
/// @arg {Iterable} iterable
/// @arg {Number} [n=2]
///
/// @return {Array} Array containing n Iterators.
///
/// @example
/// var t = _tee( range( 7 ) );
///_zip( _t[0], _drop( 1, _t[ 1 ] ) ) --> [ 0, 1 ], [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ]

function _tee( _iterable ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		var _result = data.next();
		for( var i = 0; i < size; i++ ) {
			var _child = children[ i ];
			_child.cache[ _child.size++ ] = _result;
		}
	}, function() {
		return data.is_done();	
	} );
	
	_iter.size = ( argument_count > 1 ) ? argument[ 1 ] : 2;
	_iter.children = [ ];
	
	for( var i = 0; i < _iter.size; i++ ){
		var _child = new Iterator( _iter, function() {
			if ( size == 0 ) {
				data.next();
			}
			return cache[ index++ ];
		}, function() {
			if ( index > 0 ) {
				var _t = [];
				array_copy( _t, 0, cache, index--, --size );
				cache = _t;
			}
			return ( data.is_done() && ( size == 0 ) );
		} );
		
		_child.cache = [ ];
		_child.index = 0;
		_child.size = 0;
		
		_iter.children[ i ] = _child;
	}
	
	return _iter.children;
}

#endregion

#region Range

/// @func Range( [start], stop, [step] )
/// @name Range
/// @class
///
/// @classdesc range struct constructor
/// @see _range
///
/// @arg {Number} [start=0]
/// @arg {Number} stop
/// @arg {Number} [step=1]
///
/// @return {Range}

function Range( _start, _stop, _step ) constructor {
	
	start = _start;
	stop = _stop;
	step = _step;
	
	/// @method __iter
	/// @memberof Range
	///
	/// @return {Iterator}
	
	static __iter = function() {
		return _irange( start, stop, step );
	}
	
	/// @method prod
	/// @memberof Range
	///
	/// @desc Returns product of all numbers in range
	///
	/// @arg {Number} [start]
	/// @arg {Number} [stop]
	/// @arg {Number} [step]
	///
	/// @return {Number}
	
	static prod = function() {
		return range_prod( start, stop, step );
	}
	
	/// @method reversed
	/// @memberof Range
	///
	/// @return {Range}
	
	static reversed = function() {
		var _stop = stop + _mod( start - stop, step );
		return new Range( _stop - step, start - step, -step );
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

function _range( _stop ) {
	var _start = argument_count > 1 ? _stop : 0;
	var _step = argument_count > 2 ? argument[ 2 ] : 1;
	_stop = ( argument_count > 1 ? argument[ 1 ] : _stop );
	
	return new Range( _start, _stop, _step )
}

/// @func _arange
///
/// @desc returns range array
///
/// @arg {Number} [start=0]
/// @arg {Number} stop
/// @arg {Number} [step=1]
///
/// @return {Array}

function _arange( _stop ) {
	var _start = argument_count > 1 ? _stop : 0;
	var _step = argument_count > 2 ? argument[ 2 ] : 1;
	_stop = ( argument_count > 1 ? argument[ 1 ] : _stop );
	
	return _irange( _start, _stop, _step ).to_array();
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

function _irange ( _stop ) {
	var _iter = new Iterator( ( argument_count > 1 ) ? _stop : 0, function() {
			var _result = data;
			data += step;
			return _result;
	}, function() {
		return floor( ( data - stop ) / step ) >= 0;
	} );
	
	_iter.step = ( argument_count > 2 ) ? argument[ 2 ] : 1;
	_iter.stop = ( ( argument_count > 1 ) ? argument[ 1 ] : _stop );
	
	_iter.reversed = method( _iter, function() {
		var _stop = stop + _mod( data - stop, step );
		return _irange( _stop - step, data - step, -step );
	} );
	
	return _iter;
}

/// @function range_prod
///
/// @desc Returns product of all numbers in range
///
/// @arg {Number} [start = 1]
/// @arg {Number} stop
/// @arg {Number} [step = 1]
///
/// @return {Number}
	
function range_prod( _stop ) {
	var _start = argument_count > 1 ? _stop : 1;
	var _step = argument_count > 2 ? argument[ 2 ] : 1;
	_stop = ( argument_count > 1 ? argument[ 1 ] : _stop );
		
	if ( ( _step == 2 ) && ( ( _start % 2 ) == 0 ) ) {
		_stop += _stop & 1;
		
		var _numfactors = ( _stop - _start ) >> 1;
		
		if ( _numfactors == 2 ) {
			return _start * ( _start + 2 );
		}
		
		if ( _numfactors > 1 ) {
			var _mid = ( _start + _numfactors ) | 1;
			return range_prod( _start, _mid, 2 ) * range_prod( _mid + 1, _stop, 2 );
		}
		
		if ( _numfactors == 1 ) {
			return _start;
		}
		
		return 1;
	}
	
	var _result = 1;
	
	while( floor( ( _start - _stop ) / _step ) < 0 ) {
		_result *= _start;	
		_start += _step;
	}
	
	return _result;
}

#endregion

#region Random

/// @func Random( _seed, _next, _get_seed, _set_seed )
/// @name Random
/// @class
///
/// @classdesc Iterator that yields random values
///
/// @arg {Number} seed
/// @arg {Method()} next
///
/// @return {Random}

function Random( _seed, _next ) : Generator( _seed, _next ) constructor {
	
	/// @method next
	/// @memberof Random
	///
	/// @desc Generates the next pseudorandom number. This function is passed into constructor and other functions are using it to generate specific random values, so it essentially makes a pseudo-random generation engine.
	///
	/// @arg {Number} [bits=32] That many low-order bits of the returned value will be (approximately) independently chosen bit values, each of which is (approximately) equally likely to be 0 or 1.
	///
	/// @return {Number}
	
	static next = function() {
		var _bits = ( argument_count > 0 ) ? argument[ 0 ] : 32;
		
		return __next( _bits );
	}
	
	/// @method get_seed
	/// @memberof Random
	///
	/// @desc Returns current seed
	///
	/// @return {Number}
	
	static get_seed = function() {
		return data;
	}
	
	/// @method set_seed
	/// @memberof Random
	///
	/// @desc Replaces current seed
	///
	/// @arg {Number} seed
	
	static set_seed = function( _seed ) {
		data = _seed;
		__have_next_gaussian = false;
	}
	
	/*
		basic random functions
	*/
	
	/// @method next_bool
	/// @memberof Random
	///
	/// @desc Return true or false
	///
	/// @return {Bool} The next pseudorandom, uniformly distributed boolean value from this random number generator's sequence.
	
	static next_bool = function() {
		return next( 1 );
	}
	
	/// @method next_double
	/// @memberof Random
	///
	/// @desc Return floating point value in range [ 0, n )
	///
	/// @arg {Number} [n=1]
	///
	/// @return {Number} The next pseudorandom, uniformly distributed double-precission floating point value between 0.0 ( inclusive ) and n ( exclusive ) from this random number generator's sequence.
	
	static next_double = function() {
		var n = ( argument_count > 0 ) ? argument[ 0 ] : 1.0;
		
		return ( ( ( next( 26 ) << 27 ) + next( 27 ) ) / $20000000000000 ) * n;
	}
	
	/// @method next_float
	/// @memberof Random
	///
	/// @desc Return floating point value in range [ 0, n )
	///
	/// @arg {Number} [n=1]
	///
	/// @return {Number} The next pseudorandom, uniformly distributed float value between 0.0 ( inclusive ) and n ( exclusive ) from this random number generator's sequence.
	
	static next_float = function() {
		var n = ( argument_count > 0 ) ? argument[ 0 ] : 1.0;
		return ( next( 24 ) / $1000000 ) * n;
	}
	
	/// @method next_int
	/// @memberof Random
	///
	/// @desc Return integer value in range [ 0, n )
	///
	/// @arg {Number} [ n = 4294967296 ]
	///
	/// @return {Number} The next pseudorandom, uniformly distributed int value between 0 (inclusive) and n (exclusive) from this random number generator's sequence.
	
	static next_int = function( ) {
		var n = ( argument_count > 0 ) ? argument[ 0 ] : $100000000;
		var _negative = n < 0;
		var _result;
		
		if ( ( n & -n ) == n ) {
			_result = ( n * next( 31 ) ) >> 31;
		} else {
			var _bits;
			do {
				_bits = next( 31 );
				_result = _bits % n;
			} until ( _bits - _result + ( n - 1 ) >= 0 );
		}
			 
		return _negative ? -_result : _result;
	}
	
	/// @method next_int64
	/// @memberof Random
	///
	/// @desc Return integer value in range
	///
	/// @return {Number} The next pseudorandom, uniformly distributed int64 value from this random number generator's sequence.
	
	static next_int64 = function( n ) {
		return int64 ( ( next( 32 ) << 32 ) + next( 32 ) );
	}
	
	/*
		integer random
	*/
	
	/// @method range
	/// @memberof Random
	///
	/// @arg {Number} [start=0]
	/// @arg {Number} stop
	/// @arg {Number} [step=1]
	///
	/// @return {Number}
		
	static range = function( _stop ) {
		var _start = argument_count > 1 ? _stop : 0;
		var _step = argument_count > 2 ? argument[ 2 ] : 1;
		_stop = ( argument_count > 1 ? argument[ 1 ] : _stop );
		
		if ( ( argument_count == 1 ) && instanceof( _stop ) == "Range" ) {
			_start = _stop.start;
			_step = _stop.step;
			_stop = _stop.stop;
		}
		
		var n = ceil( ( _stop - _start ) / _step );
		
		return _start + next_int( n ) * _step;
	}
	
	/*
		Random things and iterables
	*/
	
	/// @method choice
	/// @memberof Random
	///
	/// @desc Fully consume iterable and return random element from it.
	///
	/// @arg {Iterable} iterable
	///
	/// @return {Any} random item from iterable
	
	static choice = function( _iterable ) {
		_iterable = ( is_array( _iterable ) ) ? _iterable : iter( _iterable ).to_array();
		
		return _iterable[ next_int( array_length( _iterable ) ) ];
	}
	
	/// @method choices
	/// @memberof Random
	///
	/// @desc Fully consume iterable and return k random elements with replacement.
	///
	/// @arg {Iterable} iterable
	/// @arg {Number} [k=1]
	///
	/// @return {Any} random item from iterable
	
	static choices = function( _iterable ) {
		_iterable = ( is_array( _iterable ) ) ? _iterable : iter( _iterable ).to_array();
		var k = ( argument_count > 1 ) ? argument[ 1 ] : 1;
		
		var _result = [ ];
		
		var n = array_length( _iterable );
		for ( var i = 0; i < k; i++ ) {
			_result[ i ] = _iterable[ next_int( n ) ];
		}
		
		return _result;
	}
	
	/// @method choices_weighted
	/// @memberof Random
	///
	/// @desc Fully consume iterable and return k random elements with replacement.
	///
	/// @arg {Iterable} iterable
	/// @arg {Iterable} weights
	/// @arg {Number} [k=1]
	///
	/// @return {Array} random items from iterable
	
	static choices_weighted = function( _iterable, _weights ) {
		var k = ( argument_count > 2 ) ? argument[ 2 ] : 1;
		
		return choices_weighted_cumulative( _iterable, _accumulate( _weights ), k );
	}
	
	/// @method choices_weighted_cumulative
	/// @memberof Random
	///
	/// @desc Fully consume iterable and return k random elements with replacement.
	///
	/// @arg {Iterable} iterable
	/// @arg {Iterable} weights cumulative weights
	/// @arg {Number} [k=1]
	///
	/// @return {Array} random items from iterable
	
	static choices_weighted_cumulative = function( _iterable, _weights ) {
		_iterable = ( is_array( _iterable ) ) ? _iterable : iter( _iterable ).to_array();
		var n = array_length( _iterable );
		_weights = ( is_array( _weights ) ) ? _weights : iter( _weights ).to_array();
		
		if ( array_length( _weights ) != n ) {
			throw "The number of weights does not match the population";
		}
		
		var _total = _weights[ --n ];
		
		if ( _total <= 0 ) {
			throw "Total of weights must be greater than zero.";
		}
		
		var k = ( argument_count > 2 ) ? argument[ 2 ] : 1;
		var _result = [ ];
				
		for ( var i = 0; i < k; i++ ) {
			_result[ i ] = _iterable[ array_bisect_right( _weights, next_float( _total ), 0, n ) ];
		}
		
		return _result;
	}
	
	/// @method sample
	/// @memberof Random
	///
	/// @desc Returns k non-repeating items from input iterable.
	///
	/// @arg {Iterable} iterable
	/// @arg {Number} [k=1]
	///
	/// @return {Array}
	
	static sample = function( _iterable ) {
		_iterable = ( is_array( _iterable ) ) ? array_clone( _iterable ) : iter( _iterable ).to_array();
		var n = array_length( _iterable );
		var k = ( argument_count > 1 ) ? argument[ 1 ] : 1;
		
		if ( !is_between( k, 0, n ) ) {
			throw "Sample is too large or is negative";	
		}
		
		if ( k == n ) {
			return shuffle( _iterable );	
		}
		
		var _result = [ ];
		
		for( var i = 0; i < k; i++ ) {
			var j = next_int( n-- );
			_result[ i ] = _iterable[ j ];
			_iterable[ j ] = _iterable[ n ];
		}
		
		return _result;
	}
	
	/// @method sample_weighted
	/// @memberof Random
	///
	/// @desc Returns k non-repeating items from input iterable.
	///
	/// @arg {Iterable} iterable
	/// @arg {Iterable} weights
	/// @arg {Number} [k=1]
	///
	/// @return {Array}
	
	static sample_weighted = function( _iterable, _weights ) {
		_iterable = ( is_array( _iterable ) ) ? array_clone( _iterable ) : iter( _iterable ).to_array();
		var n = array_length( _iterable );
		
		_weights = ( is_array( _weights ) ) ? _weights : _accumulate( _weights ).to_array();
		
		if ( array_length( _weights ) != n ) {
			throw "The number of weights does not match the population";
		}
		
		var k = ( argument_count > 2 ) ? argument[ 2 ] : 1;
		
		var _total = _weights[ n - 1 ];
		
		if ( !is_between( k, 0, n ) ) {
			throw "Sample is too large or is negative";	
		}
		
		if ( _total != floor( _total ) ) {
			throw "Weights must be integers";
		}
		
		if ( _total <= 0 ) {
			throw "Total of weights must be greater than zero.";
		}
		
		var _result = sample( _irange( _total ), k );
		
		for( var i = 0; i < k; i++ ) {
			_result[ i ] = _iterable[ array_bisect_right( _weights, _result[ i ] ) ];
		}
		
		return _result;
	}
	
	/// @method shuffle
	/// @memberof Random
	///
	/// @desc Returns shuffled array with items from input iterable. If iterable is array, shuffles the array itself.
	///
	/// @arg {Iterable} iterable
	///
	/// @return {Array}
	
	static shuffle = function( _iterable ) {
		_iterable = ( is_array( _iterable ) ) ? _iterable : iter( _iterable ).to_array();
		
		for( var i = array_length( _iterable ) - 1; i > 0; i-- ) {
			var j = next_int( i + 1 );
			array_swap( _iterable, i, j );
		}
		
		return _iterable;
	}
	
	/*
		floating point random distributions
	*/
	
	/// @method exp_variate
	/// @memberof Random
	///
	/// @desc Exponential distribution.
	///
	/// @arg {Number} labmda lambda is 1.0 divided by the desired mean. It should be nonzero.
	///
	/// @return {Number}
	
	static exp_variate = function( _lambda ) {
		return -ln( 1.0 - next_float() ) / _lambda;
	}
	
	__next_gaussian = 0;
	__have_next_gaussian = false;
	
	/// @method gaussian
	/// @memberof Random
	///
	/// @desc Gaussian distribution.
	///
	/// @arg {Number} [mu=0] mean
	/// @arg {Number} [sigma=1] standard deviation
	///
	/// @return {Number}
	
	static gaussian = function( ) {
		if ( __have_next_gaussian ) {
			__have_next_gaussian = false;
			return __next_gaussian;
		} else {
			var _mu = ( argument_count > 0 ) ? argument[ 0 ] : 0.0;
			var _sigma = ( argument_count > 1 ) ? argument[ 1 ] : 1.0;
		
			var x2pi = next_float() * TWOPI;
			var g2rad = sqrt( -2.0 * ln( 1.0 - next_float() ) )
			var z = cos( x2pi ) * g2rad;
			
			__next_gaussian = sin( x2pi ) * g2rad;
			__have_next_gaussian = true;
			
			return _mu + z * _sigma;
		}
	}
	
	/// @method log_norm_variate
	/// @memberof Random
	///
	/// @desc If you take the natural logarithm of this distribution, you'll get a normal distribution with mean mu and standard deviation sigma.
	///
	/// @arg {Number} [mu=0] mean
	/// @arg {Number} [sigma=1] standard deviation. Sigma must be greater than zero.
	///
	/// @return {Number}
	
	static log_norm_variate = function() {
		var _mu = ( argument_count > 0 ) ? argument[ 0 ] : 0.0;
		var _sigma = ( argument_count > 1 ) ? argument[ 1 ] : 1.0;
		
		return exp( normal_variate( _mu, _sigma ) );
	}
	
	/// @method normal_variate
	/// @memberof Random
	///
	/// @desc Normal distribution.
	///
	/// @arg {Number} [mu=0] mean
	/// @arg {Number} [sigma=1] standard deviation
	///
	/// @return {Number}
	
	static normal_variate = function() {
		var v1, v2, z, zz;
		
		do {
			v1 = next_float();
			v2 = 1.0 - next_float();
			z = NV_MAGICCONST * ( v1 - 0.5 ) / v2;
			zz = z * z / 4.0
		} until ( zz <= -ln( v2 ) );
		
		var _mu = ( argument_count > 0 ) ? argument[ 0 ] : 0.0;
		var _sigma = ( argument_count > 1 ) ? argument[ 1 ] : 1.0;
		
        return _mu + z * _sigma;
	}
	
	/// @method pareto_variate
	/// @memberof Random
	///
	/// @desc Pareto distribution.
	///
	/// @arg {Number} alpha Shape parameter.
	///
	/// @return {Number}
	
	static pareto_distribution = function( _alpha ) {
		return( 1 / power( 1 - next_float( ), ( 1 / _alpha ) ) );	
	}
	
	/// @method triangular
	/// @memberof Random
	///
	/// @desc Return a random floating point number N such that a <= N <= b and with the specified mode between those bounds.
	///
	/// @arg {Number} [a=0]
	/// @arg {Number} [b=1]
	/// @arg {Number} [mode=(a+b)/2]
	///
	/// @return {Number}
	
	static triangular = function() {
		var a = ( argument_count > 0 ) ? argument[ 0 ] : 0;
		var b = ( argument_count > 1 ) ? argument[ 1 ] : 1;
		
		if ( a == b ) {
			return a;	
		}
		
		var c = ( argument_count > 2 ) ? ( argument[ 2 ] - a ) / ( b - a ): 0.5;
		
		var u = next_float();
		
		if ( u > c ) {
			u = 1.0 - u;
			c = 1.0 - c;
			var t = a;
			a = b;
			b = t;
		}
		
		return a + ( b - a ) * sqrt( u * c );
	}
	
	/// @method uniform
	/// @memberof Random
	///
	/// @desc Return floating point value in range [ a, b ). Value b may or may not be included in this range depending on floating-point rounding.
	///
	/// @arg {Number} a
	/// @arg {Number} b
	///
	/// @return {Number}
	
	static uniform = function( a, b ) {
		return a + next_float( b - a );
	}
	
	/// @method von_mises_variate
	/// @memberof Random
	///
	/// @desc Circular distribution
	///
	/// @arg {Number} mu Mean angle, expressed in radians between 0 and 2*pi
	/// @arg {Number} kappa Concentration parameter, which must be greater than or equal to zero. If kappa is equal to zero, this distribution reduces to a uniform random angle over the range 0 to 2*pi.
	///
	/// @return {Number}
	
	static von_mises_variate = function( _mu, _kappa ) {
		if ( _kappa <= 0.000001 ) {
			return next_float( TWOPI );	
		}
		
		var s = 0.5 / _kappa;
		var r = s + sqrt( 1.0 + s * s );
		
		var v1, v2, d, z;
		
		do {
			v1 = next_float();
			z = cos( pi * v1 );
			
			d = z / ( r + z );
			v2 = next_float();
			
		} until ( ( v2 < ( 1.0 - d * d ) ) or ( v2 <= ( ( 1.0 - d ) * exp( d ) ) ) );
		
		var q = 1.0 / r;
		var f = ( q + z ) / ( 1.0 + q * z );
		
		return ( _mu + ( ( next_bool() ) ? arccos( f ) : -arccos( f ) ) ) % TWOPI;
	}
	
	/// @method weibull_variate
	/// @memberof Random
	///
	/// @desc Weibull distribution.
	///
	/// @arg {Number} _alpha Scale parameter
	/// @arg {Number} _beta Shape parameter
	///
	/// @return {Number}
	
	static weibull_variate = function( _alpha, _beta ) {
		return _alpha * power( -ln( 1 - next_float( ) ), ( 1 / _beta ) );	
	}
}

/// @func _random
///
/// @desc creates Random object that uses Park–Miller random number generator
///
/// @arg {Number} [seed]
///
/// @return {Random}

function _random( ) {
	var _seed = ( argument_count > 0 ) ? argument[ 0 ] : get_timer();
	
	var _iter =  new Random( _seed, function() {
		var _bits = clamp( ( argument_count > 0 ) ? argument[ 0 ] : 32, 0, 32 );
				
		data = ( data * $5deece66d + 11 ) & $ffffffffffff;
		
		return ( data >> ( 48 - _bits ) );
	});
	
	return _iter;
}

#endregion

#region iter

/// @func ds_list_iter
/// 
/// @desc Returns iterator object for ds_list data structure.
///
/// @arg {ds_list} list
///
/// @return {IteratorCollection}

function ds_list_iter( _list ) {
	return __iter_collection( _list, function( _n ) {
		return data[| _n];
	}, function() {
		return ds_list_size( data );	
	});
}

/// @func ds_stack_iter
/// 
/// @desc Returns iterator object for ds_stack data structure.
///
/// @arg {ds_stack} stack
///
/// @return {Iterator}

function ds_stack_iter( _stack ) {
	var _iter = new Iterator( _stack, function() {
		return ds_stack_pop( data );
	}, function() {
		return ds_stack_empty( data );
	} );
	
	return _iter;
}

/// @func ds_queue_iter
///
/// @desc Returns iterator object for ds_queue data structure.
///
/// @arg {ds_queue} queue
///
/// @return {Iterator}

function ds_queue_iter( _queue ) {
	var _iter = new Iterator( _queue, function() {
		return ds_queue_dequeue( data );
	}, function() {
		return ds_queue_empty( data );	
	} );
	
	return _iter;
}

/// @func ds_map_iter
///
/// @desc Returns iterator object for ds_queue data structure.
///
/// @arg {ds_map} map
///
/// @return {IteratorDict}

function ds_map_iter( _map ) {
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

/// @func ds_priority_max_iter
///
/// @desc Returns iterator object for ds_priority data structure.
///
/// @arg {ds_priority} priority
///
/// @return {Iterator} Yields max priority elements

function ds_priority_max_iter( _priority ) {
	var _iter = new Iterator( _priority, function() {
		return ds_priority_delete_max( data );
	}, function() {
		return ds_priority_empty( data );
	} );
	
	return _iter;
}

/// @func ds_priority_min_iter
///
/// @desc Returns iterator object for ds_priority data structure.
///
/// @arg {ds_priority} priority
///
/// @return {Iterator} Yields min priority elements

function ds_priority_min_iter( _priority ) {
	var _iter = new Iterator( _priority, function() {
		return ds_priority_delete_min( data );
	}, function() {
		return ds_priority_empty( data );
	} );
	
	return _iter;
}

/// @func is_iterable
///
/// @desc Returns if object is iterable.
///
/// @arg {Iterable} object
///
/// @return {Bool}

function is_iterable( _object ) {
	switch ( typeof( _object ) ) {
		case "string":
		case "array":
		case "struct":
			return true;			
		default:
			return false;
	end;
}

/// @func iter
///
/// @desc Creates Iterator from provided Iterable.
///
/// @arg {Iterable} object
/// @arg {Any} [sentinel] used if object is method
///
/// @return {Iterator}

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
			
			var _iter = new Iterator( _sentinel, function() {
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
			_iter.cache = undefined;
			_iter.check = true;
		
			
		default:
			return iter( [ _object ] );
	end;
}

#endregion

#region iterators

/// @func _accumulate
///
/// @desc Make an iterator that returns accumulated sums, or accumulated results of other binary functions (specified via the optional func argument).
///
/// If func is supplied, it should be a function of two arguments. Elements of the input iterable may be any type that can be accepted as arguments to func.
///
/// Usually, the number of elements output matches the input iterable. However, if the optional argument initial is provided, the accumulation leads off with the initial value so that the output has one more element than the input iterable.
/// @see _reduce
///
/// @arg {Iterable} iterable
/// @arg {Method( a, b )} [func]
/// @arg {Any} [initial]
///
/// @return {Iterator} Yields accumulated sums.
///
/// @example
/// _accumulate( [ 1, 2, 3, 4, 5 ] ) --> 1, 3, 6, 10, 15
///_accumulate( [ 1, 2, 3, 4, 5 ], undefined, 100 ) --> 101, 103, 106, 110, 115
///
/// @example
/// data = [ 3, 4, 6, 2, 1, 9, 0, 7, 5, 8 ];
///_accumulate( data, _max ).to_array()
///--> [ 3, 4, 6, 6, 6, 9, 9, 9, 9, 9 ]

function _accumulate( _iterable ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		check = true;
		return sum;
	}, function() {
		if ( check ) {
			if ( !data.is_done() ) {
				sum = func( sum, data.next() );
				check = false;
			}
		}
		
		return check;
	} );
		
	if ( argument_count > 1 ) {
		if ( is_method( argument[ 1 ] ) || ( argument_count > 2 ) ) {
			_iter.func = argument[ 1 ];
			
			if ( argument_count > 2 ) {
				_iter.sum = argument[ 2 ];
				_iter.check = false;
			} else if ( _iter.data.is_done() ) {
				_iter.sum = undefined;
				_iter.check = true;
			} else {
				_iter.sum = _iter.data.next();
				_iter.check = false;
			}
			
			return _iter;
		} else {
			_iter.sum = argument[ 1 ];
			_iter.check = false;
		}
	} else if ( _iter.data.is_done() ) {
		_iter.sum = undefined;
		_iter.check = true;
	} else {
		_iter.sum = _iter.data.next();
		_iter.check = false;
	}
	
	_iter.func = _add;
	
	return _iter;
}


/// @func _chain
///
/// @desc Make an iterator that returns elements from the first iterable until it is exhausted, then proceeds to the next iterable, until all of the iterables are exhausted. Used for treating consecutive sequences as a single sequence.
/// @see _chain_from_iterable
///
/// @arg {Iterable} [...]
///
/// @return {Iterator} Yields chained elements of input iterables.
///
/// @example
/// _chain( "ABC", "DEF" ) --> "A", "B", "C", "D", "E", "F"

function _chain() {
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

/// @func _chain_from_iterable
///
/// @desc Make an iterator that returns chained elements from iterables returned by argument iterable
/// @see _chain
///
/// @arg {Iterable} iterable
///
/// @result {Iterator} Yields chained elements of iterables received from input iterable.
///
/// @example
/// _chain( [ "ABC", "DEF" ] ) --> "ABC", "DEF"
///_chain_from_iterable( [ "ABC", "DEF" ] ) --> "A", "B", "C", "D", "E", "F"

function _chain_from_iterable( _iterable ) {
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

/// @func _compress
/// 
/// @desc Make an iterator that filters elements from iterable returning only those that have a corresponding element in selectors that evaluates to True.
/// Stops when either the data or selectors iterables has been exhausted.
///
/// @arg {Iterable} iterable
/// @arg {Iterable} [selectors]
///
/// @return {Iterator} Yields matching elements.
///
/// @example
/// _compress( "ABCDEF", [ 1, 0, 1, 0, 1, 1 ] ) --> "A", "C", "E", "F"

function _compress( _iterable, _selectors ) {
	return iter( _iterable ).compress( _selectors );
}

/// @func _count
///
/// @desc Make an iterator that returns evenly spaced values starting with number start.
///
/// @arg {Number} [start=0]
/// @arg {Number} [step=1]
///
/// @return {Iterator} Infinitely yields numbers start, start + step, start + 2 * step, ...
///
/// @example
/// _count( 10 ) --> 10, 11, 12, 13, 14, ...
///_count( 2.5, 0.5 ) --> 2.50, 3, 3.50 ...

function _count() {
	var _iter = new Iterator( ( argument_count > 0 ) ? argument[ 0 ] : 0, function() {
		var _result = data;
		data += step;
		return _result;
	}, function() {
		return false;	
	});
	
	_iter.step = argument_count > 1 ? argument[ 1 ] : 1;

	return _iter;
}

/// @func _cycle
///
/// @desc Make an iterator returning elements from the iterable and saving a copy of each. When the iterable is exhausted, return elements from the saved copy. Repeats indefinitely.
///
/// @arg {Iterable} iterable
///
/// @return {Iterator} Yields elements of the input iterable cycled.
///
/// @example
/// _cycle( [ 1, 2, 3, 4 ] ) --> 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, ...

function _cycle( _iterable ) {
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

/// @func _drop
///
/// @desc Helper function for partially exhausting a long or infinite iterable
/// @see _take
///
/// @arg {Number} n
/// @arg {Iterable} iterable
///
/// @return {Iterator} Yield elements from input iterable starting from n.
///
/// @example
/// _drop( 2, "abcdef" ) --> "b", "c", "d", "e", "f"

function _drop( _n, _iterable ) {
	return _islice( _iterable, _n, undefined );	
}

/// @func _dropwhile
/// 
/// @desc Returns elements from iterable starting from the element for which predicate is false
/// @see _takewhile
///
/// @arg {Iterable} iterable
/// @arg {Method} [predicate]
///
/// @return {Iterator} Yields elements input iterable starting from the element for which predicate is false.
///
/// @example
/// _dropwhile( [ 1, 4, 6, 4, 1 ], function( x ) { return x < 5 } ) --> 6, 4, 1

function _dropwhile( _iterable, _predicate ) {
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

/// @func _enumerate
///
/// @desc Returns [ count, element ] for each element from iterable
///
/// @arg {Iterable} iterable
/// @arg {Number} [start=0]
///
/// @return {Iterator} Yields array with count and the next value from input iterable.
///
/// @example
/// seasons = [ "Spring", "Summer", "Fall", "Winter" ];
///_enumerate( seasons ) --> [ 0, "Spring" ], [ 1, "Summer" ], [ 2, "Fall" ], [ 3, "Winter" ]
///_enumerate( seasons, 1 ) --> [ 1, "Spring" ], [ 2, "Summer" ], [ 3, "Fall" ], [ 4, "Winter" ]

 function _enumerate( _iterable ) {
	return _zip( _count( ( argument_count > 1 ) ? argument[ 1 ] : 0 ), iter( _iterable ) );
}

/// @func _filter
///
/// @desc Construct an iterator from those elements of iterable for which function returns true.
/// @see _filter_false
///
/// @arg {Iterable} iterable
/// @arg {Method(e)} [function]
///
/// @return {Iterator} Yields elements from iterable for which function returns true.
///
/// @example
/// _filter( _range( 10 ), function( x ) { return x % 2 } ) --> 1, 3, 5, 7, 9

function _filter( _iterable ) {
	var _function = ( argument_count > 1 ) ? argument[ 1 ] : _truth;
	
	return iter( _iterable ).filter( _function );
}

/// @func _filter_false
///
/// @desc Construct an iterator from those elements of iterable for which function returns false.
/// @see _filter
///
/// @arg {Iterable} iterable
/// @arg {Method} [function]
///
/// @@return {Iterator} Yields elements from iterable for which function returns false.
///
/// @example
/// _filter_false( _range( 10 ), function( x ) { return x % 2 } ) --> 0, 2, 4, 6, 8

function _filter_false( _iterable ) {
	var _function = ( argument_count > 1 ) ? argument[ 1 ] : _truth;
	
	return iter( _iterable ).filter_false( _function );
}

/// @func _group_by
///
/// @desc Make an iterator that returns consecutive keys and groups from the iterable.
///
/// @arg {Iterable} iterable
/// @arg {Method} [key] Function computing a key value for each element. If not specified or is undefined, key defaults to an identity function and returns the element unchanged.
/// Generally, the iterable needs to already be sorted on the same key function.
///
/// @return {Iterator} Yields struct with key and array group for each group.
///
/// @example
/// _take( 2, _group_by( "AAAABBBCCDAABBB" ) ) --> { key: "A", group: [ "A", "A", "A", "A" ] }, { key: "B", group: [ "B", "B", "B" ] }

function _group_by( _iterable ) {
	var _key_func = ( argument_count > 1 ) ? argument[ 1 ] : _identity;
	
	return iter( _iterable ).group_by( _key_func );
}

/// @func _imap
///
/// @desc Return an iterator that applies function to every item of iterable, yielding the results. If additional iterable arguments are passed, function must take that many arguments and is applied to the items from all iterables in parallel. With multiple iterables, the iterator stops when the shortest iterable is exhausted.
/// @see _imap_from_iterable
///
/// @arg {Method} function
/// @arg {Iterable} [...]
///
/// @return {Iterator} Yields result of passing an emement of every argument into a function.
///
/// @example
/// _imap( function( x, n ) { return power( x, n ) }, [ 2, 3, 10 ], [ 5, 2, 3 ] ) --> 32, 9, 1000

function _imap( _function ) {
	var _iter = new Iterator( [ ], function() {
		var a = [];
		
		for ( var i = 0; i < size; i++ ) {
			a[i] = data[i].next();	
		}
		
		return apply( func, a );
	}, function( ) {
		for ( var i = 0; i < size; i++ ) {
			if ( data[ i ].is_done() ) {
				return true;	
			}
		}
		return false;
	} );
	
	_iter.func = is_method( _function ) ? _function : method( undefined, _function );
	_iter.size = argument_count - 1;
	
	for( var i = 0; i < _iter.size; i++ ) {
		_iter.data[ i ] = iter( argument[ i + 1 ] );
	}
	
	return _iter;
}

/// @func _imap_from_iterable
///
/// @desc Make an iterator that computes the function using arguments obtained from the iterable. Used instead of map() when argument parameters are already grouped in arrays from a single iterable ( the data has been “pre-zipped” ).
///
/// @arg {Method} function
/// @arg {Iterable} iterable
///
/// @return {Iterator} Yields result of passing every emement from iterable into the function.
///
/// @example
/// _imap_from_iterable( function( x, n ) { return power( x, n ) }, [ [ 2, 5 ], [ 3, 2 ], [ 10, 5 ] ] ) --> 32, 9, 1000

function _imap_from_iterable( _function, _iterable ) {
	var _iter = new Iterator( iter( _iterable ), function() {
		
		var a = data.next();
		if ( is_undefined( size ) ) {
			size = array_length( a );
		}
		
		return apply( func, a );
	}, function( ) {
		return data.is_done();
	} );
	
	_iter.func = _function;
	_iter.size = undefined;
	
	return _iter;
}

/// @func _islice
///
/// @desc Make an iterator that returns selected elements from the iterable. If start is non-zero, then elements from the iterable are skipped until start is reached. Afterward, elements are returned consecutively unless step is set higher than one which results in items being skipped. If stop is undefined, then iteration continues until the iterator is exhausted, if at all; otherwise, it stops at the specified position.
///
/// @arg {Iterable} iterable
/// @arg {Number} [start=0]
/// @arg {Number} stop
/// @arg {Number} [step=1]
///
/// @return {Iterator} Yields only elements from range.
///
/// @example
/// _islice( "ABCDEFG", 2 ) --> "A", "B"
///_islice( "ABCDEFG", 2, 4 ) --> "C", "D"
///_islice( "ABCDEFG", 2, undefined ) --> "C", "D", "E", "F", "G"
///_islice( "ABCDEFG", 0, undefined, 2 ) --> "A", "C", "E", "G"

function _islice( _iterable, _stop ) {
	var _start = argument_count > 2 ? _stop : 0;
	var _step = argument_count > 3 ? argument[ 3 ] : 1;
	_stop = argument_count > 2 ? argument[ 2 ] : _stop;
	
	return iter( _iterable ).slice( _start, _stop, _step );
}

/// @func _ndenumerate
///
/// @desc Return an iterator yielding pairs of array coordinates and values.
///
/// @arg {Array} array
///
/// @return {Iterator} Yields pairs of array coordinates and values.
///
/// @example
/// _ndenumerate( [ [ 0, 1 ], [ 2, 3 ] ] ) --> [ [ 0,0 ], 0 ], [ [ 0,1 ], 1 ], [ [ 1,0 ], 2 ], [ [ 1,1 ], 3 ]

function _ndenumerate( _array ) {
	var _iter = new Iterator( array_flat( _array ), function() {
		var k = index;
		var t = [ ];
		for( var i = 0; i <= ndim; i++ ) {
			t[ i ] = k div strides[ i ];
			k %= strides[ i ];
		}
		
		return [ t, data[ index++ ] ];
	}, function() {
		return ( index >= size );
	} );
	
	var _shape = array_shape( _array );
	_iter.ndim = array_length( _shape ) - 1;
	_iter.index = 0;
	_iter.size = array_length( _iter.data );
	
	var _stride = 1;
	_iter.strides[ _iter.ndim ] = 1;
	
	for ( var i = _iter.ndim - 1; i >= 0; i-- ) {
		_stride *= _shape[ i ];
		_iter.strides[ i ] = _stride;
	}
	
	return _iter;
}

/// @func _repeat
///
/// @desc Iterator that returns object over and over again.
///
/// @arg {Any} object
/// @arg {Number} [n] If specified, iterator executes this amount of times.
///
/// @return {Iterator} Yields object n times.
///
/// @example
/// _repeat( 10, 3 ) --> 10, 10, 10
///_repeat( 10 ) --> 10, 10, 10, 10, 10, ...
///
/// @example
/// _imap( function( x, n ) { return power(n) }, _range( 10 ), _repeat( 2 ) ).to_array()
///--> [ 0, 1, 4, 9, 16, 25, 36, 49, 64, 81 ]

function _repeat( _object ) {
	var _iter = new Iterator( _object, function() {
		--n;
		return data;
	}, function() {
		return ( n <= 0 );	
	});
	
	_iter.n = ( argument_count > 1 ) ? argument[ 1 ] : infinity;
		
	return _iter;
}

/// @func _take
///
/// @desc Helper function for partially consuming a long or infinite iterable
/// @see _drop
///
/// @arg {Number} n
/// @arg {Iterable} iterable
///
/// @return {Iterator} Yields next n elements from iterable.
///
/// @example
/// _take( 5, _count() ) --> 0, 1, 2, 3, 4
///_take( 7, _repeat( [ 1, 2, 3 ] ) --> 1, 2, 3, 1, 2, 3, 1

function _take( _n, _iterable ) {
	return _islice( _iterable, _n );
}

/// @func _takewhile
///
/// @desc Make an iterator that returns elements from the iterable as long as the predicate is true.
/// @see _dropwhile
///
/// @arg {Iterable} iterable
/// @arg {Method} predicate
///
/// @return {Iterator} Yields elements from iterable
///
/// @example
/// _takewhile( [ 1, 4, 6, 4, 1 ], function( x ) { return x < 5 } ) --> 1, 4

function _takewhile( _iterable, _predicate ) {
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

/// @func _zip
///
/// @desc Iterator that aggregates elements from each of the iterables until one of them is exhausted.
/// @see _zip_longest
///
/// @arg {Iterable} [...]
///
/// @return {Iterator} Yields an array with elements of every iterable.
///
/// @example
/// _zip( "ABCD", "xy" ) --> [ "A", "x" ], [ "B", "y" ]

function _zip() {
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

/// @func _zip_longest
///
/// @desc Iterator that aggregates elements from each of the iterables until all of them are exhausted.
/// @see _zip
///
/// @arg {Iterable} [...]
/// @arg {Any} fill_value
///
/// @return {Iterator} Yields an array with elements of every iterable.
///
/// @example
/// _zip_longest( "ABCD", "xy", "-" ) --> [ "A", "x" ], [ "B", "y" ], [ "C", "-" ], [ "D", "-" ]

function _zip_longest() {
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

#region combinatoric

/// @func _combinations
///
/// @desc Iterator that yields r length subsequences of elements from the input iterable.
/// Elements are treated as unique based on their position, not on their value. So if the input elements are unique, there will be no repeat values in each combination.
///
/// @arg {Iterable} iterable
/// @arg {Number} [r]
///
/// @return {Iterator}
///
/// @example
/// _combinations( [ 0, 1, 2, 3 ], 3 ) --> [ 0, 1, 2 ], [ 0, 1, 3 ], [ 0, 2, 3 ], [ 1, 2, 3 ]

function _combinations( _iterable ) {
	var r = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	
	return iter( _iterable ).combinations( r );
}

/// @func _combinations_with_replacements
///
/// @desc Make an iterator that yields r length subsequences of the iterable allowing individual elements to be repeated more than once.
///
/// @arg {Iterable} iterable
/// @arg {Number} [r]
///
/// @return {Iterator}
///
/// @example
/// _irange( 3 ).combinations_with_replacements( 2 ) --> [ 0, 0 ], [ 0, 1 ], [ 0, 2 ], [ 1, 1 ], [ 1, 2 ], [ 2, 2 ]

function _combinations_with_replacements( _iterable ) {
	var r = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	
	return iter( _iterable ).combinations_with_replacements( r );
}

/// @func _permutations
///
/// @desc Iterator that yields subsequent r-length permutations of input iterable items.
///
/// @arg {Iterable} iterable
/// @arg {Number} [r]
///
/// @return {Iterator}
///
/// @example
/// _permutations( [ 0, 1, 2 ], 2 ) -->  [ 0,1 ],[ 0,2 ],[ 1,0 ],[ 1,2 ],[ 2,0 ],[ 2,1 ]

function _permutations( _iterable ) {
	var r = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	
	return iter( _iterable ).permutations( r );
}

/// @func _product
///
/// @desc Cartesian product of input iterables
///
/// @arg {Iterable} ...
/// @arg {Number} [repeat] if supplied, computes product of single iterable with itself
///
/// @return {Iterator} Yields array with elements of each iterable
///
/// @example
/// _product( [ 0, 1 ], "ab" ) --> [ 0, "a" ], [ 0, "b" ], [ 1, "a" ], [ 1, "b" ]
///_product( [ 0, 1 ], 2 ) --> [ 0, 0 ], [ 0, 1 ], [ 1, 0 ], [ 1, 1 ]

function _product( ) {
	if ( ( argument_count == 2 ) && ( is_real( argument[ 1 ] ) ) ) {
		return iter( argument[ 0 ] ).product( argument[ 1 ] );
	}
	
	var _iter = new Iterator( [ ], function() {
		var _result = [ ];
		
		for( var i = 0; i < size; i++ ) {
			_result[ i ] = buffer[ i ][ index[ i ] ];
		}
		
		++index[ size - 1 ];
		
		return _result;
	}, function() {
		for( var i = size - 1; i >= 0; i-- ) {
			if ( index[ i ] >= array_length( buffer[ i ] ) ) {
				if ( data[ i ].is_done() ) {
					if ( i > 0 ) {
						index[ i ] = 0;
						++index[ i - 1 ];
					} else {
						size = 0;
					}
				} else {
					buffer[ i ][ index[ i ] ] = data[ i ].next();
				}
			} else {
				return false;
			}
		}
		
		return ( size == 0 );
	});
	
	_iter.size = argument_count;
	_iter.buffer = [ ];
	_iter.index = [ ];
	var _empty = 1;
	
	for( var i = 0; i < argument_count; i++ ) {
		_iter.data[ i ] = iter( argument[ i ] );
		if ( _iter.data[ i ].is_done() ) {
			++_empty;
		}
		_iter.buffer[ i ] = [ ];
		_iter.index[ i ] = 0;
	}
	
	if ( _empty >= _iter.size ) {
		_iter.size = 0;
	}
	
	return _iter;
}

#endregion

#region misc

/// @func _all
///
/// @desc Return True if all elements of the iterable are true (or if the iterable is empty).
///
/// @arg {Iterable} iterable
///
/// @return {Bool}

function _all( _iterable ) {
	_iterable = iter( _iterable );
	
	while( !_iterable.is_done() ) {
		if ( !_iterable.next() ) {
			return false;	
		}
	}
	
	return true;
}


/// @func _any
///
/// @desc Return true if any element of the iterable is true. If the iterable is empty, return false. 
///
/// @arg {Iterable} iterable
///
/// @return {Bool}

function _any( _iterable ) {
	_iterable = iter( _iterable );
	
	while( !_iterable.is_done() ) {
		if ( _iterable.next() ) {
			return true;	
		}
	}
	
	return false;
}

/// @func _reduce
///
/// @desc Apply function of two arguments cumulatively to the items of Iterable, from left to right, so as to reduce it to a single value.
/// @see _accumulate
///
/// @arg {Iterable} iterable
/// @arg {Method(a,x)} function
/// @arg [Any] initializer
///
/// @return {Any}
///
/// @example
/// _reduce( [1, 2, 3, 4], max ) --> 4

function _reduce( _iterable, _function ) {
	if ( argument_count > 2 ) {
		return iter( _iterable ).reduce( _function, argument[ 2 ] );
	}
	return iter( _iterable ).reduce( _function );
}

/// @func _sorted
///
/// @desc Returns Iterator that yields items from iterable in sorted order
///
/// @arg {Iterable} iterable
/// @arg {Method} [key=undefined]
/// @arg {Bool} [_reverse=false]
///
/// @return {Iterator}
///
/// @example
/// _sorted( [ 5, 2, 3, 1, 4 ] ) --> 1, 2, 3, 4, 5
/// _sorted( "ebcad" ).to_string() --> "abcde"

function _sorted( _iterable ) {
	var _key = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	var _reverse = ( argument_count > 2 ) ? argument[ 2 ] : false;
	
	return iter( _iterable ).sorted( _key, _reverse );
}

/// @func _unique
///
/// @desc returns Iterator that yields the non-repeating items from iterable sorted by key
///
/// @arg {Iterable} iterable
/// @arg {Method} [key]
///
/// @return {Iterator}

function _unique( _iterable ) {
	var _key = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	return iter( _iterable ).unique( _key );
}

#endregion
