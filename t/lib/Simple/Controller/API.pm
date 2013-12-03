package Simple::Controller::API;

use Moose;
use namespace::autoclean;
use JSON::Any;

BEGIN { extends 'Catalyst::Controller' }

with 'CatalystX::Controller::SimpleAPI';

__PACKAGE__->config(
    authkeys => {
        'AE281S228D4' => {
            ip_check => '^127',
            valid_applications => 'simple',
        },
    },
);

sub auto : Private {
    my ( $self, $c ) = @_;
    return $self->prepare_api_request($c);
}

sub foo : Local {
    my ( $self, $c ) = @_;
    my $j = JSON::Any->new;
    $c->stash(
        api_response => {
            processed => 1,
            status => 'success',
            data => $j->decode($c->req->param('value')),
        },
    );
}

sub return_error : Local {
    my ( $self, $c ) = @_;
    $c->stash(
        api_response => {
            processed => 1,
            status => 'fail',
            errors => {
                general => ['Error in API'],
            },
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;
