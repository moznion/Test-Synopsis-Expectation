requires 'Compiler::Lexer', '0.17';
requires 'Pod::Simple::Methody';
requires 'Test::Builder::Module';
requires 'Test::More', '0.98';
requires 'parent';
requires 'perl', '5.008005';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'Test::More', '0.98';
};
