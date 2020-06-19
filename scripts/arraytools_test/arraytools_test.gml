#region sorting

assert_equals( [ 1,2,3,4,4,5,6,6 ], array_sort( [1,4,6,3,5,6,4,2] ), "sort 1" );
assert_equals( [ 1,2,3,4,4,5,6,6 ], array_sort( [1,4,6,3,5,6,4,2], undefined ), "sort 2" );
assert_equals( [ 2,3,4,4,5,6,6,7 ], array_sort( [7,4,6,3,5,6,4,2], undefined, false ), "sort 3" );
assert_equals( [ 6,6,5,4,4,3,2,1 ], array_sort( [1,4,6,3,5,6,4,2], undefined, true ), "sort 4" );

#endregion

#region array

/*
	append
*/

assert_equals( [ 1, 2, 3, 4, 5 ], array_append( [ 1, 2, 3 ], 4, 5 ), "append 1" );

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

/*
	index
*/

assert_equals( 3, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4 ), "index 1" );
assert_equals( 7, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, 4 ), "index 2" );
assert_equals( 7, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, -4 ), "index 3" );
assert_equals( undefined, array_index( [ 1, 2, 3, 4, 1, 1, 1, 4, 5 ], 4, 4, 6 ), "index 4" );

/*
	insert
*/

assert_equals( [ 1, 2, 3, 4, 5 ], array_insert( [ 1, 2, 4, 5 ], 2, 3 ), "insert 1" );
assert_equals( [ 1, 2, 3, 4, 5 ], array_insert( [ 1, 2, 3, 5 ], -1, 4 ), "insert 2" );

/*
	pop
*/

assert_equals( 6, array_pop( [ 1, 2, 3, 4, 5, 6 ] ), "pop 1" );

/*
	remove
*/

assert_equals( [ 1, 2, 3, 4, 5 ], array_remove( [ 1, 2, 3, 3, 4, 5 ], 3 ), "remove 1" );

/*
	reverse
*/

assert_equals( [ 5, 4, 3, 2, 1 ], array_reverse( [ 1, 2, 3, 4, 5 ] ), "reverse 1" );

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