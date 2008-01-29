
package App::WWW::CPAN;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.007';

use parent qw( Class::Accessor );

__PACKAGE__->mk_accessors(qw( cpan home cache ));

use WWW::CPAN ();
use Data::Dump::Streamer qw( Dump );
use Path::Class qw( dir file );

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
  return defined $val ? Dump( $val )->Out() : undef;
}

sub _home {
  require File::HomeDir;
  my $h = dir( File::HomeDir->my_home, '.cpanq' );
  $h->mkpath( 0, 0744 ); # quiet, rwxr--r--
  return $h;
}

sub _cache {
  my $self = shift;
  require Cache::File;
  return Cache::File->new( 
              cache_root => dir( $self->home, 'cache' ),
              default_expires => '10 minutes',
  );
}

# save last arguments and answer
sub _store {
  my $self = shift;
  my $args = shift;
  my $answer = shift;

  my $k = "@{$args}";
  $self->cache->set( $k, $answer );

}

# retrieve last answer if args are the same
sub _retrieve {
  my $self = shift;
  my $args = shift;

  my $k = "@{$args}";
  return $self->cache->get( $k );

}

my %method_for = (
   'meta'  => 'fetch_distmeta',
   'query' => 'query',
);

sub run {
  my $self = shift;
  $self->home( _home );
  $self->cache( $self->_cache );
  $self->cpan( WWW::CPAN->new );

  if ( defined( my $c = $self->_retrieve( \@_ ) ) ) {
    #warn "cache hit\n";
    print $c;
    return;
  }
  my $cmd = shift;
  if ( exists $method_for{$cmd} ) {
    my $cmd_args = $self->parse_args(@_);
    my $ans = $self->do_cmd( $method_for{$cmd}, $cmd_args );
    if ( defined $ans ) {
      $self->_store( [ $cmd, @_ ], $ans );
      print $ans;
    }
  } else {
    die "unsupported command: $cmd\n";
  }
}

1;
