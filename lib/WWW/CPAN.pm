
package WWW::CPAN;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.004';

use Class::Constructor::Factory 0.001;
use parent qw( Class::Accessor Class::Constructor::Factory );

my $FIELDS = {
  host   => 'search.cpan.org',
  ua     => defer { # default useragent
              my %options = ( agent => 'www-cpan/' . $VERSION, );
              require LWP::UserAgent;
              return LWP::UserAgent->new( %options );
            },
  j_loader => defer { # json loader
              require JSON::Any;
              JSON::Any->import; # XXX JSON::Any needs this
              return JSON::Any->new;
            },
  x_loader => defer { # xml loader
              require XML::Simple;
              my %options = (
                  ForceArray => [qw( module dist match )],
                  KeyAttr    => [],
              );
              return XML::Simple->new( %options );
  },
};

__PACKAGE__->mk_constructor0( $FIELDS );
__PACKAGE__->mk_accessors( keys %$FIELDS );

use Class::Lego::Myself;
__PACKAGE__->give_my_self;

use Carp qw( carp );

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
  (my $self, @_) = &find_my_self;
  my $uri = $self->_build_distmeta_uri(@_);
  my $r = $self->ua->get($uri);
  if ( $r->is_success ) {
    return $self->_load_json( $r->content );
  } else {
    carp $r->status_line; # FIXME needs more convincing error handling
    return;
  }
}

# http://search.cpan.org/search?query=Archive&mode=all&format=xml
sub _build_query_uri {
  my $self = shift;
  my $params = shift;

  if ( ! ref $params ) {
    $params = { query => $params, mode => 'all', format => 'xml', };
  }
  require URI;
  my $uri = URI->new();
  $uri->scheme('http');
  $uri->authority( $self->host );
  my @path = qw( search );
  $uri->path_segments(@path);

  $params->{mode}   ||= 'all';
  $params->{format} ||= 'xml';
  $uri->query_form( $params );

  return $uri;
}
# other params: s (start), n (page size, should be <= 100)
# TODO fetch the entire result by default

sub _load_xml {
  my $self = shift;
  return $self->x_loader->XMLin( shift );
}

sub query {
  my $self = &find_my_self;
  my $uri = $self->_build_query_uri(@_);
  my $r = $self->ua->get($uri);
  if ( $r->is_success ) {
    return $self->_load_xml( $r->content );
  } else {
    carp $r->status_line; # FIXME needs more convincing error handling
    return;
  }
}

"I didn't do it! -- Bart Simpson";
