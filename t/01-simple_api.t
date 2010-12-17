use strict;
use warnings;
use lib 't/lib';
use Test::More;
use Catalyst::Test 'Simple';
use HTTP::Request::Common ();
use MooseX::Declare;
use Try::Tiny;

my ( $res, $c ) = ctx_request('/');

my $class = 'Simple';
my $api_model_class = class {

        extends 'Catalyst::Model';

        with 'SimpleAPI::Agent';

        sub do_request {
            my ( $self, $method, $uri, $data ) = @_;
            my $req_method = 'HTTP::Request::Common::' . $method;
            {
                no strict 'refs';
                if ( $method eq 'GET' ) {
                    $uri->query_form($data);
                    return Catalyst::Test::local_request(
                        $class, &$req_method($uri)
                    );
                }
                elsif ( $method eq 'POST' ) {
                    return Catalyst::Test::local_request(
                        $class, &$req_method($uri, $data)
                    );
                }
                else {
                    confess "$method not supported";
                }
            }
        }

};
my $api_model = $api_model_class->name->new($c, {
    api_key => 'AE281S228D4',
    application_id => 'simple-test',
    api_base_url => $c->req->base->as_string,
});

$res = $api_model->request('/api/foo', { value => 10 });
ok(exists $res->{'results'}{'value'});
ok($res->{'results'}{'value'} == 10);

try {
    $res = $api_model->request('/api/return_error', { value => 10 });
}
catch {
    like $_->{'general'}[0], qr{Error in API};
};

try {
    $res = $api_model->request('/api/foo', { value => 10 }, 'HEAD');
}
catch {
    like $_, qr{HEAD not supported};
};

done_testing;
