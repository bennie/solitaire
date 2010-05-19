#!/usr/bin/perl -Ilib -I/Users/phil/lib

use Term::Activity;
use Card;

use strict;

my $c = new Card;
my $ta = new Term::Activity 'deck test';

for ( 1 .. 250000 ) {
  my $deck1 = join('',$c->deck());

  # Deal out the deck to discard
  while ( my $draw = $c->draw() ) {
    $c->discard($draw);
  }

  $c->flip();

  my $deck2 = join('',$c->deck());

  die "Bad deck!" unless length($deck1) == 104 and $deck1 eq $deck2;

  $ta->tick;
  $c->shuffle;
}
