package Card;
$Card::VERSION='$Revision: 1.1 $';

use strict;

=head3 new()

Creates the Card object. It also creates a fresh deck and shuffles it for 
ready use. It also creates an  empty discard pile.

Internally the following values are created:

  $self->{deck}        : Array ref of the active deck (pre-shuffeled)
  $self->{discard}     : Array ref of discards
  $self->{valid_cards} : Hash ref of valid cards that may be in the deck 
                         or discarded.

=cut

sub new {
  my $self = {};
  bless $self;

  $self->{deck}    = [];
  $self->{discard} = [];

  for my $suit (qw/S C H D/) {
    for my $value (qw/A K Q J 0 9 8 7 6 5 4 3 2/) {
      push @{$self->{deck}}, $value.$suit;
    }
  }

  for my $card (@{$self->{deck}}) {
    $self->{valid_cards}->{$card} = 1;
  }

  $self->shuffle();

  return $self;
}

=head3 deck()

Returns an array or arraref of the current deck.

=cut

sub deck {
  my $self = shift @_;
  return wantarray ? @{$self->{deck}} : $self->{deck};
}

=head3 discard($card_value)

Discards the card into the discard pile. Throws a warning if you discard an 
invalid card.

=cut

sub discard {
  my $self = shift @_;
  my $card = shift @_;

  warn "$card is not a valid value to discard." unless $self->{valid_cards}->{$card};

  push @{$self->{discard}}, $card;
}

=head3 draw()

Returns the next card from the top of the deck.

=cut

sub draw {
  my $self = shift @_;
  return shift @{$self->{deck}};
}

=head3 flip()

Takes the discard pile and puts it under the current deck.

=cut

sub flip {
  my $self = shift @_;
  push @{$self->{deck}}, @{$self->{discard}};
  $self->{discard} = [];
}

=head3 shuffle()

Shuffles the deck. Does not effect the discard pile. You may wish to flip() 
before shuffling.

=cut

sub shuffle {
  my $self = shift @_;
  my @old_order = @{$self->{deck}};
  my @new_order = ();

  while (@old_order) {
    push(@new_order, splice(@old_order, rand(@old_order), 1))
  }

  $self->{deck} = [ @new_order ];
}

1;
