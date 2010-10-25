package Scope::Container;

use strict;
use warnings;
use Guard;
use Log::Minimal;
use base qw/Exporter/;

our $VERSION = '0.01';
our @EXPORT = qw/start_scope_container scope_container/;
my $CONTEXT;

sub start_scope_container {
    my $old;
    $old = $CONTEXT if defined $CONTEXT;
    $CONTEXT = {};
    return guard {
        undef $CONTEXT;
        $CONTEXT = $old if defined $old;
    };
}

sub scope_container {
    my $key = shift;
    die "undefined key" if ! defined $key;
    debugf("scope_container is not initilized") if ! defined $CONTEXT;
    if ( @_ ) {
        return $CONTEXT->{$key} = shift;
    }
    return if ! exists $CONTEXT->{$key};
    $CONTEXT->{$key};
}

1;
__END__

=head1 NAME

Scope::Container - scope based container

=head1 SYNOPSIS

  use Scope::Container;

  sub getdb {
      if ( my $dbh = scope_container('db') ) {
          return $dbh;
      } else {
          my $dbh = DBI->connect(...);
          scope_container('db', $dbh)
          return $dbh;
      }
  }

  for (1..10) {
    my $contaier = start_scope_container();
    getdb(); # do connect
    getdb(); # from container
    getdb(); # from container
  }

  getdb(); # do connect

=head1 DESCRIPTION

Scope::Container is scope based container for temporary items and Database Connections.

=head1 EXPORTED FUNCTION

=over 4

=item my $guard = start_scope_container();

=item my $value = scope_container($key:Str[,$val:Str]);

=back

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
