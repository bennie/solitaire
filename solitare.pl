#!/usr/bin/perl -Ilib

use Card;
use strict;

my $debug = 2;

my $deck = new Card;

my %table;
&deal_table();

&flip_all_cards();
1 while &move_aces();

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
}

=head2 debug_table()

Displays the current standing of the table

=cut

sub debug_table {
  return undef unless $debug > 2;
  for my $col ( 1 .. 7 ) {
    print STDERR "Hidden $col : ", join(',',  @{$table{$col}{hidden}}), "\n";
    print STDERR "Showing $col : ", join(',',  @{$table{$col}{showing}}), "\n";
  }
  for my $ace ( qw/AC AD AH AS/ ) {
    print STDERR "Ace Stack : ", join(', ', @{$table{$ace}}), "\n";
  }
  print STDERR "In Hand : ", join(', ', @{$table{hand}}), "\n";
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

Returns a hash or hasref keyed by the cards that are currently needed on 
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
  return $count;
}
