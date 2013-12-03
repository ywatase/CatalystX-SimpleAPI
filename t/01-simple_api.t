use strict;
use warnings;
use lib 't/lib';
use Try::Tiny;
use Test::More;
BEGIN {
    use_ok 'Plack::Test';
}

use Simple::Agent;
use Simple;

my $api_model = Simple::Agent->new({
    api_key => 'AE281S228D4',
    application_id => 'simple-test',
    api_base_url => 'http://localhost',
});

my $param = {
    value => {
        bar => 1,
        baz => 1,
    },
};
my $res = $api_model->request('/api/foo', $param);
is_deeply($res, $param->{'value'});

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
