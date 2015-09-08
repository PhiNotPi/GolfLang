print "Version 0-1\n";

my %ops = (
    '[' => 'push@m,\&startarray;',
    ']' => '$r=[];for(1..~~@m){$a=pop@m;if($a eq \&startarray){last}unshift@{$r},$a}push@m,$r;',
    ':' => '&inclistlevel($m[$#m]);',
    '*' => '&performop(\&mult);',
    '+' => '&performop(\&add);',
    '/' => '&performop(\&div);',
    '-' => '&performop(\&sub);',
    '^' => '&performop(\&exp);',
    'c' => '&performop(\&splitchars);',
    '=' => '&performop(\&stringeq);',
    '_' => 'push @m,$a=<>;',
    '`' => 'print &fancyprint(pop@m);',
    '|' => 'push(@activemods,"reduce");',
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

    $compiled .= 'print &basicprint(@m);';

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

sub startarray{
  return @_;
}

sub splitchars{
  local @a = split(//,$_[0]);
  return \@a;
}

sub stringeq{
  if($_[0] eq $_[1]){
    return 1;
  }
  return 0;
}

sub mult {
  local @items = @_;
  #print &basicprint($items[0])," * ",&basicprint($items[1]),"\n";
  return $items[0] * $items[1];
}

sub add {
  local @items = @_;
  #print &basicprint($items[0])," + ",&basicprint($items[1]),"\n";
  return $items[0] + $items[1];
}

sub sub {
  local @items = @_;
  #print &basicprint($items[0])," - ",&basicprint($items[1]),"\n";
  return $items[0] - $items[1];
}

sub div {
  local @items = @_;
  #print &basicprint($items[0])," / ",&basicprint($items[1]),"\n";
  return $items[0] / $items[1];
}

sub exp {
  local @items = @_;
  #print &basicprint($items[0])," ^ ",&basicprint($items[1]),"\n";
  return $items[0] ** $items[1];
}

sub inclistlevel {
  local @items = @_;
  for $item (@items){
    if($listlevel{$item} > 0){
      if(ref($item) eq "ARRAY"){
        &inclistlevel(@{$item});
      }
    }
    else{
      $listlevel{$item}++;
    }
  }
  return @items;
}

sub swap {
  local $b = pop @m;
  local $a = pop @m;
  push@m,$b;
  push@m,$a;  
}

%listlevel;


sub basicprint {
 local @itemlist = @_;
 local $res = "";
 for $item (@itemlist){
   if(ref($item) eq "ARRAY"){
     for $subitem (@{$item}){
       $res .= &basicprint($subitem);
     }
   }
   else{
     $res .= $item;
   }
 }
 return $res;
}

sub fancyprint {
 local @itemlist = @_;
 local $res = "";
 if(~~@itemlist > 1){
  for $item (@itemlist){
   $res .= fancyprint($item) . " ";
  }
  chop $res;
  return $res;
 }
 elsif(ref($itemlist[0]) eq "ARRAY"){
  $res .= "[";
  for $item (@{$itemlist[0]}){
   $res .= fancyprint($item) . " ";
  }
  chop $res;
  return $res."]";
 }
 else{
  return $itemlist[0];
 }
}

sub maxdepth {
 #print "A";
 local $item = $_[0];
 if(ref($item) eq "ARRAY"){
   local $max = 0;
   for $subitem (@{$item}){
     local $depth = &maxdepth($subitem);
     if($depth > $max){
       $max = $depth;
     }
   }
   return $max + 1;
 }
 else{
   return 0;
 }
}


sub listfunc {
  #print "lf:",fancyprint(@_),"\n";
  
  local $depth = shift @_;
  local $func = shift @_;
  local @footprint = @{$footprints[$depth]};
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
      push(@results,&listfunc($depth,$func,@newitems));
    }
    return \@results;
  }
  
  local %neededdepths;
  for $loc (0..$#items){
    $neededdepths{$items[$loc]} = $footprint[$loc];
    #print $footprint[$loc],"\n";
  }
  
  if(local @listofarrays = grep {(&maxdepth($_) - $neededdepths{$_} > 0) && ($neededdepths{$_} >= 0)} @items){
    local $minlen = -1;
    for $item (@listofarrays){
      #print " @{$item}\n";
      if($minlen<0 || $#{$item}<$minlen){
        $minlen = $#{$item};
      }         
    }
    local @results;
    for $loc (0..$minlen){
      local @newitems;
      for $item (@items){
        if(grep {$_ eq $item} @listofarrays){
          push(@newitems,${$item}[$loc])
        }
        else{
          push(@newitems,$item);
        }
      }
      push(@results,&listfunc($depth,$func,@newitems));
    }
    return \@results;
  }
  else{
    return &applymods($depth,$func,@items);
  }
}

%acceptablemods = (
  \&mult => ["reduce"],
  \&add => ["reduce"],
  \&div => ["reduce"],
  \&sub => ["reduce"],
  \&exp => ["reduce"],
  \&stringeq => ["reduce"],
);

%defaultfootprint = (
  \&mult => [0,0],
  \&add => [0,0],
  \&div => [0,0],
  \&sub => [0,0],
  \&exp => [0,0],
  \&stringeq => [0,0],
  \&splitchars => [0],
  \&inclistlevel => [-1],
);

%modfootprints = (
  "reduce" => [-1],
);


sub performop {
  local $func = $_[0];
  @footprints = ();
  $footprints[0] = $defaultfootprint{$func};
  @chosenmods = ();
  @remainingmods = ();
  for $mod (@activemods){
    if(grep {$_ eq $mod} @{$acceptablemods{$func}}){
      unshift(@footprints,$modfootprints{$mod});
      push(@chosenmods, $mod);
    }
    else{
      push(@remainingmods,$mod);
    }
  }
  @activemods = @remainingmods;
  @operands = ();
  for(1..~~@{$footprints[0]}){
    unshift(@operands,pop@m);
  }
  #print fancyprint(@footprints)."\n";
  push(@m,&listfunc(0,$func,@operands));
}

sub applymods {
 local $depth = shift @_;
 local $func = shift @_;
 local @items = @_;
 if($depth < ~~@chosenmods){
   local $mod = $chosenmods[$depth];
   #print "- $mod\n";
   $depth++;
   if($mod eq "reduce"){
     if(ref($items[$#items]) ne "ARRAY"){
       return $items[$#items];
     }
     local @chosenarray = @{$items[$#items]};
     if(~~@{$footprints[$depth]} eq 1){
       @chosenarray = map {&listfunc($depth,$func,$_)} @chosenarray;
       $depth = ~~@chosenmods;
     }
     local $running = $chosenarray[0];
     for $loc (1..$#chosenarray){
       $running = &listfunc($depth,$func,$running,$chosenarray[$loc]);
     }
     return $running;
   }
 }
 else{
   #print "- none\n";
   return &{$func}(@items);
 }
}

@activemods = ();
@chosenmods = ();
@remainingmods = ();


'}
