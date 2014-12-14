#! /usr/bin/perl
#
# sons-and-daughters
#
# Run a toy Monte-Carlo simulation of births, investigating the ratio
# of sexes born under different assumptions.
#
# Created by M J Oldfield
# 8.xi.2009
#

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

my $N_fam      = 100000;
my $bias       = 0.0;
my $multi_sons = 0;
my $max_kids   = 0;

my $usage;

GetOptions(
           "n_samples=i",     \$N_fam,
           "bias=f",          \$bias,
           "multi_sons!",     \$multi_sons,
           "max_kids=i",      \$max_kids, 

           "help|info|usage", \$usage,
          );

pod2usage( -verbose => 2 ) if $usage;

die "--bias must be between 0 and 1, "
  unless 0.0 <= $bias && $bias <= 1.0;

die "If --multisons is specified, so must --max_kids=N, "
  if $multi_sons && $max_kids <= 0;

my $n_boys  = 0;
my $n_girls = 0;
my %n_dom;
my %n_sig;
foreach my $n_fam (1 .. $N_fam)
  {
    my $m_boys  = 0;
    my $m_girls = 0;

    # Pick a boy/girl threshold for this particular family:
    # Each child will be a boy if the random sample is below the threshold.
    my $thresh  = 0.5 * (1.0 + $bias * (rand() < 0.5 ? 1 : -1));
    do
      {
        if (rand() < $thresh) { $m_boys++;  }
        else                  { $m_girls++; }
      } until (!$multi_sons  && $m_boys > 0)
           || ($max_kids > 0 && ($m_boys + $m_girls) >= $max_kids);
                               
    $n_boys  += $m_boys;
    $n_girls += $m_girls;

    my $sig = sprintf "(%d,%d)", $m_boys, $m_girls;
    $n_sig{$sig}++;
    
    my $dom = $m_boys > $m_girls ? "B"
            : $m_boys < $m_girls ? "G"
            :                      "E";   

    $n_dom{$dom}++;
  }
        
my $n_kids = $n_boys + $n_girls;
printf "Simulating %d families...\n", $N_fam;

printf "  - Multiple sons are %s.\n", $multi_sons ? "allowed" : "disallowed";

printf "  - The family size is limited to %d children.\n", $max_kids
  if $max_kids;

printf "Results:\n"
     . "  Male fraction             % .1f%%\n"
     . "  < boys/family >           % .3f\n"
     . "  < girls/family >          % .3f\n"
     . "  < b - g/family >          % .3f\n"
     . "  < kids/family >           % .3f\n"
     . "  families with more boys:  % .1f%%\n"
     . "  families with more girls: % .1f%%\n"
     . "  families with balance:    % .1f%%\n",  
  $n_boys  / $n_kids * 100.0,
  $n_boys  / $N_fam,
  $n_girls / $N_fam,
  ($n_boys - $n_girls) / $N_fam,
  $n_kids  / $N_fam,
  $n_dom{B} / $N_fam * 100.0,
  $n_dom{G} / $N_fam * 100.0,
  $n_dom{E} / $N_fam * 100.0,
  ;

print "\nFamily signatures:\n"
    , map  { sprintf("%8s: %6d %.1f%%\n", $_, $n_sig{$_}, $n_sig{$_} / $N_fam * 100.0) }
      sort { $n_sig{$b} <=> $n_sig{$a} }
      keys %n_sig
    ;

__END__

=head1 NAME
 
sons-and-daughters - Investigate how the sex-ratio changes under odd assumptions
 
=head1 USAGE

  sons-and-daughters 

  sons-and-daughters --n_samples=100000 --genf=0.2
 
=head1 DESCRIPTION
 
The main role of this program is to simulate births in families where
the parents choose to stop having kids as soon as they've had a
son. That is families will always have one son and zero or more
daughters.

There's a bizarre misapprehension that this will cause some asymmetry
between boys and girls in the total number of births, despite assuming
that at each birth the mother is equally likely to produce a boy or a
girl.

Moving beyond this, the program introduces an extra twist: in every
family we'll assume that genetics picks a random probability of having
a son. In itself this doesn't introduce a bias: a family is equally
likely to produce more boys than girls as the converse. However, the
effect interacts with waiting for a son with the nett effect that more
girls than boys will be born.

=head1 OPTIONS

=over

=item --n_samples=N

Unsurprisingly the program investigates by generating random families,
and counting how many kids are in each.  This option just sets the
number of families we generate: 100,000 takes a fraction of second on
my laptop.

=item --bias=0.2

Set the scale of the 'bias effect'. If bias is 0 then all births will
have an equal chance of being a boy or a girl. Conversely if genf is
1, each family will either always have boys or always have girls.
Intermediate values moderate the effect: 0.5 means that each family's
will either have about one quarter boys and three quarters girls, or
vice versa.

=item --multi_sons

Remove the constraint that families will stop having children when the
first boy comes along. If this is set, all families will have
C<--max_kids=N> children, which implies that this must be set!

=item --max_kids=N

Make each family stop having children when they've had this many
children. It's probably most useful in combination with
C<--multi_sons>.

=back 
 
=head1 BUGS AND LIMITATIONS

There are no known bugs in this application.

Please report problems to the author.

Patches are welcome.
 
=head1 AUTHOR

M J Oldfield, ex-atalier@mjo.tc
 
=head1 LICENCE AND COPYRIGHT
 
Copyright (c) 2009 M J Oldfield. All rights reserved.
 
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 


