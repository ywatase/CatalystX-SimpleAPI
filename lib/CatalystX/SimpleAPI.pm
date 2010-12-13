package CatalystX::SimpleAPI;

our $VERSION = '0.01';

1;

__END__

=head1 NAME

CatalystX::SimpleAPI

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 USAGE

In your actions, all your API arguments will have already been placed in C<< $c->stash->{'api_params'} >>.
Your API response will be placed in C<< $c->stash->{'api_response'} >>.  The C<api_response> hash should 
have the following structure.

    $c->stash->{'api_response'} => {
        processed => 0,      # true / false value indicating the request was processed.
        
        status => 'failed',  # 'success' or 'failed' indicating whether the request was processed successfully.
        
        data => {},          # hashref containing the results of the api action
        
        errors => {           # error messages in the form of field => 'message' in the case of an error
                    general => 'failed validation' # 'general' should always be present to describe the overall error
                    ingredient => 'Ingredient is invalid.', # per-parameter error messaging if appropriate.
        }
    }

If you process your request, you should set C<processed> to B<1> even if the request was did not
have a successful result.  The C<processed> value is used to indicate that the parameters
were accepted and the action requested was attempted.  The C<status> value is used to indicate
whether the requested action accomplished what was requested.  The basic rule of thumb here
is that C<processed> should only be set to B<0> if the action could not be started for some reason
(such as auth failure or other exceptional condition.)  Note that if C<processed> is B<0>, C<status>
will ALWAYS be B<failed>.  

In your subclass, you will need to call the C<< $self->prepare_api_request($c) >> 
method to initialize the API request. This is usually done in the C<auto>
action or the root of the action chain. Note that authorization failure sets
up the response, but does B<NOT> send it to the browser. The example below
uses the end action to do that.  If you use C<< $self->return_api_data($c) >>
somewhere else, you will need to check the return value of
C<prepare_api_request> and ensure C<return_api_data> is called yourself.

Your basic SimpleAPI derived controller should look like this:

    sub auto : Private {
        my ( $self, $c ) = @_;

        # will return false if the api did not pass authorization.
        return $self->prepare_api_request($c);
    }

    sub end : Private {
        my ( $self, $c ) = @_;
        
        return $self->return_api_data($c);
    }



=head1 AUTHOR

Jay Kuri <jayk@cpan.org>

=head1 CONTRIBUTORS

Wallace Reis (wreis) C<< <wreis@cpan.org> >>.

=head1 SPONSORSHIP

Development sponsored by Ionzero LLC L<http://www.ionzero.com/>.

=head1 COPYRIGHT & LICENSE

Copyright (C) 2010 Jay Kuri and the above contributors.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
