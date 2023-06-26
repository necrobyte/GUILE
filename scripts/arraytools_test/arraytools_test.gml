#region sorting

assert_equals( [ 1,2,3,4,4,5,6,6 ], array_key_sort( [1,4,6,3,5,6,4,2] ), "sort 1" );
assert_equals( [ 1,2,3,4,4,5,6,6 ], array_key_sort( [1,4,6,3,5,6,4,2], undefined ), "sort 2" );
assert_equals( [ 2,3,4,4,5,6,6,7 ], array_key_sort( [7,4,6,3,5,6,4,2], undefined, false ), "sort 3" );
assert_equals( [ 6,6,5,4,4,3,2,1 ], array_key_sort( [1,4,6,3,5,6,4,2], undefined, true ), "sort 4" );

#endregion

#region array

/*
	append
*/

assert_equals( [ 1, 2, 3, 4, 5 ], array_append( [ 1, 2, 3 ], 4, 5 ), "append 1" );

/*
	bisect_left
*/

assert_equals( 0, array_bisect_left( [ ], 1 ), "bisect_left 1" );
assert_equals( 0, array_bisect_left( [ 1 ], 0 ), "bisect_left 2" );
assert_equals( 0, array_bisect_left( [ 1 ], 1 ), "bisect_left 3" );
assert_equals( 1, array_bisect_left( [ 1 ], 2 ), "bisect_left 4" );
assert_equals( 0, array_bisect_left( [ 1, 1 ], 0 ), "bisect_left 5" );
assert_equals( 0, array_bisect_left( [ 1, 1 ], 1 ), "bisect_left 6" );
assert_equals( 2, array_bisect_left( [ 1, 1 ], 2 ), "bisect_left 7" );
assert_equals( 0, array_bisect_left( [ 1, 1, 1 ], 0 ), "bisect_left 8" );
assert_equals( 0, array_bisect_left( [ 1, 1, 1 ], 1 ), "bisect_left 9" );
assert_equals( 3, array_bisect_left( [ 1, 1, 1 ], 2 ), "bisect_left 10" );
assert_equals( 0, array_bisect_left( [ 1, 1, 1, 1 ], 0 ), "bisect_left 11" );
assert_equals( 0, array_bisect_left( [ 1, 1, 1, 1 ], 1 ), "bisect_left 12" );
assert_equals( 4, array_bisect_left( [ 1, 1, 1, 1 ], 2 ), "bisect_left 13" );
assert_equals( 0, array_bisect_left( [ 1, 2 ], 0 ), "bisect_left 14" );
assert_equals( 0, array_bisect_left( [ 1, 2 ], 1 ), "bisect_left 15" );
assert_equals( 1, array_bisect_left( [ 1, 2 ], 1.5 ), "bisect_left 16" );
assert_equals( 1, array_bisect_left( [ 1, 2 ], 2 ), "bisect_left 17" );
assert_equals( 2, array_bisect_left( [ 1, 2 ], 3 ), "bisect_left 18" );
assert_equals( 0, array_bisect_left( [ 1, 1, 2, 2 ], 0 ), "bisect_left 19" );
assert_equals( 0, array_bisect_left( [ 1, 1, 2, 2 ], 1 ), "bisect_left 20" );
assert_equals( 2, array_bisect_left( [ 1, 1, 2, 2 ], 1.5 ), "bisect_left 21" );
assert_equals( 2, array_bisect_left( [ 1, 1, 2, 2 ], 2 ), "bisect_left 22" );
assert_equals( 4, array_bisect_left( [ 1, 1, 2, 2 ], 3 ), "bisect_left 23" );
assert_equals( 0, array_bisect_left( [ 1, 2, 3 ], 0 ), "bisect_left 24" );
assert_equals( 0, array_bisect_left( [ 1, 2, 3 ], 1 ), "bisect_left 25" );
assert_equals( 1, array_bisect_left( [ 1, 2, 3 ], 1.5 ), "bisect_left 26" );
assert_equals( 1, array_bisect_left( [ 1, 2, 3 ], 2 ), "bisect_left 27" );
assert_equals( 2, array_bisect_left( [ 1, 2, 3 ], 2.5 ), "bisect_left 28" );
assert_equals( 2, array_bisect_left( [ 1, 2, 3 ], 3 ), "bisect_left 29" );
assert_equals( 3, array_bisect_left( [ 1, 2, 3 ], 4 ), "bisect_left 30" );
assert_equals( 0, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 0 ), "bisect_left 31" );
assert_equals( 0, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 1 ), "bisect_left 32" );
assert_equals( 1, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 1.5 ), "bisect_left 33" );
assert_equals( 1, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 2 ), "bisect_left 34" );
assert_equals( 3, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 2.5 ), "bisect_left 35" );
assert_equals( 3, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 3 ), "bisect_left 36" );
assert_equals( 6, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 3.5 ), "bisect_left 37" );
assert_equals( 6, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 4 ), "bisect_left 38" );
assert_equals( 10, array_bisect_left( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 5 ), "bisect_left 39" );

/*
	bisect_right
*/

assert_equals( 0, array_bisect_right( [ ], 1 ), "bisect_right 1" );
assert_equals( 0, array_bisect_right( [ 1 ], 0 ), "bisect_right 2" );
assert_equals( 1, array_bisect_right( [ 1 ], 1 ), "bisect_right 3" );
assert_equals( 1, array_bisect_right( [ 1 ], 2 ), "bisect_right 4" );
assert_equals( 0, array_bisect_right( [ 1, 1 ], 0 ), "bisect_right 5" );
assert_equals( 2, array_bisect_right( [ 1, 1 ], 1 ), "bisect_right 6" );
assert_equals( 2, array_bisect_right( [ 1, 1 ], 2 ), "bisect_right 7" );
assert_equals( 0, array_bisect_right( [ 1, 1, 1 ], 0 ), "bisect_right 8" );
assert_equals( 3, array_bisect_right( [ 1, 1, 1 ], 1 ), "bisect_right 9" );
assert_equals( 3, array_bisect_right( [ 1, 1, 1 ], 2 ), "bisect_right 10" );
assert_equals( 0, array_bisect_right( [ 1, 1, 1, 1 ], 0 ), "bisect_right 11" );
assert_equals( 4, array_bisect_right( [ 1, 1, 1, 1 ], 1 ), "bisect_right 12" );
assert_equals( 4, array_bisect_right( [ 1, 1, 1, 1 ], 2 ), "bisect_right 13" );
assert_equals( 0, array_bisect_right( [ 1, 2 ], 0 ), "bisect_right 14" );
assert_equals( 1, array_bisect_right( [ 1, 2 ], 1 ), "bisect_right 15" );
assert_equals( 1, array_bisect_right( [ 1, 2 ], 1.5 ), "bisect_right 16" );
assert_equals( 2, array_bisect_right( [ 1, 2 ], 2 ), "bisect_right 17" );
assert_equals( 2, array_bisect_right( [ 1, 2 ], 3 ), "bisect_right 18" );
assert_equals( 0, array_bisect_right( [ 1, 1, 2, 2 ], 0 ), "bisect_right 19" );
assert_equals( 2, array_bisect_right( [ 1, 1, 2, 2 ], 1 ), "bisect_right 20" );
assert_equals( 2, array_bisect_right( [ 1, 1, 2, 2 ], 1.5 ), "bisect_right 21" );
assert_equals( 4, array_bisect_right( [ 1, 1, 2, 2 ], 2 ), "bisect_right 22" );
assert_equals( 4, array_bisect_right( [ 1, 1, 2, 2 ], 3 ), "bisect_right 23" );
assert_equals( 0, array_bisect_right( [ 1, 2, 3 ], 0 ), "bisect_right 24" );
assert_equals( 1, array_bisect_right( [ 1, 2, 3 ], 1 ), "bisect_right 25" );
assert_equals( 1, array_bisect_right( [ 1, 2, 3 ], 1.5 ), "bisect_right 26" );
assert_equals( 2, array_bisect_right( [ 1, 2, 3 ], 2 ), "bisect_right 27" );
assert_equals( 2, array_bisect_right( [ 1, 2, 3 ], 2.5 ), "bisect_right 28" );
assert_equals( 3, array_bisect_right( [ 1, 2, 3 ], 3 ), "bisect_right 29" );
assert_equals( 3, array_bisect_right( [ 1, 2, 3 ], 4 ), "bisect_right 30" );
assert_equals( 0, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 0 ), "bisect_right 31" );
assert_equals( 1, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 1 ), "bisect_right 32" );
assert_equals( 1, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 1.5 ), "bisect_right 33" );
assert_equals( 3, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 2 ), "bisect_right 34" );
assert_equals( 3, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 2.5 ), "bisect_right 35" );
assert_equals( 6, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 3 ), "bisect_right 36" );
assert_equals( 6, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 3.5 ), "bisect_right 37" );
assert_equals( 10, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 4 ), "bisect_right 38" );
assert_equals( 10, array_bisect_right( [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 ], 5 ), "bisect_right 39" );

/*
	clear
*/

assert_equals( [ ], array_clear( [ 1, 2, 3, 4, 5 ] ), "clear 1" );

/*
	clone
*/

assert_equals( [ 1, 2, 3, 4, 5 ], array_clone( [ 1, 2, 3, 4, 5 ] ), "clone 1" );

/*
	count
*/

assert_equals( 4, array_count( [ 2, 3, 4, 3, 10, 3, 5, 6, 3 ], 3 ), "count 1" );
assert_equals( 0, array_count( [ 2, 3, 4, 3, 10, 3, 5, 6, 3 ], 7 ), "count 2" );

/*
	extend
*/

assert_equals( [ 1, 2, 3, 4, 5 ], array_extend( [ 1, 2, 3 ], [ 4, 5 ] ), "extend 1" );

/*
	flat
*/

assert_equals( [ ], array_flat( [ ] ), "flat 1" );
assert_equals( [ 1, 2, 3, 4 ], array_flat( [ 1, 2, 3, 4 ] ), "flat 2" );
assert_equals( [ 1, 2, 3, 4 ], array_flat( [ [ 1, 2 ], [ 3, 4 ] ] ), "flat 3" );
assert_equals( [ 1, 2, 3, 4 ], array_flat( [ [ [ 1, 2 ], [ 3, 4 ] ] ] ), "flat 4" );
assert_equals( [ [ 1, 2 ], [ 3, 4 ] ], array_flat( [ [ [ 1, 2 ], [ 3, 4 ] ] ], 1 ), "flat 5" );
assert_equals( [ 1, 2, 3, 4 ], array_flat( [ [ [ 1, 2 ], [ 3, 4 ] ] ], 2 ), "flat 6" );
assert_equals( [ [ 1, 2 ], [ 3, 4, 5 ] ], array_flat( [ [ 1, 2 ], [ 3, 4, 5 ] ] ), "flat 7" );
assert_equals( [ 1, 2, 3, [ 4, 5 ] ], array_flat( [ [ 1, 2 ], [ 3, [ 4, 5 ] ] ] ), "flat 8" );

/*
	index
*/

assert_equals( 3, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4 ), "index 1" );
assert_equals( 7, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, 4 ), "index 2" );
assert_equals( 7, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, -4 ), "index 3" );
assert_equals( undefined, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, 4, 6 ), "index 4" );

/*
	remove
*/

assert_equals( [ 1, 2, 3, 4, 5 ], array_remove( [ 1, 2, 3, 3, 4, 5 ], 3 ), "remove 1" );

/*
	reshape
*/

assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_reshape( [ 0, 1, 2, 3, 4, 5 ], [ 6 ] ), "reshape 1" );
assert_array_equals( [ [ 0, 1, 2 ], [ 3, 4, 5 ] ], array_reshape( [ 0, 1, 2, 3, 4, 5 ], [ 2, 3 ] ), "reshape 2" );
assert_array_equals( [ [ 0, 1 ], [ 2, 3 ], [ 4, 5 ] ], array_reshape( [ 0, 1, 2, 3, 4, 5 ], [ 3, 2 ] ), "reshape 3" );
assert_array_equals( [ [ [ 0,1,2 ],[ 3,4,5 ] ],[ [ 6,7,8 ],[ 9,10,11 ] ] ], array_reshape( arange( 12 ), [ 2, 2, 3 ] ), "reshape 4" );
assert_array_equals( [ [ [ 0,1 ],[ 2,3 ],[ 4,5 ] ],[ [ 6,7 ],[ 8,9 ],[ 10,11 ] ] ], array_reshape( arange( 12 ), [ 2, 3, 2 ] ), "reshape 5" );
assert_array_equals( [ [ [ 0,1 ],[ 2,3 ] ],[ [ 4,5 ],[ 6,7 ] ],[ [ 8,9 ],[ 10,11 ] ] ], array_reshape( arange( 12 ), [ 3, 2, 2 ] ), "reshape 6" );

/*
	shape
*/

assert_equals( [ 0 ], array_shape( [] ), "shape 1" );
assert_equals( [ 1, 0 ],  array_shape( [[]] ), "shape 2" );
assert_equals( [ 2, 0 ], array_shape( [[],[]] ), "shape 3" );
assert_equals( [ 1, 1 ],  array_shape( [[ 1 ]] ), "shape 4" );
assert_equals( [ 2, 1 ],  array_shape( [ [ 1 ], [ 2 ] ] ), "shape 5" );
assert_equals( [ 1, 2 ],  array_shape( [[ 1, 2 ]] ), "shape 6" );
assert_equals( [ 2, 2 ], array_shape( [ [ 1, 2 ],[ 3, 4 ] ] ), "shape 7" );
assert_equals( [ 2 ], array_shape( [ [ 1, 2 ],[ 3, 4, 5 ] ] ), "shape 8" );
assert_equals( [ 2, 2, 2 ], array_shape( [ [ [ 1, 2 ],[ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ] ), "shape 9" );
assert_equals( [ 1, 2 ],  array_shape( [ [ 2 ], [ 1 ] ], false ), "shape 10" );

/*
	slice
*/

assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ] ), "slice 1" );
assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined ), "slice 2" );
assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined ), "slice 3" );
assert_equals( [ 0, 1, 2, 3, 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, undefined ), "slice 4" );
assert_equals( [ 0, 2, 4 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, 2 ), "slice 5" );
log( [ 5, 4, 3, 2, 1, 0 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, -1 ), "slice 6" );
assert_equals( [ 5, 4, 3, 2, 1, 0 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, -1 ), "slice 6" );
assert_equals( [ 5, 3, 1 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], undefined, undefined, -2 ), "slice 7" );
assert_equals( [ 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], 4 ), "slice 8" );
assert_equals( [ 4, 5 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], -2 ), "slice 9" );
assert_equals( [ 3 ], array_slice( [ 0, 1, 2, 3, 4, 5 ], 3, 4 ), "slice 10" );

#endregion

#region Array

var a = new Array( [ ] );
assert_equals( [ 0 ], a.shape, "Array empty shape" );
assert_equals( string( [ ] ), a.to_string(), "Array empty to_string" );
assert_equals( [ ], a.to_array(), "Array empty to_array" );

a = new Array( [ 1, 2, 3, 4 ] );
assert_equals( [ 4 ], a.shape, "Array 1d shape" );
assert_equals( string( [ 1, 2, 3, 4 ] ), a.to_string(), "Array 1d to_string" );
assert_equals( [ 1, 2, 3, 4 ], a.to_array(), "Array 1d to_array" );

a = new Array( [ [ 1, 2 ] , [ 3, 4 ] ] );
assert_equals( [ 2, 2 ], a.shape, "Array 2d shape" );
assert_equals( string( [ [ 1, 2 ] , [ 3, 4 ] ] ), a.to_string(), "Array 2d to_string" );
assert_equals( 4, a.get( 1, 1 ), "Array get" );
a.set( 0, [ 0, 0 ] );
assert_array_equals( [ [ 0, 2 ] , [ 3, 4 ] ], a.to_array(), "Array 2d to_array" );

a = new Array( [ [ 1, 2] , [ 3, 4, 5 ] ] );
assert_equals( [ 2 ], a.shape, "Array non-rectangular" );

a = new Array( arange( 12 ) );
assert_equals( arange( 12 ), a.to_array(), "Array to_array" );
assert_equals( arange( 12 ), a.T().to_array(), "Array T 1" );

a.resize( [ 2, 6 ] );
assert_array_equals( [ [ 0,1,2,3,4,5 ],[ 6,7,8,9,10,11 ] ], a.to_array(), "Array resize 1" );
assert_array_equals( [ [ 0,6 ],[ 1,7 ],[ 2,8 ],[ 3,9 ],[ 4,10 ],[ 5,11 ] ], a.T().to_array(), "Array T 2" );

a = new Array( arange( 12 ) ).reshape( [ 6, 2 ] );
assert_array_equals(  [ [ 0,1 ],[ 2,3 ],[ 4,5 ],[ 6,7 ],[ 8,9 ],[ 10,11 ] ], a.to_array(), "Array reshape 2" );
assert_array_equals( [ [ 0,2,4,6,8,10 ],[ 1,3,5,7,9,11 ] ], a.T().to_array(), "Array T 3" );

a.resize( [ 2, 2, 3 ] );

assert_equals( [ 0,6,3,9,1,7,4,10,2,8,5,11 ] , a.T().data, "Array transpose 3d 1" );
assert_equals( [ 0,3,6,9,1,4,7,10,2,5,8,11 ], a.T( [ 2, 0, 1 ] ).data, "Array transpose 3d 2" );
assert_equals( [ 0,3,1,4,2,5,6,9,7,10,8,11 ], a.T( [ 0, 2, 1 ] ).data, "Arary transpose 3d 3" );

#endregion