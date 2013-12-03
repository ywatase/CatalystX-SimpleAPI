requires 'namespace::autoclean';
requires 'JSON::Any';

on test => sub {
    requires 'Catalyst::Runtime' => '5.90051';
    requires 'Try::Tiny';
    requires 'Test::More';
};

feature 'catalyst', 'Catalyst Controller' => sub {
    recommends 'MooX::Types::MooseLike';
    recommends 'MooseX::MethodAttributes::Role';
};

feature 'agent', 'agent' => sub {
    recommends 'Moo';
    recommends 'LWP::UserAgent';
    recommends 'URI';
};