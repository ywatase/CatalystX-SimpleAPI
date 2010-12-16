use inc::Module::Install;
use Module::Install::ReadmeFromPod;

name     'CatalystX-SimpleAPI';
all_from 'lib/CatalystX/SimpleAPI.pm';
author   q{Jay Kuri <jayk@cpan.org>};
license  'perl';
readme_from;
repository 'git://github.com/wreis/CatalystX-SimpleAPI.git';

test_requires 'Test::More';
test_requires 'MooseX::Declare';
test_requires 'Try::Tiny';

requires 'Catalyst::Runtime';
requires 'Moose';
requires 'namespace::autoclean';
requires 'MooseX::MethodAttributes';
requires 'JSON::XS';
requires 'LWP::UserAgent';
requires 'JSON::Any';
requires 'URI';

auto_install;

WriteAll;
