use strict;
use Test::More;
use Scope::Container;

{
    my $sc = start_scope_container();
    scope_container('foo', 'foo1');
    is( scope_container('foo'), 'foo1' );
}

ok( ! scope_container('foo') );

sub bar {
    my ($key, $val) = @_;
    is(scope_container($key), $val);
}

{
    my $sc = start_scope_container();
    scope_container('foo', 'foo2');
    bar('foo','foo2');
    {
        bar('foo','foo2');
        my $sc = start_scope_container();
        ok( scope_container('foo') );
        scope_container('foo', 'foo3');
        bar('foo','foo3');
        {
            my $sc = start_scope_container();
            scope_container('foo', 'foo4');
        }
        is(scope_container('foo'), 'foo3');
        bar('foo','foo3');
    }
    is(scope_container('foo'), 'foo2');
}

ok( ! scope_container('foo') );

done_testing;
