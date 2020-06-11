/// @func array_swap
///
/// @desc swaps two array elements
///
/// @arg {Array} array
/// @arg {Number} a
/// @arg {Number} b

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
					array_swap( _keys, _left, _right );
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

