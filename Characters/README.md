## How to use

When making a new creature/character:
- Make a folder with the name of the creature
- Create an inherited scene from GenericCharacter.tscn
- Attach a script that extends GenericCharacterController.gd
- Override handleMove(), handleJump(), etc. to define how the creature moves and its abilities (use super() to reuse the contents of the functions in the generic script) 
- Add whatever else is needed
