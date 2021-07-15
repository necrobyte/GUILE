#region const

/// @constant {Number} TWOPI
/// @desc Also known as global.tau
/// @default 2*pi

global.tau = 2 * pi;
#macro TWOPI global.tau

/// @constant {Number} NV_MAGICCONST
/// @desc Also known as global.nv_magicconst. Used in normal variate random distribution.
/// @default 4 * exp( -0.5 ) / sqrt( 2.0 )

global.nv_magicconst = 4 * exp( -0.5 ) / sqrt( 2.0 )
#macro NV_MAGICCONST global.nv_magicconst

/// @constant {Number} SMALL_FACTORIALS
/// @desc Also known as global.small_factorials. Lookup table for int64 factorial values.
/// @default [0!..20!]

global.small_factorials = [ 1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 
		3628800, 39916800, 479001600, 6227020800, 87178291200, 1307674368000, 
		20922789888000, 355687428096000, 6402373705728000, 121645100408832000, 2432902008176640000 ];
#macro SMALL_FACTORIALS global.small_factorials

#endregion

#region test

/// @func assert
///
/// @desc Asserts that a condition is true. If it isn't it throws an error with the given message.
///
/// @arg {Bool} condidion
/// @arg {String} message

function assert( _condition, _message ) {
	if ( !_condition ) {
		show_error( _message, true );		
	}
}

/// @func assert_equals
///
/// @desc Asserts that two arguments are equal. If they are not, an error is thrown with the given message. 
///
/// @arg {Any} expected
/// @arg {Any} actuals
/// @arg {String} [message]

function assert_equals( _expected, _actual, _message ) {
	_message = is_undefined( _message ) ? "" : _message;
	if ( typeof( _expected ) == "array" ) {
		assert( array_equals( _expected, _actual ), _message );	
	} else {
		assert( _expected == _actual, _message );
	}
}

/// @func assert_array_equals
///
/// @desc Asserts that two arguments are equal. If they are not, an error is thrown with the given message. 
///
/// @arg {Array} expected
/// @arg {Array} actuals
/// @arg {String} [message]

function assert_array_equals( _expected, _actual, _message ) {
	_message = is_undefined( _message ) ? "" : _message;
	var _size = array_length( _expected );
	assert( _size == array_length( _actual ), _message );
	
	for ( var i = 0; i < _size; i++ ) {
		var _item = _expected[ i ];
		if ( typeof( _item ) == "array" ) {
			assert_array_equals(  _item, _actual[ i ], _message );
		} else {
			assert( _item == _actual[ i ], _message );
		}
	}
}

#endregion

#region data_structues

/// @function _list
/// @desc returns ds_list
/// @arg [...]

function _list( ) {
	var _ds = ds_list_create();
	var _n = argument_count;
	
	for (var i = 0; i < _n; i++ ) {
		_ds[| i ] = argument[ i ];
	}
	
	return _ds;
}

/// @function _stack
/// @desc returns ds_stack
/// @arg [...]

function _stack( ) {
	var _ds = ds_stack_create();
	var _n = argument_count;
	
	for (var i = 0; i < _n; i++ ) {
		ds_stack_push( _ds, argument[ i ] );
	}
	
	return _ds;
}

/// @function _queue
/// @desc returns ds_queue
/// @arg [...]

function _queue( ) {
	var _ds = ds_queue_create();
	var _n = argument_count;
	
	for (var i = 0; i < _n; i++ ) {
		ds_queue_enqueue( _ds, argument[ i ] );
	}
	
	return _ds;
}

/// @function _map
/// @desc returns ds_map
/// @arg {array} [...] key, value pairs

function _map( ) {
	var _ds = ds_map_create();
	var _n = argument_count;
	
	for (var i = 0; i < _n; i++ ) {
		var _t = argument[ i ];
		ds_map_add( _ds, _t[ 0 ], _t[ 1 ] );
	}
	
	return _ds;
}

/// @function _priority
/// @desc returns ds_priority
/// @arg {array} [...] value, priority pairs

function _priority( ) {
	var _ds = ds_priority_create();
	var _n = argument_count;
	
	for (var i = 0; i < _n; i++ ) {
		var _t = argument[ i ];
		ds_priority_add( _ds, _t[ 0 ], _t[ 1 ] );
	}
	
	return _ds;
}

/// @func StructMap()
/// @name StructMap
/// @class
///
/// @classdesc Map-like data structure
///
/// @return {StructMap} - StructMap struct

function StructMap() constructor {
	/// @member {Struct} data
	/// @memberof StructMap
	///
	/// @desc Key-value pairs
	data = { };
	
	/// @member {Number} size
	/// @memberof StructMap
	///
	/// @desc Amount of defined entries.
	size = 0;
	
	static __iter = function() {
		var _iter = __iter_dict( data, function() {
			var _result = cache;
			cache = undefined;
			++index;
			return _result;
		}, function( _key ) {
			return variable_struct_get( data, _key );
		}, function() {
			while ( ( index < size ) && is_undefined( cache ) ) {
				cache = keys[ index ];
				if ( is_undefined( get( cache ) ) ) {
					cache = undefined;
					++index;
				}
			}
			
			return index >= size;
		} );
	
		_iter.keys = variable_struct_get_names( data );
		_iter.index = 0;
		_iter.cache = undefined;
		_iter.size = array_length( _iter.keys );

		return _iter;
	}
	
	static add = function( _key, _value ) {
		if ( is_undefined( variable_struct_get( data, _key ) ) ) {
			if ( !is_undefined( _value ) ) {
				++size;
			}
		} else if ( is_undefined( _value ) && ( --size == 0 ) ) {
			clear();
			exit;
		}
		
		variable_struct_set( data, _key, _value );
	}
	
	/// @method clear
	/// @memberof StructMap
	///
	/// @desc Remove all items from StructMap
	
	static clear = function() {
		delete data;
		
		size = 0;
		
		data = { };
	};
	
	/// @method exists
	/// @memberof StructMap
	///
	/// @desc Return true if the specified key exists in StructMap
	///
	/// @arg {Any} key
	///
	/// @return {Bool}
	
	static exists = function( _key ) {
		return !is_undefined( variable_struct_get( data, _key ) );
	};
	
	/// @method find
	/// @memberof StructMap
	///
	/// @desc Returns the first key associated with value. If no such key exists then the function will return undefined.
	///
	/// @arg {Any} value
	/// @arg {Method} [func] function of two arguments to compare Map item with value
	///
	/// @return {Any} key associated with value
	
	static find = function( _value ) {
		var _iter = __iter();
		var _func = ( argument_count > 1 ) ? argument[ 1 ] : _eq;
		
		while( !_iter.is_done() ) {
			var _item = _iter.next();
			if ( _func( _item[ 1 ], _value ) ) {
				return _item[ 0 ];
			}
		}
		
		return undefined;
	}
	
	/// @method get
	/// @memberof StructMap
	///
	/// @desc Returns value associated with the key. If no such key exists then the function will return undefined.
	///
	/// @arg {Any} key
	///
	/// @return {Any}
	
	static get = function( _key ) {
		var _result = data;
		
		for( var i = 0; i < argument_count; i++ ) {
			if ( instanceof( _result ) == "StructMap" ) {
				_result = _result.get( argument[ i ] );
			} else if ( is_struct( _result ) ) {
				_result = variable_struct_get( _result, argument[ i ] );
			} else {
				return undefined;	
			}
		}
		
		return _result;
		
	}
	
	/// @method is_empty
	/// @memberof StructMap
	///
	/// @desc Return false if StructMap has any items, true if it does not.
	///
	/// @return {Bool}
	
	static is_empty = function() {
		return ( size == 0 );
	}
	
	/// @method items
	/// @memberof StructMap
	///
	/// @desc Returns Iterator of key-value pairs
	///
	/// @return {IteratorDict}
	
	static items = function() {
		return __iter();
	}
	
	/// @method keys
	/// @memberof StructMap
	///
	/// @desc Returns Iterator of keys
	///
	/// @return {Iterator}
	
	static keys = function() {
		return __iter().names();
	}
	
	/// @method set
	/// @memberof StructMap
	///
	/// @desc Sets new value associated with key.
	///
	/// @arg {Any} key If key exists, previous value would be overwritten.
	/// @arg {Any} value If undefined, key is removed.
	///
	/// @return {Bool}
	
	static set = add;
	
	/// @method remove
	/// @memberof StructMap
	///
	/// @desc Remove key from the StructMap
	///
	/// @arg {Any} key
	
	static remove = function( _key ) {
		if ( is_undefined( variable_struct_get( data, _key ) ) ) {
			exit;
		}
		
		variable_struct_set( data, _key, undefined );
		
		if ( --size == 0 ) {
			clear();
		}
	}
	
	static to_string = function() {
		var _result = "{ ";
		
		var _iter = __iter();
		var _comma = false;
		
		while( !_iter.is_done() ) {
			var a = _iter.next();
			_result += ( _comma ? ", " : "" ) + a[ 0 ] + " : " + string( a[ 1 ] );
			_comma = true;
		}
		
		delete _iter;
		
		return _result + " }";
	}
}

/// @func UnionFind()
/// @name UnionFind
/// @class
///
/// @classdesc Union-find data structure.
///
/// @arg {Any} ... this structure will be initialized with the discrete partition on the given set of elements.
///
/// @return {UnionFind} - UnionFind struct

function UnionFind( ) constructor {
	elements = new StructMap();
	parents = new StructMap();
	
	var _elements = [ ];
	
	for ( var i = 0; i < argument_count; i++ ) {
		var _element = argument[ i ];
		elements.add( _element, { parent: _element, weight: 1 } );
		parents.add( _element, [ _element ] );
	}
	
	static __iter = function() {
		return elements.keys();	
	}
	
	/// @method get
	/// @memberof UnionFind
	///
	/// @desc Find and return the name of the set containing the object.
	///
	/// @arg {Any} object
	///
	/// @return {String}
	
	static get = function( _object ) {
		var _element = elements.get( _object );
		
		if ( is_undefined( _element ) ) {
			return undefined;	
		}
		
		return _element.parent;
	}
	
	/// @method groups
	/// @memberof UnionFind
	///
	/// @desc Iterates over the sets stored in this structure.
	///
	/// @return {Iterator}
	///
	/// @example
	/// partition = UnionFind( 1, 2, 3 )
	///partition.groups() --> [ 1 ], [ 2 ], [ 3 ]
	///partition.union( 1, 2 )
	///partition.groups() --> [ 1, 2 ], [ 3 ]
	
	static groups = function() {
		return parents.items().values();
	}
	
	/// @method union
	/// @memberof UnionFind
	///
	/// @desc Find the sets containing the objects and merge them all.
	///
	/// @arg {Any} ... objects
	
	static union = function( ) {
		var _objects = [ ];
		
		for( var i = 0; i < argument_count; i++ ) {
			_objects[ i ] = argument[ i ];
		}
		
		var _elements = _imap( function( e ) { 
			var _item = elements.get( e );
			
			if ( is_undefined( _item ) ) {
				_item = { parent: e, weight: 1 };
				elements.add( e, _item );
				parents.add( e, [ e ] );
			}
			
			return [ e, _item.parent, _item.weight ];
		}, _objects ).sorted( function( e ) { return e[ 2 ]; }, true );
		
		if ( _elements.is_done() ) {
			exit;
		}
		
		var _root = _elements.next()[ 1 ];
		var _root_struct = elements.get( _root );
		var _root_parent = parents.get( _root );
		
		while( !_elements.is_done() ) {
			var _element = _elements.next()[ 0 ];
			
			var _element_parent = elements.get( _element ).parent;
			
			if ( _element_parent != _root ) {
				var _parent = parents.get( _element_parent );
				var n = array_length( _parent );
				_root_struct.weight += n;
				array_copy( _root_parent, array_length( _root_parent ), _parent, 0, n );
			
				for( var i = 0; i < n; i++ ) {
					
					var _item = elements.get( _parent[ i ] );
					_item.parent = _root;
					_item.weight = _root_struct.weight;
				}
				
				parents.set( _element_parent, undefined );
			}
		}
		
		parents.set( _root, _root_parent );
	}
}

#endregion

#region misc

/// @func apply
///
/// @desc Executes function with arguments passed as array. Up to 16 arguments supported.
///
/// @arg {Method} function
/// @arg {Array} arguments
///
/// @return {Any} Result returned by function
///
/// @example
/// apply( min, [ 1, 2, 3 ] ) --> 1

function apply( func, a ) {
	var size = array_length( a );
	switch ( size ) {
			case 0: return func( );
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
}

/// @func to_string
///
/// @desc Returs string representation of object
///
/// @arg {Any} object
/// @arg [separator]
///
/// @return {String}

function to_string( _object ) {
	switch typeof( _object ) {
		case "struct":
			if ( variable_struct_exists( _object, "to_string" ) ) {
				var _separator = ( argument_count > 1 ) ? argument[ 1 ] : "";
				return _object.to_string( _separator );
			}
			return string( _object );
			
		default:
			return string( _object );
	}
}

/// @func log
/// @desc Concatenates all arguments and outputs to console using show_debug_message
/// @arg {Any} [...]

function log() {
	var _s = "";

	for ( var i = 0; i < argument_count; i++ ) {
		_s += ( ( i > 0 ) ? " " : "" ) + to_string( argument[ i ] );
	}

	show_debug_message( _s );
}

#endregion

#region operators

/// @func _add
///
/// @desc Add values of two arguments
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} a + b
///
/// @example
/// _add( 2, 2 ) --> 4
///_add( "foo", "bar" ) --> "foobar:

function _add( a, b ) {
	return a + b;
}

/// @func bit_length
///
/// @desc Returns number of bits that are needed to represent a.
///
/// @arg {Number} a
///
/// @return {Number}
///
/// @example
/// bit_length( -37 ) --> 6 // -37 = -0b100101

function bit_length( a ) {
	return floor( log2 ( abs( a ) ) ) + 1;	
}

/// @func _eq
///
/// @desc Returns true if two arguments are equal
///
/// @arg {Any} a
/// @arg {Any} b
///
/// @return {Bool}

function _eq( a, b ) {
	return ( a == b );
}

/// @func factorial
///
/// @desc Return x factorial as an integer.
///
/// @arg {Number} x
///
/// @return {Number}

function factorial( a ) {
	if ( ( a < 0 ) || ( a != floor( a ) ) ) {
		throw "factorial only supports positive integer values";
	}
	
	if ( a < 21 ) {
		return SMALL_FACTORIALS[ a ];	
	}
	
	var num_of_set_bits = function( i ) {
		i = i - ( ( i >> 1 ) & $55555555 );
		i = ( i & $33333333 ) + ( ( i >> 2 ) & $33333333 );
		return ( ( ( i + ( i >> 4 ) & $F0F0F0F ) * $1010101 ) & $ffffffff ) >> 24;
	}
	
	var _inner = 1;
	var _outer = 1;
	var n = bit_length( a );
	
	for ( var i = n; i >= 0; i-- ) {
		_inner *= range_prod( ( ( a >> ( i + 1 ) ) + 1 ) | 1, ( ( a >> i ) + 1 ) | 1, 2 );
		_outer *= _inner;
	}
	
	return 1.0 * _outer << ( a - num_of_set_bits( a ) );
}

/// @func _div
///
/// @desc Divides first argment by the secone one
/// @see _floordiv
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} a / b
///
/// @example
/// _div( 4, 2 ) --> 2

function _div( a, b ) {
	return a / b;
}

/// @func _floordiv
///
/// @desc Divides first argment by the secone one and returns integer part.
/// @see _div
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} a div b
///
/// @example
/// _div( 5, 2 ) --> 2.50
///_floordiv( 5, 2 ) --> 2

function _floordiv( a, b ) {
	return a div b;
}

/// @func _identity
///
/// @desc Function that returns it's argument
///
/// @arg {Any} a
///
/// @return {Any} a
///
/// @example
/// _identity( 10 ) --> 10

function _identity( a ) {
	return a;
}

/// @func is_between
///
/// @desc Check if value is in range [ a, b ]
///
/// @arg {Number} value
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Bool}

function is_between( _value, a, b ) {
	return ( b > a ) ? ( ( _value >= a ) && ( _value <= b ) ) : ( ( _value <= a ) && ( _value >= b ) );
}

/// @func isqrt
///
/// @desc  Return the integer part of the square root of n.
///
/// @arg {Number} n
///
/// @return {Number}
///
/// @example
/// isqrt( 6 ) --> 2

function isqrt( n ) {
	n = floor( n );
	
	if ( n < 0 ) {
		throw "sqrt() argument must be nonnegative";	
	}
	
	if ( n == 0 ) {
		return 0;	
	}
	
	var c = ( bit_length( n ) - 1 ) div 2;
	var a = 1;
	var d = 0
	
	for ( var s = bit_length( c ) - 1; s >= 0; s-- ) {
		var e = d;
		var d = c >> s;
		a = ( a << ( d - e - 1 ) ) + ( n >> ( 2 * c - e - d + 1 ) ) div a;
	}

	return a - bool( a * a > n );
}

/// @func _max
///
/// @desc Returns largest of the input values
///
/// @arg {Number} _a
/// @arg {Number} _b
/// @arg {Number} [...]
///
/// @return {Number} Largest of the input values
///
/// @example
/// _max( 1, 2, 3 ) --> 3

_max = function( _a, _b ) {
	var _result = _a;
	var _n = argument_count;
	
	for( var i = 1; i < _n; ++i ) {
		_result = max( _result, argument[ i ] );	
	}
	
	return _result;
}

/// @func _min
///
/// @desc Returns smallest of the input values
///
/// @arg {Number} _a
/// @arg {Number} _b
/// @arg {Number} [...]
///
/// @return {Number} Smallest of the input values
///
/// @example
/// _min( 1, 2, 3 ) --> 1

_min = function( _a, _b ) {
	var _result = _a;
	var _n = argument_count;
	
	for( var i = 1; i < _n; ++i ) {
		_result = min( _result, argument[ i ] );	
	}
	
	return _result;
}

/// @func _mod
///
/// @desc Divides first argment by the secone one and returns modulus.
/// @see _rem
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} modulus of a divided by b
///
/// @example
/// _mod( 4, 2 ) --> 0

function _mod( a, b ) {
	return ( ( a % b ) + b ) % b;
}

/// @func _mul
///
/// @desc Multiplies argument values
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} a * b
///
/// @example
/// _mul( 2, 2 ) --> 4

function _mul( a, b ) {
	return a * b;
}

/// @func _rem
///
/// @desc Divides first argment by the secone one and returns remainder.
/// @see _mod
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} a % b
///
/// @example
/// _rem( 4, 2 ) --> 0

function _rem( a, b ) {
	return a % b;
}

/// @func _pow
///
/// @desc Substract second argument from the first one
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} power( a, b )
///
/// @example
/// _pow( 2, 2 ) --> 4

function _pow( a, b ) {
	return power( a, b );
}

/// @func _sub
///
/// @desc Substract second argument from the first one
///
/// @arg {Number} a
/// @arg {Number} b
///
/// @return {Number} a - b
///
/// @example
/// _sub( 4, 2 ) --> 2

function _sub( a, b ) {
	return a - b;
}

/// @func _truth
///
/// @desc Returns if argument is true
///
/// @arg {Any} a
///
/// @return {Bool} Boolean representation of object
///
/// @example
/// _truth( 1 ) --> true
///_truth( 0.2 ) --> false

function _truth( a ) {
	return bool( a );
}

#endregion