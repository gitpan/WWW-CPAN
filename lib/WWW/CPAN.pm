
package WWW::CPAN;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.002';

use Class::Constructor::Factory 0.001;
use parent qw( Class::Accessor Class::Constructor::Factory );

my $FIELDS = {
  host   => 'search.cpan.org',
  ua     => defer { # default useragent
              my %options = ( agent => 'www-cpan/' . $VERSION, );
              require LWP::UserAgent;
              return LWP::UserAgent->new( %options );
            },
  loader => defer { # default loader
              require JSON::Any;
              JSON::Any->import; # XXX JSON::Any needs this
              return JSON::Any->new;
            },
};

__PACKAGE__->mk_constructor0( $FIELDS );
__PACKAGE__->mk_accessors( keys %$FIELDS );

use Carp qw( carp );

my $default;
sub _default_object {
  if ( !$default ) {
    $default = __PACKAGE__->new();
  }
  return $default;
}

# adapted from Test::Base
sub _find_my_self {
  my $self = shift;
  $self = _default_object() if !ref($self);
  return $self, @_;
}

sub _build_distmeta_uri {
  my $self = shift;
  my $params = shift;

  if ( ! ref $params ) {
    $params = { dist => $params };
  }
  require URI;
  my $uri = URI->new();
  $uri->scheme('http');
  $uri->authority( $self->host );
  my @path = qw( meta );
  if ( $params->{author} ) {
    push @path, $params->{author};
  }

  my $dist = $params->{dist};
  if ( $params->{version} ) {
    $dist .= '-' . $params->{version};
  }
  push @path, $dist;

  push @path, 'META.json'; # XXX support YAML as well
  $uri->path_segments(@path);

  return $uri;
}

sub _load_json {
  my $self = shift;
  my $json = shift;
  return $self->loader->Load($json);
}

sub fetch_distmeta {
  (my $self, @_) = _find_my_self(@_);
  my $uri = $self->_build_distmeta_uri(@_);
  my $r = $self->ua->get($uri);
  if ( $r->is_success ) {
    return $self->_load_json( $r->content );
  } else {
    carp $r->status_line; # FIXME needs more convincing error handling
    return;
  }
}

"I didn't do it! -- Bart Simpson";
