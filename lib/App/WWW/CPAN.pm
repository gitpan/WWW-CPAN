
package App::WWW::CPAN;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.005';

use parent qw( Class::Accessor );

__PACKAGE__->mk_accessors(qw( cpan ));

use WWW::CPAN ();
use Data::Dump::Streamer qw( Dump );

sub parse_args {
  my $self = shift;
  my @args = @_;
  my %hash;
  for ( @args ) {
    if ( /\A ([^=]+) = (.*) \z/x ) {
      $hash{$1} = $2;
    } else {
      # FIXME warn if @args > 1
      return $_;
    }
  }
  return \%hash; 
}

sub do_cmd {
  my $self = shift;
  my $cmd  = shift;
  my $args = shift;
  my $val  = $self->cpan->$cmd( $args );
  Dump( $val );
}

my %method_for = (
   'meta'  => 'fetch_distmeta',
   'query' => 'query',
);

sub run {
  my $self = shift;
  $self->cpan( WWW::CPAN->new );
  my $cmd = shift;
  if ( exists $method_for{$cmd} ) {
    my $cmd_args = $self->parse_args(@_);
    $self->do_cmd( $method_for{$cmd}, $cmd_args );
  } else {
    die "unsupported command: $cmd\n";
  }
}


