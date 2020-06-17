#region sorting

log( string( [ 1,4,6,3,5,6,4,2 ] ) );
log( array_sort( [1,4,6,3,5,6,4,2] ) );

#endregion

#region array

var a = [ 1, 2, 3 ];
array_append( a, 4, 5 );
log( a );
array_clear( a );
log( a );
array_extend( a, [ 1, 2, 4, 6 ] );
log( a );
array_insert( a, 2, 3 );
log( a );
array_insert( a, -1, 5 );
log( a );
array_delete( a, 2 );
log( a );
array_delete( a, -2 );
log( array_pop( a ), a );
array_reverse( a );
log( a );

/*
	slice
*/

assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ] ), "slice 1" );
assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined ), "slice 2" );
assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined ), "slice 3" );
assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, undefined ), "slice 4" );
assert_equals( [ 0, 2, 4 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, 2 ), "slice 5" );
assert_equals( [ 5, 4, 3, 2, 1, 0 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, -1 ), "slice 6" );
assert_equals( [ 5, 3, 1 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, -2 ), "slice 7" );
assert_equals( [ 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], 4 ), "slice 8" );
assert_equals( [ 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], -2 ), "slice 9" );
assert_equals( [ 3 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], 3, 4 ), "slice 10" );

#endregion