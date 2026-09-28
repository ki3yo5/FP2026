* appendTag.inc
* args: %1 = tag string, %2 = flag (0/1)

$ifthen not %2==0
$ifthen %SUF%==""
$setglobal SUF %1
$else
$setglobal SUF %SUF%_%1
$endif
$endif
