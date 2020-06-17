#region sorting

log( string( [ 1,4,6,3,5,6,4,2 ] ) );
log( array_sort( [1,4,6,3,5,6,4,2] ) );

#endregion

#region array

var a = [ 1, 2, 3 ];
array_append( a, 4, 5 );
log( a );
array_extend( a, [ 6, 7 ] );
log( a );

#endregion