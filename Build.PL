use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Validator::Custom::Ext::Mojolicious',
    license             => 'perl',
    dist_author         => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    dist_version_from   => 'lib/Validator/Custom/Ext/Mojolicious.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Validator::Custom' => 0.0701,
    },
    add_to_cleanup      => [ 'Validator-Custom-Ext-Mojolicious-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
