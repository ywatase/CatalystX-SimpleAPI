use strict;
use warnings;
use lib 't/lib';
use Test::More;
use HTTP::Request::Common ();
use MooseX::Declare;
use Try::Tiny;
use utf8;

BEGIN {
    use_ok 'Catalyst::Test', 'Simple';
}

my ( $res, $c ) = ctx_request('/');

my $class = 'Simple';
my $api_model_class = class {

        extends 'Catalyst::Model';

        with 'SimpleAPI::Agent';

        sub _get_request {
            my ( $self, $uri, $data ) = @_;
            $uri->query_form($data);
            return Catalyst::Test::local_request(
                $class, HTTP::Request::Common::GET($uri)
            );
        }

        sub _post_request {
            my ( $self, $uri, $data ) = @_;
            return Catalyst::Test::local_request(
                $class, HTTP::Request::Common::POST($uri, $data)
            );
        }

};
my $api_model = $api_model_class->name->new($c, {
    api_key => 'AE281S228D4',
    application_id => 'simple-test',
    api_base_url => $c->req->base->as_string,
});

my $param = {
    value => { foo => 'áçéò' },
};
$res = $api_model->request('/api/foo', $param);
is_deeply($res, $param->{'value'});

done_testing;
