use Test::More 'no_plan';

package MyValidator1;
use base 'Validator::Custom';

__PACKAGE__->add_constraint(
    int => sub { ($_[0] || '') =~ /^\d+$/ }
);

package Parameters;
use base 'Object::Simple::Base';

__PACKAGE__->attr('to_hash');

package Request;
use base 'Object::Simple::Base';

__PACKAGE__->attr(params => sub {Parameters->new});

package Controller;
use base 'Object::Simple::Base';

__PACKAGE__->attr('stash');
__PACKAGE__->attr(req => sub {Request->new});

package main;

use lib 't/01-core';
use_ok('Validator::Custom::Ext::Mojolicious');

my $test;
sub test {$test = shift}

my $mv;
my $params;
my $c;
my $result;


test 'validate';
$mv = Validator::Custom::Ext::Mojolicious->new;
$mv->validator_class('MyValidator1');
$mv->validation_rules({
    'controller1#action1' => [
        key1 => [
            'int'
        ]
    ]
});

$c = Controller->new;
$c->stash({action => 'action1', controller => 'controller1'});
$c->req->params->to_hash({key1 => 'a'});
$result = $mv->validate($c);
ok(!$result->is_valid, "$test : basic valid");

$c->stash({action => 'action1', controller => 'controller1'});
$c->req->params->to_hash({});
$result = $mv->validate($c);
ok(!$result->is_valid, "$test : params empty");

$c->stash({action => 'action2', controller => 'controller1'});
$c->req->params->to_hash({key1 => 'a'});
$result = $mv->validate($c);
ok($result->is_valid, "$test : not found validation_rule");

$mv->validator_class(MyValidator1->new);
$c->stash({action => 'action1', controller => 'controller1'});
$c->req->params->to_hash({key1 => 'a'});
$result = $mv->validate($c);
ok(!$result->is_valid, "$test : validator_class is object");

$mv->validator_class('MyValidator2');
$mv->validation_rules({
    'controller1#action1' => [
        key1 => [
            'upper'
        ]
    ]
});
$c->stash({action => 'action1', controller => 'controller1'});
$c->req->params->to_hash({key1 => 'a'});
$result = $mv->validate($c);
ok(!$result->is_valid, "$test : validator_class load");


test 'Error case';
$mv = Validator::Custom::Ext::Mojolicious->new;
$mv->validator_class('');
$mv->validation_rules({
    'controller1#action1' => [
        key1 => [
            'int'
        ]
    ]
});
$c = Controller->new;
$c->stash({action => 'action1', controller => 'controller1'});
$c->req->params->to_hash({key1 => 'a'});
eval {$result = $mv->validate($c)};
like($@, qr/validator_class' must be specified/, "$test : not specified validator_class");

$mv->validator_class('AAAAAA');
eval {$result = $mv->validate($c)};
ok($@, "$test : cannot load validator_class");

$mv->validator_class('CGI');
eval {$result = $mv->validate($c)};
like($@, qr/'validator_class' must be 'Validator::Custom' subclass or object/,
     "$test : validator_class not Validator::Custom subclass");


