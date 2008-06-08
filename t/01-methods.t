#!perl
use strict;
use warnings;
use File::Temp;
use Test::More qw( no_plan );

our $class;

BEGIN {
    $class = 'Net::Squid::Auth::Plugin::UserList';
    eval "use $class";
    die $@ if $@;
}

can_ok $class, qw( new initialize is_valid );

{    # no config
    my $plugin = eval { $class->new(); };
    ok !$plugin, q{No plugin instance is constructed without a config hash.};
}

{
    my $config = { users => qq{lmc:secret\nmanager:test} };
    my $plugin = $class->new($config);
    ok defined $plugin
      && UNIVERSAL::isa( $plugin, q{Net::Squid::Auth::Plugin::UserList} ),
      q{Plugin constructed and have the right type.};
    eval{ $plugin->initialize; };
    ok !$@, q{Plugin initialized successfuly};
    my $valid;
    $valid = eval{ $plugin->is_valid( 'notauser', 'secret' ); };
    ok !$@ && !$valid, q{Invalid user rejected as expected.};
    $valid = eval{ $plugin->is_valid( 'lmc', 'wrong' ); };
    ok !$@ && !$valid, q{Invalid password rejected as expected.};
    $valid = eval{ $plugin->is_valid( 'lmc', 'secret' ); };
    ok !$@ && $valid, q{Valid credentials accepted.};
}
