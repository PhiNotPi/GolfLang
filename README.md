# GolfLang

language and name subject to change without warning

feature list:
 - input `_`
 - output, either implicit or the fancier `` ` ``
 - nested array creation via `[` and `]`
 - multiplication/addition/division/subtraction/exponentiation/stringEquality/splitToChars
 - foreach using `:`

Example:

    3[4 5]][2 3]:*

This creates the arrays `[3 [4 5]]` and `[2 3]` and then does a foreach on the second one, multiplies them,
giving a result of `[[6 [8 10]][9 [12 15]]]` which is implicitly printed as printed as `681091215`

    _c]_c=||+

Given two inputs, a string and a character, outputs the number of occurances of that character in the string;
