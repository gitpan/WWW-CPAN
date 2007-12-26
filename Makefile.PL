
use 5.006;
use ExtUtils::MakeMaker 6.31; # XXX yes, that's not a nice thing to do

WriteMakefile(
  NAME => 'WWW-CPAN',
  VERSION_FROM => 'lib/WWW/CPAN.pm',

  PREREQ_PM => {
    'strict'     => 0,
    'warnings'   => 0,

    'LWP::UserAgent'   => 0,
    'parent'           => 0,
    'Class::Accessor'  => 0,

    'JSON::Any'        => 0,

    'Test::More'       => 0,

  },
  LICENSE => 'perl',
  AUTHOR  => 'Adriano R. Ferreira <ferreira@cpan.org>',
  
);

