use Test::More 'no_plan';

package MyValidator1;
use base 'Validator::Custom';

__PACKAGE__->add_constraint(
    int => sub { ($_[0] || '') =~ /^\d+$/ }
);

package Parameters;
use base 'Object::Simple';

__PACKAGE__->attr('to_hash');

package Request;
use base 'Object::Simple';

__PACKAGE__->attr(params => sub {Parameters->new});

package Controller;
use base 'Object::Simple';

__PACKAGE__->attr('stash');
__PACKAGE__->attr(req => sub {Request->new});
__PACKAGE__->attr(match => sub {Match->new});

package Match;
use base 'Object::Simple';

__PACKAGE__->attr(endpoint => sub { Route->new });

package Route;
use base 'Object::Simple';

__PACKAGE__->attr('name');

package main;

use lib 't/01-core';
use_ok('Validator::Custom::Ext::Mojolicious');

my $test;
sub test {$test = shift}

my $vm;
my $params;
my $c;
my $result;


test 'validate';
$vm = Validator::Custom::Ext::Mojolicious->new;
$vm->validator('MyValidator1');
$vm->rules({
    'name1' => [
        key1 => [
            'int'
        ]
    ]
});

$c = Controller->new;
$c->match->endpoint->name('name1');
$c->req->params->to_hash({key1 => 'a'});
$result = $vm->validate($c);
ok(!$result->is_valid, "$test : basic valid");

$c->match->endpoint->name('name1');
$c->req->params->to_hash({});
$result = $vm->validate($c);
ok(!$result->is_valid, "$test : params empty");

$c->match->endpoint->name('name2');
$c->req->params->to_hash({key1 => 'a'});
$result = $vm->validate($c);
ok($result->is_valid, "$test : not found validation_rule");

$vm->validator(MyValidator1->new);
$c->match->endpoint->name('name1');
$c->req->params->to_hash({key1 => 'a'});
$result = $vm->validate($c);
ok(!$result->is_valid, "$test : validator is object");

$vm->validator('MyValidator2');
$vm->rules({
    'name1' => [
        key1 => [
            'upper'
        ]
    ]
});
$c->match->endpoint->name('name1');
$c->req->params->to_hash({key1 => 'a'});
$result = $vm->validate($c);
ok(!$result->is_valid, "$test : validator load");


test 'Error case';
$vm = Validator::Custom::Ext::Mojolicious->new;
$vm->validator('');
$vm->rules({
    'name1' => [
        key1 => [
            'int'
        ]
    ]
});
$c = Controller->new;
$c->match->endpoint->name('name1');
$c->req->params->to_hash({key1 => 'a'});
eval {$result = $vm->validate($c)};
like($@, qr/validator' must be specified/, "$test : not specified validator");

$vm->validator('AAAAAA');
eval {$result = $vm->validate($c)};
ok($@, "$test : cannot load validator");

$vm->validator('CGI');
eval {$result = $vm->validate($c)};
like($@, qr/'validator' must be 'Validator::Custom' subclass or object/,
     "$test : validator not Validator::Custom subclass");


