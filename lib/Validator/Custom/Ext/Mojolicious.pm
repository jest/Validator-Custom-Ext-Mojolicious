package Validator::Custom::Ext::Mojolicious;
use base 'Object::Simple::Base';

use warnings;
use strict;
use Carp 'croak';

__PACKAGE__->attr('validation_rules' => sub { {} });

__PACKAGE__->attr('validator_class');

sub validate {
    my ($self, $c) = @_;
    
    # Controller
    my $controller = $c->stash->{controller} || '';
    
    # Action
    my $action = $c->stash->{action} || '';
    
    # Validation rule
    my $validation_rule = $self->validation_rules->{"$controller#$action"} || [];
    
    # Params
    my $params = $c->req->params->to_hash || {};

    # Validator class
    my $validator_class = $self->validator_class;
    
    # Not exsits 'validator'
    croak "'validator_class' must be specified"
      unless $validator_class;
    
    # Validator
    my $validator;
    
    # Object
    if (ref $validator_class) { $validator = $validator_class }
    
    # Class
    elsif (! ref $validator_class) {
        
        # Load
        unless ($validator_class->can('isa')) {
            eval "require $validator_class";
            croak $@ if $@;
        }
        
        # New
        $validator = $validator_class->new;
    }
    
    croak "'validator_class' must be 'Validator::Custom' subclass or object"
      unless $validator_class->isa('Validator::Custom');
    
    # Validate
    my $result = $validator->validate($params, $validation_rule);
    
    return $result;
}

=head1 NAME

Validator::Custom::Ext::Mojolicious - Validator for Mojolicious

=head1 VERSION

Version 0.0103

=cut

our $VERSION = '0.0103';

=head1 SYNOPSIS

    package YourApp;
    use base 'Mojolicious';
    
    use Validator::Custom::Ext::Mojolicious;
    
    __PACKAGE__->attr(validator => sub {
        
        return Validator::Custom::Ext::Mojolicious->new(
            validator_class  => 'Validator::Custom::HTMLForm',
            validation_rules => {
                'create#default' => [
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
                'example#welcome' => [
                    # ...
                ]
            }
        );
        
    });
    
    package YourApp::Create;
    use base 'Mojolicious::Controller';

    sub default { 
        my $self = shift;
        
        # Validate
        my $vresult = $self->app->validator->validate($self);
        
        unless ($vresult->is_valid) {
           # Someting 
        }
    }

=head1 Attributes

=head2 validator_class

    $v->validator_class('Validator::Custom::HTMLForm');

This class must be L<Validator::Custom> subclass like L<Validator::Custom::HTMLForm>.

You can also set object, not class
    
    my $vc = Validator::Custom::HTMLForm->new(error_stock => 0);
    $v->validator_class($vc);

=head2 validation_rules

You can set validation rules correspond to controller and action pair.
Constoller and action must be join '#'. 

    $v->validation_rules({
        'create#default' => [
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
        'action#controller' =>[
                # ...
        ]
    });

Validation rule is explained L<Validator::Custom> documentation.

=head1 Methods

L<Validator::Custom::Ext::Mojolicious> inherits all methods from
L<Object::Simple::Base> and implements the following new ones.

=head2 validate

Validate received data

    my $vresult = $v->validate($c);
    
This method receive L<Mojolicious::Controller> object. and validate request parameters.
and return validation rusult. This result is L<Validator::Custom::Result> object.

=head1 Author

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 Copyright & License

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
