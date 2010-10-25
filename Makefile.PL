use inc::Module::Install;
name 'Scope-Container';
all_from 'lib/Scope/Container.pm';

# requires '';
requires 'Log::Minimal';
requires 'Guard';
tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
