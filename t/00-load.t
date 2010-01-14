#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Validator::Custom::Ext::Mojolicious' );
}

diag( "Testing Validator::Custom::Ext::Mojolicious $Validator::Custom::Ext::Mojolicious::VERSION, Perl $], $^X" );
