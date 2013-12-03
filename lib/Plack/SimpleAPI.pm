package Plack::SimpleAPI;
use strict;
use warnings;
use Plack::Request;
use Plack::Util::Accessor qw( req auth_config response authorization );

our $VERSION = "0.01";

sub new {
    my ( $class, $env, $args ) = @_;
    $args ||= +{};
    bless {
        response  => {},
        req       => Plack::Request->new($env),
        %$args,
    }, $class;
}

sub prepare_api_request {
    my ($self) = @_;

    ## This sets the default response as a failure.
    $self->make_default_response;

    my $params = $self->req->parameters;
    my $provided_authkey = $params->{'authkey'} || 'unknown';
    my $authkey_ip_check;
    my $auth_config = $self->auth_config;
    if ( exists( $auth_config->{$provided_authkey} ) ) {
        $self->authorization($auth_config->{$provided_authkey});
        if ( exists( $auth_config->{$provided_authkey}{'ip_check'} ) ) {
            $authkey_ip_check = $auth_config->{$provided_authkey}{'ip_check'};
        }
        else {
            $authkey_ip_check = $auth_config->{$provided_authkey};
        }
    }

    if ( defined($authkey_ip_check)
        && ( $self->req->address =~ /$authkey_ip_check/ ) )
    {
        my $valid_apps
            = $self->authorization->{'valid_applications'};
        unless ( $params->{'application'} =~ m/$valid_apps/i ) {
            $self->make_error_api_response('Authorization failed');
            return 0;
        }
        return 1;
    }
    else {
        $self->make_error_api_response('Service not available, check your configuration'),
        return 0;
    }
}

sub return_api_data {
    my ( $self ) = @_;
    my $jsonobject = JSON::Any->new;
    my $responsetext = $jsonobject->encode($self->response);
    return [200, ['Content-Type' => 'application/json; charset=utf-8'], [$responsetext]];
}

sub make_default_response {
    my ($self) = @_;
    $self->response({
        processed => 0,
        status    => 'failed',
        data      => {},
    });
}

sub make_error_api_response {
    my ( $self, $error ) = @_;
    $self->response({
        processed => 0,
        status => 'failed',
        errors => {
            general => [
                $error,
            ],
       },
    });
}

sub make_unrecoverable_error_api_response {
    my ($self, $error) = @_;
    $self->make_error_api_response('An unrecoverable error occurred: ' . $error);
}


1;

__END__

=pod

=head1 NAME

Plack::SimpleAPI - 

=head1 SYNOPSIS

    Plack::SimpleAPI - 

=head1 DESCRIPTION

=head1 Method

=head2 new

=over 4

=item B<arg>

hoge

=back

=head1 PREREQUISITES

C<Class::Accessor::Lite>

=head1 Author

 Yusuke Wtase <ywatase@gmail.com>

=cut
