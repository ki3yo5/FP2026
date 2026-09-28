* appendTagVal.inc
* args: %1 = tag string, %2 = value

$ifthen not %2==0
$ifthen %SUF%==""
$setglobal SUF %1%2
$else
$setglobal SUF %SUF%_%1%2
$endif
$endif
