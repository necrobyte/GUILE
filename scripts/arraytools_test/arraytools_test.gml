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

#endregion