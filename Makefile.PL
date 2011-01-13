use inc::Module::Install;
use Module::Install::ReadmeFromPod;

name     'CatalystX-SimpleAPI';
all_from 'lib/CatalystX/SimpleAPI.pm';
author   q{Jay Kuri <jayk@cpan.org>};
readme_from;
repository 'git://github.com/wreis/CatalystX-SimpleAPI.git';

test_requires 'Test::More';
test_requires 'MooseX::Declare';
test_requires 'CatalystX::RoleApplicator';
test_requires 'Catalyst::TraitFor::Request::DecodedParams';

requires 'Catalyst::Runtime' => '5.80029';
requires 'Moose';
requires 'namespace::autoclean';
requires 'MooseX::MethodAttributes';
requires 'LWP::UserAgent';
requires 'JSON::Any';
requires 'URI';
requires 'Try::Tiny';

auto_install;

WriteAll;
