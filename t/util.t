use strict;
use warnings;
use Test::More;
use Data::Dumper qw/Dumper/;

use Data::Context::Util qw/lol_path lol_iterate/;

my ($data, $tests) = get_data();
test_lol_path();
test_lol_iterate();
test_do_require();

done_testing;

sub test_lol_path {

    for my $path ( keys %$tests ) {
        is lol_path($data, $path), $tests->{$path}, "lol_path '$path' returns '".(defined $tests->{$path} ? $tests->{$path} : '')."'";
    }
}

sub test_lol_iterate {
    my %result;
    lol_iterate(
        $data,
        sub {
            my ( $data, $path ) = @_;
            $result{$path} = $data if $path;
        }
    );

    for my $path ( keys %$tests ) {
        is $result{$path}, $tests->{$path}, "lol_iterate saw '$path' had a value of '".(defined $tests->{$path} ? $tests->{$path} : '')."'";
    }

    # iterate over constant data
    %result = ();
    lol_iterate(
        1,
        sub {
            my ( $data, $path ) = @_;
            $result{$path || ''} = $data;
        }
    );
    is_deeply {''=>1}, \%result, "Iterate over constant object ok";

    # itterate over null data
    %result = ();
    lol_iterate(
        undef,
        sub {
            my ( $data, $path ) = @_;
            $result{$path || ''} = $data;
        }
    );
    is_deeply {}, \%result, "Iterate over undefined object without path ok";

    # with a defined path
    lol_iterate(
        undef,
        sub {
            my ( $data, $path ) = @_;
            $result{$path || ''} = $data;
        },
        'path'
    );
    is_deeply {}, \%result, "Iterate over undefined object with path ok"
        or note Dumper \%result;
}

sub test_do_require {
}

sub get_data {
    return (
        {
            a => "A",
            b => [
                {
                    b_a => "B A",
                },
                {
                    b_b => [
                        {
                            b_b_a => "B B A",
                        },
                        {
                            b_b_b => "B B B",
                        },
                    ],
                },
            ],
            c => Dummy->new(
                data => {
                    'c_a' => 'C A',
                }
            ),
            d => bless [], 'other object',
        },
        {
            'a'               => 'A',
            'b.0.b_a'         => "B A",
            'b.1.b_b.1.b_b_b' => "B B B",
            'c.data.c_a'      => 'C A',
            'e'               => undef,
            'b.1.b_b.1.b_b_e' => undef,
        }
    );
}

package Dummy;

use Moose;

BEGIN {
    has data => (
        is  => 'rw',
        isa => 'HashRef',
    );
};
