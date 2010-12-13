package CatalystX::Controller::SimpleAPI;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use JSON::XS ();

has authkeys => (
    isa => 'HashRef', is => 'ro', required => 1,
);

sub prepare_api_request : Private {
    my ( $self, $c ) = @_;

    if (!exists($c->stash->{'api_params'})) {
        $c->stash->{'api_params'} = $c->req->params;
    }
    $c->stash->{'api_params'}{'output'} = 'json';
    
    ## This sets the default response as a failure.  
    $c->stash->{'api_response'} = {
        processed => 0,
        status => 'failed',
        data => {},
    };

    my $provided_authkey = $c->stash->{'api_params'}{'authkey'} || 'unknown';
    my $authkey_ip_check;
    if (exists($self->authkeys->{$provided_authkey})) {
        $c->stash->{'api_authorization'} = $self->authkeys->{$provided_authkey};
        if (exists($self->authkeys->{$provided_authkey}{'ip_check'})) {
            $authkey_ip_check = $self->authkeys->{$provided_authkey}{'ip_check'}
        } else {
            $authkey_ip_check = $self->authkeys->{$provided_authkey};
        }
    }
    
    if (defined($authkey_ip_check) && ( $c->req->address =~ $authkey_ip_check)) {
         if (!grep { $c->stash->{'api_params'}{'application'} eq $_ } @{$c->stash->{'api_authorization'}{'valid_applications'}}) {
            $c->stash->{'api_response'}{'processed'} = 0;
            $c->stash->{'api_response'}{'status'} = 'failed';
            $c->stash->{'api_response'}{'errors'} = {
                'general' => [ 'Authorization failed' ],
            };
            return 0;
        }
        return 1;
    } else {
        $c->stash->{'api_response'}{'errors'} = {
            'general' => [ 'Service not available, check your configuration' ],
        };
        return 0;
    }
}

sub return_api_data : Private {
     my ( $self, $c ) = @_;
    $c->response->header('Cache-Control' => 'no-cache');
    $c->response->header('application/json');
    my $jsonobject = JSON::XS->new->utf8->pretty(1);
    my $responsetext = $jsonobject->encode($c->stash->{'api_response'});
    $c->response->body($responsetext);
}

sub end : Private {
    my ( $self, $c ) = @_; 
        
    if (!$c->res->body()) {
        if ($#{$c->error} == -1) {
            return $self->return_api_data($c);
        } else {
            $c->stash->{'api_response'}{'processed'} = 0;
            $c->stash->{'api_response'}{'status'} = 'failed';
            delete $c->stash->{'api_response'}{'data'};
            $c->stash->{'api_response'}{'errors'} = { 'general' => [ 'An unrecoverable error occurred: ' . $c->error->[0] ] };
            $c->clear_errors;
            return $self->return_api_data($c);
        }   
    }   
}

1;

__END__

=head1 NAME

=head1 DESCRIPTION

Catalyst Controller that implements a JSON or XML based API.

=head1 CONFIGURATION

    __PACKAGE__->config(
        authkeys => {
            'AE281S228D4' => {
                ip_check => qr/^10\.0\.0\.[0-9]+$/,
                valid_applications => [qw/ audit_us report_us audit_uk report_uk /],
            },
        },
    );

C<authkeys> are a mapping of authorization keys and a regex to be used to verify
the clients address. For a request to the API to be valid, it must contain a
valid authkey, and the origin IP must match the  regex associated with the
authkey provided.  

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
