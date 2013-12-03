use strict;
use warnings;
use lib 't/lib';
use Test::More;
use Try::Tiny;
use utf8;

use Simple::Agent;

my $api_model = Simple::Agent->new({
    api_key => 'AE281S228D4',
    application_id => 'simple-test',
    api_base_url => 'http://localhost/',
});

my $param = {
    value => { foo => 'áçéò' },
};
my $res = $api_model->request('/api/foo', $param);
is_deeply($res, $param->{'value'});

done_testing;
