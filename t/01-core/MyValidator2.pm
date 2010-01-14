package MyValidator2;
use base 'Validator::Custom';

__PACKAGE__->add_constraint(
    upper => sub { $_[0] =~ /^[A-Z]+$/ }
);
