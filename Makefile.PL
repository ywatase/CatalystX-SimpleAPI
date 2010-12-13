use inc::Module::Install;

name     'CatalystX::SimpleAPI';
all_from 'lib/CatalystX/SimpleAPI.pm';
author   q{Jay Kuri <jayk@cpan.org>};
license  'perl';
repository 'git://github.com/wreis/CatalystX--SimpleAPI.git';

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

if ($Module::Install::AUTHOR) {
    system("pod2text lib/CatalystX/SimpleAPI.pm > README")
        and die $!
}

auto_install;

WriteAll;
