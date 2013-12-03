package CatalystX::Controller::SimpleAPI;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use Plack::SimpleAPI;

our $VERSION = '0.03';

has _authkeys => (
    init_arg => 'authkeys', isa => 'HashRef',
    is => 'ro', required => 0,
);

has simpleapi => (
    isa => 'Plack::SimpleAPI', is => 'rw',
);

sub _auth_config {
    my ( $self, $c ) = @_;
    return $self->_authkeys || $c->config->{'authkeys'} || {};
}

sub prepare_api_request : Private {
    my ( $self, $c ) = @_;
    $self->simpleapi(Plack::SimpleAPI->new($c->req->env));
    $self->simpleapi->auth_config($self->_auth_config);
    $self->simpleapi->prepare_api_request;
}

sub return_api_data : Private {
    my ( $self, $c ) = @_;
    $c->res->from_psgi_response($self->simpleapi->return_api_data);
}

sub end : Private {
    my ( $self, $c ) = @_; 
    my $res = $c->res;
    if ($c->stash->{api_response}) {
        $self->simpleapi->response($c->stash->{api_response});
    }
    unless ( defined $res->body && length $res->body ) {
        if (scalar @{$c->error}) {
            $self->simpleapi->make_unrecoverable_error_api_response($c->error->[0]);
            $c->clear_errors;
        }
        return $self->return_api_data($c);
    }   
}

1;

__END__

=head1 NAME

CatalystX::Controller::SimpleAPI - Catalyst controller for a simple API

=head1 SYNOPSIS

    package ServiceApp::Controller::API;

    use Moose;
    use namespace::autoclean;
    BEGIN { extends 'Catalyst::Controller' }

    with 'CatalystX::Controller::SimpleAPI';

    __PACKAGE__->config(
        authkeys => {
            'AE281S228D4' => {
                ip_check => '^10\.0\.0\.[0-9]+$',
                valid_applications => 'myapp',
            },
        },
    );

    sub auto : Private {
        my ( $self, $c ) = @_;

        # will return false if the api did not pass authorization.
        return $self->prepare_api_request($c);
    }

    1;

=head1 DESCRIPTION

Catalyst Controller that implements (currently only) a JSON based API.

=head1 CONFIGURATION

C<authkeys> are a mapping of authorization keys, and an IP and application
identification regexes. For a request to the API to be valid, it must contain a
valid authkey, and the origin IP and app id must match the regexes associated
with the authkey provided.

If no authkeys configuration for the controller is provided, it will fall back
to using the global C<authkeys> element of the application config.
C<< $c->config->{authkeys} >>

=head1 METHODS

=over 4

=item prepare_api_request

Prepares the API request to be processed.

=item return_api_data

Returns the api response to the browser in JSON format.

=back

=head1 AUTHOR & LICENSE

See L<CatalystX::SimpleAPI>.

=cut
