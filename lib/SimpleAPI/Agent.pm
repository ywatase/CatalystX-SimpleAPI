package SimpleAPI::Agent;

use Moose::Role;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use LWP::UserAgent;
use JSON::Any;
use URI;
use Data::Dumper;

has 'user_agent' => ( 
    isa => duck_type([qw/get post/]), is => 'ro',
    lazy => 1, builder => '_build_user_agent',
);

sub _build_user_agent { return LWP::UserAgent->new }
                
has 'api_key' => ( isa => 'Str', is => 'ro', required => 1 );

has 'application_id' => ( isa => 'Str', is => 'ro', required => 1 );

has 'api_base_url' => ( isa => 'Str', is => 'ro', required => 1 );

has 'json_decoder' => (
    isa => duck_type([qw/jsonToObj/]), is => 'ro',
    lazy => 1, builder => '_build_json_decoder',
);

sub _build_json_decoder { return JSON::Any->new }

sub request {
    my ( $self, $path, $data, $method ) = @_;
    $method = uc($method || 'POST');
    $data ||= {};
    $data->{'application'} = $self->application_id;
    if (!defined($data->{'authkey'})) {
        $data->{'authkey'} = $self->api_key;
    }
    my $base_url = $self->api_base_url;
    $base_url =~ s{/$}{}g;
    $path =~ s{^/}{}g;
    my $uri = URI->new(join(q{/}, $base_url, $path));

    return $self->handle_response(
        $self->do_request($method, $uri, $data)
    );
}

sub do_request {
    my ( $self, $method, $uri, $data ) = @_;
    my $req_method = q{_} . lc $method . '_request';
    if ( $self->can($req_method) ) {
        return $self->$req_method($uri, $data);
    }
    else {
        confess "$method not supported";
    }
}

sub _get_request {
    my ( $self, $uri, $data) = @_; 
    $uri->query_form($data);
    return $self->user_agent->get($uri);
}

sub _post_request {
    my ( $self, $uri, $data ) = @_; 
    return $self->user_agent->post($uri, $data);
}

sub handle_response {
    my ( $self, $response ) = @_;
    if ( $response->is_success ) {
        my $response_data = $self->json_decoder->jsonToObj($response->content);
        if ( (exists($response_data->{'processed'})
                && $response_data->{'processed'} == 0)
            || (exists($response_data->{'status'})
                && $response_data->{'status'} ne 'success') 
        ) {
            my @errors = values(%{$response_data->{errors}});
            confess join("\n", map @$_, @errors);
        } else {
            return $response_data->{'data'};
        }
    } else {
        confess 'Request to SimpleAPI failed: ' . $response->status_line;
    }
}

1;

__END__

=head1 NAME

=head1 DESCRIPTION

=head1 AUTHOR & LICENSE

See L<CatalystX::SimpleAPI>.

=cut