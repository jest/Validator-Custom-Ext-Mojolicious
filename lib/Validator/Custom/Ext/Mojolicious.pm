package Validator::Custom::Ext::Mojolicious;

use warnings;
use strict;

use base 'Object::Simple';

use Carp 'croak';

__PACKAGE__->attr(rules => sub { {} });
__PACKAGE__->attr('validator');

sub validate {
    my ($self, $c) = @_;
    
    # Name
    my $name = $c->match->endpoint->name;
    
    # Validation rule
    my $rule = $self->rules->{$name} || [];
    
    # Params
    my $params = $c->req->params->to_hash || {};
    
    my $validator = $self->validator;
    
    # Not exsits 'validator'
    croak "'validator' must be specified"
      unless $validator;
    
    # Class
    unless (ref $validator) {
        
        # Load
        unless ($validator->can('isa')) {
            eval "require $validator";
            croak $@ if $@;
        }
        
        # New
        $validator = $validator->new;
    }
    
    # Not subclass of Validator::Custom
    croak "'validator' must be 'Validator::Custom' subclass or object"
      unless $validator->isa('Validator::Custom');
    
    # Validate
    my $result = $validator->validate($params, $rule);
    
    return $result;
}

=head1 NAME

Validator::Custom::Ext::Mojolicious - Mojolicious validator

=head1 VERSION

Version 0.0301

=cut

our $VERSION = '0.0301';

=head1 STATE

This module is not stable.

=head1 SYNOPSIS

    use Mojolicious::Lite;
    
    use Validator::Custom::Ext::Mojolicious;
    
    my $validator = Validator::Custom::Ext::Mojolicious->new(
        validator  => 'Validator::Custom::HTMLForm',
        rules => {
            create => [
                title => [
                    [{length => [0, 255]}, 'Title is too long']
                ],
                brash => [
                    ['not_blank', 'Select brach'],
                    [{'in_array' => [qw/bash cpp c-sharp/]}, 'Brash is invalid']
                ],
                content => [
                    [ 'not_blank',           "Input content"],
                    [ {length => [0, 4096]}, "Content is too long"]
                ]
            ],
            index => [
                # ...
            ]
        }
    );
    
    post '/create' => sub {
        my $self = shift;
        
        # Validate
        my $vresult = $validator->validate($self);
        
        unless ($vresult->is_valid) {
           # Someting 
        }        
    
    } => 'create'; # Route name

=head1 ATTRIBUTES

=head2 validator

    $validator->validator('Validator::Custom::HTMLForm');

This class must be L<Validator::Custom> subclass like L<Validator::Custom::HTMLForm>.

You can also set object, not class
    
    $validator->validator(Validator::Custom::HTMLForm->new(error_stock => 0));

=head2 rules

You can set validation rules correspond to route name.

    $validator->rules({
        'create' => [
            title => [
                [{length => [0, 255]}, 'title is too long']
            ],
            brash => [
                ['not_blank', 'brash must exists'],
                [{'in_array' => [qw/bash cpp/]}, 
                 'brash select is invalid']
            ],
            content => [
                [ 'not_blank',         'Content must be exists'],
                [ {length => [0, 4096]}, 'Conten is too long']
            ]
        ],
        'index' =>[
                # ...
        ]
    });

Validation rule is explained in L<Validator::Custom>.

=head1 METHODS

L<Validator::Custom::Ext::Mojolicious> inherits all methods from
L<Object::Simple::Base> and implements the following new ones.

=head2 validate

Validate received data

    my $vresult = $validator->validate($c);
    
This method receive L<Mojolicious::Controller> object. and validate request parameters.
and return validation rusult. This result is L<Validator::Custom::Result> object.

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
