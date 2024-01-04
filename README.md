# Solitaire

A monte carlo solitaire simulator to test the effectiveness of playing solitaire.

## Project History

Starting in 2006, this project was something I used to work on while only "in the air."

When taking airline flights I used to bring a deck of cards to pass the time. I would play
solitare. Later as a tech professional, when flying, I would write code about solitare to
pass the time.

At some point, I got to "project bankruptcy" -- where it would take longer to "come up to
speed" on the codebase in a flight than most flights were.

So now the "only work on it in the air" idea has been jettisoned. Pardon the pun.

## What is solitaire?

A solo card-game. Called "patience" in Europe, in the US it is "Solitaire."

More info here:

https://en.wikipedia.org/wiki/Patience_(game)

## What do we want to test?

At several points in the game you have the option of what move to do first in front of others. Are any of these play-order techniques more effective:

* Always flipping the tableau first
* Always playing the tableau first
* Always playing the hand first
* Always move to ace first
* Combining the tableau first or conversly: only when required

A more complex variation to code might be:

* Remove from aces to try to place hand cards onto the tableau

## License

[MIT](https://choosealicense.com/licenses/mit/)