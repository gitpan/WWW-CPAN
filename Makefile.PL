
use 5.006;
use ExtUtils::MakeMaker 6.31; # XXX yes, that's not a nice thing to do

WriteMakefile(
  NAME         => 'WWW-CPAN',
  VERSION_FROM => 'lib/WWW/CPAN.pm',

  PREREQ_PM => {
    'strict'     => 0,
    'warnings'   => 0,

    'LWP::UserAgent'   => 0,
    'parent'           => 0,
    'Class::Accessor'  => 0,
    'Class::Constructor::Factory' => 0.001,
    'Class::Lego::Myself'         => 0.001,
    'Carp'             => 0,

    'JSON::Any'        => 0,
    'XML::Simple'      => 0,
    'Data::Dump::Streamer' => 0, # required by bin/cpanq

    'Test::More'       => 0,

  },
  # recommends => { 'Test::Script' => 0, }
  EXE_FILES     => [ 'bin/cpanq' ],
  LICENSE       => 'perl',
  AUTHOR        => 'Adriano R. Ferreira <ferreira@cpan.org>',
  ABSTRACT_FROM => 'lib/WWW/CPAN.pod',

);
