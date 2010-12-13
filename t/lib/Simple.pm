package Simple;

use Moose;
use namespace::autoclean;
use Catalyst::Runtime 5.80;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(name => 'Simple');

__PACKAGE__->setup;

1;
