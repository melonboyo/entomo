$BUTLER = "$env:APPDATA\itch\apps\butler\butler.exe"
$USERNAME = 'melonboyo'
$GAME = "gofrog-bigmode-2"

& $BUTLER push web "$USERNAME/${GAME}:web"
& $BUTLER push win64 "$USERNAME/${GAME}:windows"
& $BUTLER push linux64 "$USERNAME/${GAME}:linux-universal"
#& $BUTLER push macOS "$USERNAME/${GAME}:osx"
