#region Array

/// @func Array( dimensions )
/// @name Array
/// @class
///
/// @classdesc Multi-dimensional array
///
/// @arg {Array} object
/// @arg {Number} [ndmin=0] minimum number of dimensions 
/// @arg {Bool} [c_order=true] the memory layout of the array. If true, layout is row major.
///
/// @return {Array} - Array struct

function Array( _object ) constructor {
	/// @field data
	/// @memberof Array
	///
	/// @desc 1d array as buffer
	data = _object;
	
	/// @field shape
	/// @memberof Array
	///
	/// @desc Size of Array in every dimension
	shape = [];
	
	/// @field ndim
	/// @memberof Array
	///
	/// @desc Number of array dimensions.
	///
	/// @return {Number}
	
	if ( argument_count > 1 ) {
		ndim = argument[ 1 ];
		for( var i = 0;	i < ndim; i++ ) {
			shape[ i ] = 0;
		}
	} else {
		ndim = 0;
	}
	
	/// @field strides
	/// @memberof Array
	///
	/// @desc Size of array dimensions cached.
	strides = [];
	
	/// @field c_order
	/// @memberof Array
	///
	/// @desc Dimensions order. True means row-first, false is row-last.
	c_order = ( argument_count > 2 ) ? argument[ 2 ] : true;
		
	/// @method get
	/// @memberof Array
	///
	/// @arg {Number} index0
	/// @arg {Number} index1
	/// @arg ...
	///
	/// @desc Returns array element
	///
	/// @return {Any}
	
	static get = function() {
		var _c = [];
		if ( ( argument_count == 1 ) && is_array( argument[ 0 ] ) ) {
			_c = argument[ 0 ];	
		} else {
			for( var i = 0; i < argument_count; i++ ) {
				_c[ i ] = argument[ i ];
			}
		}
		var _n = 0;
		for( var i = 0; i < ndim; i++ ) {
			_n += _c[ i ] * strides[ i ];
		}
		return data[ _n ];
	}
	
	/// @method set
	/// @memberof Array
	///
	/// @arg {Any} value
	/// @arg {Number} index0
	/// @arg {Number} index1
	/// @arg ...
	///
	/// @desc Writes new value at position index.
	
	static set = function( _value ) {
		var _c = [];
		if ( ( argument_count == 1 ) && is_array( argument[ 0 ] ) ) {
			_c = argument[ 0 ];	
		} else {
			for( var i = 0; i < argument_count; i++ ) {
				_c[ i ] = argument[ i ];
			};
		}
		var _n = 0;
		for( var i = 0; i < ndim; i++ ) {
			_n += _c[ i ] * stride[ i ];
		}
		return data[ _n ] = _value;
	}
	
}

#endregion

#region array

/// @func array_append
///
/// @desc Add items to the end of the array
///
/// @arg {Array} array
/// @arg ... items
///
/// @example
/// var a = [ 1, 2, 3 ];
///array_append( a, 4, 5 );
///a --> [ 1, 2, 3, 4, 5 ];

function array_append( _array ) {
	var n = array_length( _array );
	for( var i = 1; i < argument_count; i++ ) {
		_array[@ n++ ] = argument[ i ];
	}
	
	return _array;
}

/// @func array_clear
///
/// @desc Remove all elements from the array.
///
/// @arg {Array} array
///
/// @example
/// var a = [ 1, 2, 3 ];
///array_clear( a );
///a --> [  ];

function array_clear( _array ) {
	array_resize( _array, 0 );
	
	return _array;
}

/// @func array_clone
///
/// @desc Returns copy of the input array.
///
/// @arg {Array} array

function array_clone( _array ) {
	var _result = [ ];
	array_copy( _result, 0, _array, 0, array_length( _array ) );
	return _result;
}

/// @func array_count
///
/// @desc Return the number of times x appears in the list.
///
/// @arg {Array} array
/// @arg {Any} value
///
/// @return {Number}
///
/// @example
/// array_count( [ 2, 3, 4, 3, 10, 3, 5, 6, 3 ], 3 ) --> 4

function array_count( _array, _value ) {
	var n = array_length( _array );
	var _result = 0;
	
	for( var i = 0; i < n; i++ ) {
		if ( _array[ i ] == _value ) {
			++_result;
		}
	}
	
	return _result;
}

/// @func array_delete
///
/// @desc Removes element with specified index from the array
///
/// @arg {Array} array
/// @arg {Number} index

function array_delete( _array, _index ) {
	var n = array_length( _array );
	_index = ( _index < 0 ) ? _index + n : _index;
	
	while ( ++_index < n ) {
		_array[@ _index - 1 ] = _array[ _index ];
	}
	
	array_resize( _array, n - 1 );
	
	return _array;
}

/// @func array_extend
///
/// @desc Extend the array by appending all the items from the iterable.
///
/// @arg {Array} array
/// @arg {Iterable} iterable
///
/// @example
/// var a = [ 1, 2, 3 ];
///array_extend( a, [ 4, 5 ] );
///a --> [ 1, 2, 3, 4, 5 ];

function array_extend( _array, _iterable ) {
	var n = array_length( _array );
	var _data = iter( _iterable );
	
	while ( !_data.is_done() ) {
		_array[@ n++ ] = _data.next();
	}
	
	return _array;
}

/// @func array_index
///
/// @desc Return zero-based index in the list of the first item whose value is equal to given value. Returns undefined if no such item.
///
/// @arg {Array} array
/// @arg {Any} value
/// @arg {Number} [start=0]
/// @arg {Number} [stop=infinity]
///
/// @return {Number}
///
/// @example
/// array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4 ) --> 3
///array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, 4 ) --> 7
///array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, 4, 6 ) --> undefined

function array_index( _array, _value ) {
	var n = array_length( _array );
	var _start = ( argument_count > 2 ) ? argument[ 2 ] : undefined;
	_start = is_undefined( _start ) ? 0 : ( ( _start < 0 ) ? _start + n : _start );
	var _stop = ( argument_count > 3 ) ? argument[ 3 ] : undefined;
	_stop = clamp( is_undefined( _stop ) ? n : ( ( _stop < 0 ) ? _stop + n : _stop ), 0, n );
	
	while ( _start < _stop ) {
		if ( _array[ _start ] == _value ) {
			return _start;
		}
		++_start;
	}
	
	return undefined;
}

/// @func array_insert
///
/// @desc Insert an item at a given position.
///
/// @arg {Array} array
/// @arg {Number} index Index of the element before which to insert the new value.
/// @arg {Any} value
///
/// @example
/// var a = [ 1, 2, 4, 6 ];
///array_insert( a, 2, 3 );
///a --> [ 1, 2, 3, 4, 6 ];
///array_insert( a, -1, 5 );
///a --> [ 1, 2, 3, 4, 5, 6 ];

function array_insert( _array, _index, _value ) {
	var n = array_length( _array );
	_index = ( _index < 0 ) ? _index + n : _index;
	
	if ( _index < n ) {
		array_copy( _array, _index + 1, _array, _index, n - _index );
	}
	
	_array[@ _index ] = _value;
	
	return _array;
}

/// @func array_map
///
/// @desc Applies function to every item of input aray
///
/// @arg {Array} array
/// @arg {Method} func

function array_map( a, func ) {
	var n = array_length( a );
	var _result = [ ];
	
	for( var i = 0; i < n; i++ ) {
		_result[ i ] = func( a[ i ] );
	}
	
	return _result;
}

/// @func array_pop
///
/// @desc Remove the item at the given position in the array, and return it.
///
/// @arg {Array} array
/// @arg {Number} [index=-1]

function array_pop( _array ) {
	var _index = ( argument_count > 1 ) ? argument[ 1 ] : -1;
	var n = array_length( _array );
	_index = ( _index < 0 ) ? _index + n : _index;
	
	var _result = _array[ _index ];
	
	while ( ++_index < n ) {
		_array[@ _index - 1 ] = _array[ _index ];
	}
	
	array_resize( _array, n - 1 );
	
	return _result;
}

/// @func array_remove
///
/// @desc
///
/// @arg {Array} array
/// @arg {Any} value

function array_remove( _array, _value ) {
	var _index = array_index( _array, _value );
	if ( !is_undefined( _index ) ) {
		array_delete( _array, _index );
	}
	
	return _array;
}

/// @func array_reverse
///
/// @desc Reverse the elements of the array in place
///
/// @arg {Array} array
///
/// @example
/// var a = [ 1, 2, 3, 4, 5 ];
///array_reverse( a );
///a --> [ 5, 4, 3, 2, 1 ];

function array_reverse( _array ) {
	var n = array_length( _array );
	var m = n div 2;
	
	for( var i = 0; i < m; i++ ) {
		array_swap( _array, i, n - i  - 1 );
	}
	
	return _array;
}

/// @func array_slice
///
/// @desc Return part of the array.
///
/// @arg {Array} array
/// @arg {Number} [start=0]
/// @arg {Number} [stop=infinity]
/// @arg {Number} [step=1]
///
/// @return {Array}

function array_slice( _array ) {
	var n = array_length( _array );
	var _start = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	_start = is_undefined( _start ) ? 0 : ( ( _start < 0 ) ? _start + n : _start );
	var _stop = ( argument_count > 2 ) ? argument[ 2 ] : undefined;
	_stop = is_undefined( _stop ) ? n : ( ( _stop < 0 ) ? _stop + n : _stop );
	var _step = ( argument_count > 3 ) ? argument[ 3 ] : undefined;
	_step = is_undefined( _step ) ? 1 : _step;
	
	if ( _step < 0 ) {
		var t = _stop + _mod( _start - _stop, _step );
		_stop = _start + sign( _step );
		_start = t + sign( _step );
	}
	
	var _result = [ ];
	var _size = 0;
	
	while( ( ( _start - _stop ) / _step ) < 0 ) {
		_result[ _size++ ] = _array[ _start ];
		_start += _step;
	}
	
	return _result;
}

/// @func array_swap
///
/// @desc swaps two array elements
///
/// @arg {Array} array
/// @arg {Number} a first element index
/// @arg {Number} b second element index
///
/// @example
/// var a = [ 1, 2, 3, 4, 5 ];
///array_swap( 1, 3 );
///a --> [ 1, 4, 3, 2, 5 ];

function array_swap( _array, a, b ) {
	var _t = _array[ a ];
	_array[@ a ] = _array[ b ];
	_array[@ b ] = _t;
}

#endregion

#region sorting

/// @func array_sort
///
/// @desc quicksort array
///
/// @arg {Array} array
/// @arg {Method} [key=undefined]
/// @arg {Bool} [reverse=false]
///
/// @return {Array} Input array but sorted using quicksort algorithm

function array_sort( a ) {
	if ( array_length( a ) < 2 ) {
		return a;	
	}
	var _key = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	var _reverse = ( argument_count > 2 ) ? argument[ 2 ] : false;
	return array_qsort( a, _key, _reverse );
}

/// @func array_qsort
///
/// @desc quicksort array using Hoare partitioning
///
/// @arg {Array} array
/// @arg {Method} [key=undefined]
/// @arg {Bool} [reverse=false]
///
/// @return {Array} Input array but sorted using quicksort algorithm

function array_qsort( a ) {
	var _key = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	var _reverse = ( argument_count > 2 ) ? argument[ 2 ] : false;
	var _keys = is_array( _key ) ? _key : ( is_undefined( _key ) ? a : array_map( a, _key ) );
	
	var _left = ( argument_count > 3 ) ? argument[ 3 ] : 0;
	var _right = ( argument_count > 4 ) ? argument[ 4 ] : array_length( a ) - 1;
	
	if ( _left < _right ) {
		do {
			if ( ( _right - _left ) == 1 ) {
				if ( _reverse ? _keys[ _left ] < _keys[ _right ] : _keys[ _left ] > _keys[ _right ] ) {
					array_swap( a, _left, _right );
					if ( _key ) {
						array_swap( _keys, _left, _right );
					}
				}
				break;
			}
			
			var i = _left;
			var j = _right;
			var p = ( i + j ) >> 1;
			
			do {
				if ( _reverse ) {
					while ( _keys[ i ] > _keys[ p ] ) {
						++i;
					}
					while ( _keys[ j ] < _keys[ p ] ) {
						--j;
					}
				} else {
					while ( _keys[ i ] < _keys[ p ] ) {
						++i;
					}
					while ( _keys[ j ] > _keys[ p ] ) {
						--j;
					}
				}
				
				if ( i <= j ) {
					if( i != j ) {
						array_swap( a, i, j );
						if ( _key ) {
							array_swap( _keys, i, j );
						}
					}
					if ( p == i ) {
						p = j;
					} else if ( p == j ) {
						p = i;
					}
					++i;
					--j;
				}
			} until ( i > j );
			
			if ( ( j - _left ) > ( _right - i ) ) {
				if ( i < _right ) {
					array_qsort( a, _key ? _keys : _key, _reverse, i, _right );
				}
				_right = j;
			} else {
				if( _left < j ) {
					array_qsort( a, _key ? _keys : _key, _reverse, _left, j );
				}
				_left = i;
			}	
		} until ( _left >= _right );
	}

	return a;
}

#endregion