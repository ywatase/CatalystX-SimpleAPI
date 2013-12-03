package Simple::Agent;
use Moose;
use HTTP::Request::Common;
with 'SimpleAPI::Agent';
use Plack::Test;
$Plack::Test::Impl = 'Server';

use Simple;
my $app = Plack::Test->create(Simple->psgi_app);

sub _get_request {
    my ( $self, $uri, $data ) = @_;
    $uri->query_form($data);
    return $app->request(GET $uri);
}

sub _post_request {
    my ( $self, $uri, $data ) = @_;
    return $app->request(POST $uri, $data);
}

1;
