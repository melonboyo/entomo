# Entomo
Game project for Agile Development Processes at University of Gothenburg

## How to export and update on Itchio

### Install butler (skip if you already have butler installed)
- Install the Itch desktop app
- In the app, install butler (https://itchio.itch.io/butler)

### Export
- Create two folders in /Exports with the names "win64" and "linux64" respectively
- In Godot, go to Project -> Export... -> Export all -> Release
- The executables can now be found in the folders that you created

### Update the game with butler (if you are a collaborator on the game's itch page)
- Run the push.ps1 file in Powershell (located in /Exports folder)
