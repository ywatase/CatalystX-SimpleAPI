use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'CatalystX::SimpleAPI';
    use_ok 'CatalystX::Controller::SimpleAPI';
    use_ok 'SimpleAPI::Agent';
    use_ok 'Plack::SimpleAPI';
}

done_testing;
