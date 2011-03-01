package CatalystX::SimpleAPI;

our $VERSION = '0.04';

1;

__END__

=head1 NAME

CatalystX::SimpleAPI - Simple API support for Catalyst apps

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

    sub foo : Local {
        my ( $self, $c ) = @_;
        $c->stash(
            api_response => {
                processed => 1,
                status => 'success',
                data => {
                    results => $c->req->params,
                }
            },
        );
    }

    1;

    ...

    package MyApp::Model::ServiceApp; 

    use Moose;
    use namespace::autoclean;

    extends 'Catalyst::Model';

    with 'SimpleAPI::Agent';

    __PACKAGE__->config(
        api_key => 'AE281S228D4',
        application_id => 'myapp',
        api_base_url => 'http://localhost:5000/'
    );

    1;

    ...

    $c->model('ServiceApp')->request('/api/foo', { value => 10 });

=head1 DESCRIPTION

It provides a simple API support - currently only JSON based - for Catalyst
applications.

=head1 USAGE

In your actions, all your API arguments will have already been placed in
C<< $c->stash->{'api_params'} >>. Your API response will be placed in
C<< $c->stash->{'api_response'} >>. The C<api_response> hash should 
have the following structure.

    $c->stash->{'api_response'} = {
        # true / false value indicating the request was processed.
        processed => 0,

        # 'success' or 'failed' indicating whether the request was processed
        # successfully.
        status => 'failed',
    
        # hashref containing the results of the api action
        data => {},

        # error messages in the form of field => 'message' in the case of an error
        errors => {
            # 'general' should always be present to describe the overall error
            general => 'failed validation',

            # per-parameter error messaging if appropriate.
            ingredient => 'Ingredient is invalid.',
        },
    };

If you process your request, you should set C<processed> to B<1> even if the
request was did not have a successful result.  The C<processed> value is used to
indicate that the parameters were accepted and the action requested was attempted.
The C<status> value is used to indicate whether the requested action accomplished
what was requested.  The basic rule of thumb here is that C<processed> should only
be set to B<0> if the action could not be started for some reason (such as auth
failure or other exceptional condition.)  Note that if C<processed> is B<0>, C<status>
will ALWAYS be B<failed>.  

In your subclass, you will need to call the C<< $self->prepare_api_request($c) >> 
method to initialize the API request. This is usually done in the C<auto>
action or the root of the action chain.

=head1 SEE ALSO

L<Catalyst Advent Calendar 2009|http://www.catalystframework.org/calendar/2009/21>

=head1 AUTHOR

Jay Kuri (jayk) C<< <jayk@cpan.org> >>.

=head1 CONTRIBUTORS

Wallace Reis (wreis) C<< <wreis@cpan.org> >>.

=head1 SPONSORSHIP

Development sponsored by Ionzero LLC L<http://www.ionzero.com/>.

=head1 COPYRIGHT & LICENSE

Copyright (C) 2010 Jay Kuri and the above contributors.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
