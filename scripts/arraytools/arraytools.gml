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
/// @arg {...} items
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

/// @func array_map
///
/// @desc Applies function to every item of input aray
///
/// @arg {Array} array
/// @arg {Method} func

function array_map( a, func ) {
	var _size = array_length( a );
	var _result = [ ];
	
	for( var i = 0; i < _size; i++ ) {
		_result[ i ] = func( a[ i ] );
	}
	
	return _result;
}

#endregion

#region sorting

/// @func array_sort
///
/// @desc quicksort array
///
/// @arg {Array} array
/// @arg {Method} [key]
///
/// @return {Array} Input array but sorted using quicksort algorithm

function array_sort( a ) {
	var key = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	return array_qsort( a, key );
}

/// @func array_qsort
///
/// @desc quicksort array
///
/// @arg {Array} array
/// @arg {Method} [key]
///
/// @return {Array} Input array but sorted using quicksort algorithm

function array_qsort( a ) {
	var key = ( argument_count > 1 ) ? argument[ 1 ] : undefined;
	var _keys = is_array( key ) ? key : ( is_undefined( key ) ? a : array_map( a, key ) );
	log( "keys: ", _keys );
	
	var _left = ( argument_count > 2 ) ? argument[ 2 ] : 0;
	var _right = ( argument_count > 3 ) ? argument[ 3 ] : array_length( a ) - 1;
	
	if ( _left < _right ) {
		do {
			if ( ( _right - _left ) == 1 ) {
				if ( _keys[ _left ] > _keys[ _right ] ) {
					array_swap( a, _left, _right );
					if ( key ) {
						array_swap( _keys, _left, _right );
					}
				}
				break;
			}
			
			var i = _left;
			var j = _right;
			var p = ( i + j ) >> 1;
			
			do {
				while ( _keys[ i ] < _keys[ p ] ) {
					++i;	
				}
				while ( _keys[ j ] > _keys[ p ] ) {
					--j;	
				}
				if ( i <= j ) {
					if( i != j ) {
						array_swap( a, i, j );
						array_swap( _keys, i, j );
					}
					if ( p == i ) {
						p = j;	
					} else if ( p ==j ) {
						p = i;	
					}
					++i;
					--j;
				}
			} until ( i > j );
			
			if ( ( j - _left ) > ( _right - i ) ) {
				if ( i < _right ) {
					array_qsort( a, _keys, i, _right );	
				}
				_right = j;
			} else {
				if( _left < j ) {
					array_qsort( a, _keys, _left, j );
				}
				_left = i;
			}	
		} until ( _left >= _right );
	}

	return a;
}

#endregion