# GolfLang

language and name subject to change without warning

feature list:
 - input
 - output
 - nested array creation via `]` which pops a number to serve as the array length and then groups those many items
 - multiplication/addition
 - foreach using `:`

Example:

    3 4 5 2]2]2 3 2]:*`

This creates the arrays `[3 [4 5]]` and `[2 3]` and then does a foreach on the second one, multiplies them,
giving a result of `[[6 [8 10]][9 [12 15]]]` which is printed as `681091215`
