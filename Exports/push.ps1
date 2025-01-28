$BUTLER = "$env:APPDATA\itch\apps\butler\butler.exe"
$USERNAME = 'melonboyo'
$GAME = "entomo"

& $BUTLER push win64 "$USERNAME/${GAME}:windows"
& $BUTLER push linux64 "$USERNAME/${GAME}:linux-universal"
#& $BUTLER push macOS "$USERNAME/${GAME}:osx"
