package Connector;

use strict;
use warnings;
use Carp;
use Data::Util qw/is_array_ref/;
use List::Util qw/shuffle/;
use Log::Minimal;
use Scope::Container;
use DBIx::Connector;
use Data::MessagePack;

sub connect {
    my $class = shift;
    if ( is_array_ref($_[0]) ) {
        my @dsn = @_;

        my $connector;
        my $dsn_key = build_dsn_key(@dsn);      
        my $dbh = lookup_container($dsn_key);
        return $dbh if $dbh;

        for my $s_dsn ( shuffle(@dsn) ) {
            eval {
                ($dbh, $connector) = $class->connect(@$s_dsn);
            };
            infof($@) if $@;
            last if ( $dbh );
        }
        
        if ( $dbh ) {
            save_container($dsn_key, $connector);
            return wantarray ? ( $dbh, $connector ) : $dbh;
        }
        
        croak("couldnt connect all DB, " .
            join(",", map { $_->[0] } @dsn));
        
    }

    my @dsn = @_;
    my $dsn_key = build_dsn_key(\@dsn);     
    my $dbh = lookup_container($dsn_key);
    return $dbh if $dbh;

    my $connector = DBIx::Connector->new(@dsn);
    $dbh = $connector->dbh;
        
    save_container($dsn_key, $connector);
    return wantarray ? ( $dbh, $connector ) : $dbh;
}

sub build_dsn_key {
    my @dsn = @_;
    @dsn = sort { $a->[0] cmp $b->[0] } @dsn;
    Data::MessagePack->pack(\@dsn);
}

sub lookup_container {
    my $key = shift;
    my $connector = scope_container("pickless:dbix:connector:".$key);
    return if !$connector;
    my $dbh;
    eval {
        $dbh = $connector->_dbh;
    };
    return if $@;
    return $dbh;
}

sub save_container {
    my $key = shift;
    scope_container("pickless:dbix:connector:".$key, shift);
}

1;


__END__

=head1 NAME

connector - DBI connection cache with Scope::Container

=head1 SYNOPSIS

  use Scope::Container;
  use Connector;

  my $container = start_scope_container();

  {
      my $dbh = Connector->connect("dbi:mysql:mydb","user","password",{RaiseError=>1});

      my $dbh2 = Connector->connect(
          ["dbi:mysql:mydb;host=srv1","user","password",{RaiseError=>1}],
          ["dbi:mysql:mydb;host=srv2","user","password",{RaiseError=>1}],
          ["dbi:mysql:mydb;host=srv3","user","password",{RaiseError=>1}],
      );
  }

  {
      #return from cache
      my $dbh = Connector->connect("dbi:mysql:mydb","user","password",{RaiseError=>1}); 

      my $dbh2 = Connector->connect(
          ["dbi:mysql:mydb;host=srv1","user","password",{RaiseError=>1}],
          ["dbi:mysql:mydb;host=srv2","user","password",{RaiseError=>1}],
          ["dbi:mysql:mydb;host=srv3","user","password",{RaiseError=>1}],
      );
  }

  # clear DB connection cache if $container scope out

=head1 DESCRIPTION

DBI connection cache with Scope::Container

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
