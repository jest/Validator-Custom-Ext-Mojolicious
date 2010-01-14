package Validator::Custom::Ext::Mojolicious;
use Object::Simple;

use warnings;
use strict;
use Carp 'croak';

sub validation_rules : Attr { type => 'hash', default => sub {{}} }

sub validator_class  : Attr {}

sub validate {
    my ($self, $c) = @_;
    
    # Controller
    my $controller = $c->stash->{controller};
    
    # Action
    my $action = $c->stash->{action};
    
    # Validation rule
    my $validation_rule = $self->validation_rules->{$controller}{$action} || [];
    
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

Object::Simple->build_class;

=head1 NAME

Validator::Custom::Ext::Mojolicious - Validator for Mojolicious

=head1 VERSION

Version 0.0101

=cut

our $VERSION = '0.0101';


=head1 SYNOPSIS

    package YourApp;
    use base 'Mojolicious';
    
    use Validator::Custom::Ext::Mojolicious;
    
    __PACKAGE__->attr(validator => sub { Validator::Custom::Ext::Mojolicious->new });
    
    sub startup {
        my $self = shift;
        
        $self->validator->validator_class('Validator::Custom::HTMLForm');
        
        $self->validator->validation_rules(
            'create#default' => [
                title => [
                    [{length => [0, 255]}, 'Title is too long']
                ],
                brash => [
                    ['not_blank', 'Select brach'],
                    [{'in_array' => [qw/bash cpp c-sharp css delphi diff groovy java javascript perl
                                        php plain python ruby scala sql vb xml invaid/]},
                     'Brash is invalid']
                ],
                content => [
                    [ 'not_blank',           "Input content"],
                    [ {length => [0, 4096]}, "Content is too long"]
                ]
            ],
            'example#welcome' => [
                # ...
            ]
        );
        
        # Something else
        
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

=head1 Methods

=head2 validate

Validate received data

    $v->validate($c);

=head2 validator_class

You can set validator class.
This must be L<Validator::Custom> subclass like L<Validator::Custom::HTMLForm>.

    $v->validator_class('Validator::Custom::HTMLForm');

You can also set object
    
    my $vc = Validator::Custom::HTMLForm->new(error_stock => 0);
    $v->validator_class($vc);

=head2 validation_rules

You can set validation rules according to controller and action pair.
This is used when 'validate' is executed.

    $v->validation_rules(
        create => {
            default => [
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
            ]
        },
        some_controller => {
            some_action => [
                # ...
            ]
        }
    );

=head1 Author

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 Copyright & License

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
