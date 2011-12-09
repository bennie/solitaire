#!/usr/bin/perl -Ilib

# need to make the first element of an array (0) to always be the top
# of any stack as it might sit on the table

use Card;
use strict;

my $debug = 3;

my $deck = Card->new();

my %table;
&deal_table();

while ( &draw_hand ) {
  my $count = 0;
  while ( &move_aces()    ) { &flip_all_cards(); $count++; }
  $count = 0 and &debug_table() if $count;
  while ( &move_tableau() ) { &flip_all_cards(); $count++; }
  $count = 0 and &debug_table() if $count;

  while ( &play_card_in_hand() ) { &flip_all_cards(); $count++; }
  $count = 0 and &debug_table() if $count;
}

### Subroutines

=head2 deal_table()

Deals out the cards for a standard solitaire starting position.

=cut

sub deal_table {
  for my $col ( 1 .. 7 ) { $table{$col}{showing} = []; }
  for ( my $start = 1; $start < 8; $start++ ) {
    for my $col ( $start .. 7 ) {
      my $card = $deck->draw();
      unshift @{$table{$col}{hidden}}, $card;
    }
  }
  $table{AC} = [];
  $table{AD} = [];
  $table{AH} = [];
  $table{AS} = [];
  for ( 1 .. 3 ) {
    my $card = $deck->draw();
    unshift @{$table{hand}}, $card;
  }
  $table{discard} = [];

  &flip_all_cards();
  &debug_table() if $debug;
}

=head2 debug_table()

Displays the current standing of the table

=cut

sub debug_table {
  return undef unless $debug > 1;
  print STDERR "\n";
  for my $col ( 1 .. 7 ) {
    print STDERR "Tableau $col : (", join(',',  @{$table{$col}{hidden}}), ") ",
                 join(',',  @{$table{$col}{showing}}), "\n";
  }
  for my $ace ( qw/AC AD AH AS/ ) {
    print STDERR "Ace $ace : ", join(', ', @{$table{$ace}}), "\n";
  }
  print STDERR "In Hand : ", join(', ', @{$table{hand}}), "\n";
  print STDERR "In Discard : ", join(', ', @{$table{discard}}), "\n\n";
}

=head2 draw_hand()

Discards the current hand and draws three cards. Returns the number of cards drawn

=cut

sub draw_hand {
  while ( scalar(@{$table{hand}}) > 0 ) {
    push @{$table{discard}}, shift @{$table{hand}};
  }
  for ( 1 .. 3 ) {
    my $card = $deck->draw();
    next unless $card;
    unshift @{$table{hand}}, $card;
  }
  print STDERR "Drawing cards\n" if $debug;

  return scalar(@{$table{hand}});
}

=head2 flip_all_cards()

Goes through the table and turns over the top card on any un-turned stacks.

=cut

sub flip_all_cards {
  for my $col ( 1 .. 7 ) {
    if ( scalar(@{$table{$col}{showing}}) == 0 and scalar(@{$table{$col}{hidden}}) > 0 ) {
      push @{$table{$col}{showing}}, shift @{$table{$col}{hidden}};
    }
  }
  &debug_table() if $debug;
}

=head2 need_aces()

Returns a hash or hashref keyed by the cards that are currently needed on 
the ace stacks. The value for that key is the stack on which it belongs.

=cut

sub need_aces {
  my %need;
  for my $stack ( qw/AC AD AH AS/ ) {
    $need{$stack} = $stack and next unless scalar(@{$table{$stack}}) > 0;
    my ($value,$suit) = split '', $table{$stack}[0];
    next if $value eq 'K';
    my $new = $value eq 'A' ? '2'
            : $value =~ /^[2-8]$/ ? $value + 1
            : $value eq '9' ? '0'
            : $value eq '0' ? 'J'
            : $value eq 'J' ? 'Q'
            : $value eq 'Q' ? 'K'
            : $value; # ERROR!
    warn "Error computing next ace value based on $table{$stack}[0]\n" if $new eq $value;
    $need{$value.$suit} = $stack;
  }
  print "Need Aces: ", join(', ', keys %need), "\n" if $debug > 2;
  return wantarray ? %need: \%need;
}

=head2 need_tableau()

Given a card, returns an arrayref of the two cards it can sit upon on the 
tableau.

=cut

sub need_tableau {
  my $card = shift @_;
  my ($value,$suit) = split '', $card, 2;

  return [] if $value eq 'K';

  my $newval = $value =~ /^[2-8]$/ ? $value + 1
             : $value eq 'A' ? '2'
             : $value eq '9' ? '0'
             : $value eq '0' ? 'J'
             : $value eq 'J' ? 'Q'
             : $value eq 'Q' ? 'K'
             : $value; # ERROR!
  if ( $suit eq 'C' or $suit eq 'S' ) {
    return [ $newval.'D', $newval.'H' ];
  } elsif ( $suit eq 'D' or $suit eq 'H' ) { 
    return [ $newval.'C', $newval.'S' ];
  } else { die "Can't parse suit in &need_tableau()" }
}

=head2 move_aces() 

Checks all currently showing cards and the hand to see if any of them 
can be put on the aces and then moves them there, returning the number of 
cards moved.

=cut

sub move_aces {
  my $need  = &need_aces();
  my $count = 0;
  for my $needed ( keys %$need ) {
   # Table
   for my $col ( 1 .. 7 ) {
      if ( $table{$col}{showing}->[0] eq $needed ) {
        push @{$table{$need->{$needed}}}, shift @{$table{$col}{showing}};
        print STDERR "MOVE: $needed from $col to $need->{$needed}\n" if $debug > 1;
        $count++;
      }
    }
    # Hand
    if ( $table{hand}->[0] eq $needed ) {
      push @{$table{$need->{$needed}}}, shift @{$table{hand}};
      print STDERR "MOVE: $needed from the hand to $need->{$needed}\n" if $debug > 1;
      $count++;
    }
     
  }
  print STDERR "No acestack cards to move.\n";
  return $count;
}

sub move_tableau {
  for my $col ( 1 .. 7 ) {
    next if scalar(@{$table{$col}{showing}}) < 1; 
    my $card = $table{$col}{showing}->[-1];
    my $test = &need_tableau($card);
    for my $test_card ( @$test ) {
      #print STDERR "$card on the top of the column $col needs $test_card\n";
      for my $check_col ( 1 .. 7 ) {
        next if $col == $check_col; # Don't apply this card to itself
        next unless $test_card eq $table{$check_col}{showing}->[0];
        print STDERR "Moving tableau stack on $card (needing $test_card) to $table{$check_col}{showing}->[0].\n";
        my @lift = @{$table{$col}{showing}};
        $table{$col}{showing} = [];
        push @{$table{$check_col}{showing}}, @lift;
        return 1;
      }
    }
  }
  print STDERR "No cards to move on the tableau\n";
  return 0;
}

sub play_card_in_hand {
  if ( scalar(@{$table{hand}}) < 1 ) {
    print STDERR "Hand empty\n";
    return 0;
  }

  my $handcard = $table{hand}->[0];
  my $desired = &need_tableau($handcard);
  for my $col ( 1 .. 7 ) {
    next if scalar(@{$table{$col}{showing}}) < 1; 
    my $card = $table{$col}{showing}->[0];
    for my $desired_card ( @$desired ) {
      next unless $card eq $desired_card;
      print STDERR "Moving hand card $handcard (needing $desired_card) to $table{$col}{showing}->[0]?\n";      
      my $lift = shift @{$table{hand}};
      push @{$table{$col}{showing}}, $lift;
      return 1;
    }
  }
  print STDERR "No cards to move from the hand\n";
  return 0;
}