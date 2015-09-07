print "Version 0-1\n";

my %ops = (
    ']' => '$len=pop@m;$ref=[];for(1..$len){unshift(@{$ref},pop@m)};push(@m,$ref);',
    ':' => '$listlevel{$m[$#m]}++;',
    '*' => '$a=pop@m;$b=pop@m;push(@m,&listfunc(\&mult,$a,$b));',
    '+' => '$a=pop@m;$b=pop@m;push(@m,&listfunc(\&add,$a,$b));',
    '_' => 'push @m,$a=<>;',
    '`' => '&basicprint(pop@m);',
    ' ' => ' ',
);

my $repl = 0;

print 'Would you like to run each program more than once? (y/n) ';
chomp(my $response = <>);
$response = chop($response = reverse $response);
if($response eq "Y" || $response eq "y")
{
    $repl = 1;
}

my $showcompiled = 0;

print 'Would you like the "compiled" Perl code of every _______ program? (y/n) ';
chomp($response = <>);
$response = chop($response = reverse $response);
if($response eq "Y" || $response eq "y")
{
    $showcompiled = 1;
}

while(1)
{
    print "\nPROGRAM:\n";
    
    #these next few lines may be subject to system-dependent newline issues
    $/ = "\n\n";
    chop(my $original=<>);
    $/ = "\n";
    $original = reverse $original;
    
    
    my $compiled = &initialize;
    my $pushstring = "";
    while($original){
        my $char = chop $original;
        my $pushflag = 1;
        my $comp = "";
        if(exists $ops{$char}){
            $comp = $ops{$char} . "\n";
        }
        else {
            $pushflag = 0;
        }
        if($char eq '\\'){
            $char = chop $original;
        }
        if($pushflag==1 && $pushstring ne ""){
            $compiled .= 'push(@m,\'' . $pushstring . '\');' . "\n"; 
            $pushstring = "";
        }
        elsif($pushflag == 0){
            if($char eq "'" || $char eq '\\'){
                $char = '\\'.$char;
            }
            $pushstring .= $char;
        }
        $compiled .= $comp;
    }
    if($showcompiled){
        print "$compiled\n";
    }
    my $reps = 1;
    if($repl){
        print 'How many times to run? ';
        $reps = <>;
    }
    for(1..$reps){
        print "\nINPUT:\n";
        my @m;  #initialize variables for _______ program to run
        my @c;
        my %hash;
        eval $compiled;
    }
}

######################################################################################################################################

sub initialize{return '

sub mult {
  $_[0] * $_[1];
}

sub add {
  $_[0] + $_[1];
}

sub basicprint {
 local @itemlist = @_;
 for $item (@itemlist){
   if(ref($item) eq "ARRAY"){
     for $subitem (@{$item}){
       &basicprint($subitem);
     }
   }
   else{
     print $item;
   }
 }
}

sub listfunc {
  #print"@_\n";
  local $func = shift @_;
  local @items = @_;
  if(local @listoflists = grep {$listlevel{$_} > 0} @items){
    local @results;
    for $chose (@{$listoflists[0]}){
      local @newitems;
      for $item (@items){
        if($item eq $listoflists[0]){
          push(@newitems,$chose);
        }
        else{
          push(@newitems,$item);
        }
      }
      push(@results,&listfunc($func,@newitems));
    }
    return \@results;
  }
  elsif(local @listofarrays = grep {ref($_) eq "ARRAY"} @items){
    local $minlen = -1;
    for $item (@listofarrays){
      if($minlen<0 || $#{$item}<$minlen){
        $minlen = $#{$item};
      }         
    }
    local @results;
    for $loc (0..$minlen){
      local @newitems;
      for $item (@items){
        if(ref($item) eq "ARRAY"){
          push(@newitems,${$item}[$loc])
        }
        else{
          push(@newitems,$item);
        }
      }
      push(@results,&listfunc($func,@newitems));
    }
    return \@results;
  }
  else{
    return &{$func}(@items);
  }
}

'}
