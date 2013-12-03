use inc::Module::Install;
use Module::Install::ReadmeFromPod;
use Module::Install::AuthorTests;
use Module::Install::CPANfile;

name     'Plack-SimpleAPI';
all_from 'lib/CatalystX/SimpleAPI.pm';
author   q{Jay Kuri <jayk@cpan.org>};
readme_from;
repository 'git://github.com/ywatase/CatalystX-SimpleAPI.git';

author_tests('t/author');

auto_install;
cpanfile;

WriteAll;
