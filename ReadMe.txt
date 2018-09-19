8/05/2018
Inspired by https://www.instructables.com/id/Literary-Clock-Made-From-E-reader/

Works.
• Mac App. LitClock
• Mac Screensaver. LitSaver
• iOS app. LitClock_iOS
• tvOS app. LitClock_TV

When there a range of possible quotes it cycles through them.
tvOS/iOS app disables the auto-background.
Transition animation: added boss to manage the animation, and holder view to contain it.
Uses a one-shot timer to start the repeating timer on the start of the minute. Resynchronizes after running for a day.
9/09/2018
core animation, cross-platform pan animation in mac, screensaver.
I made it write to the macOS dock icon, but the result was too small to read, so I removed that code.

TODO:
tvOS icons.

watch app?

Which times have bad quotes?
Which have mediocre quotes?
Code up the smart quote algorithm on the file and run it.

# Building

1) Start by editing account.xcconfig. It currently says:

ACCOUNT=com.example

change that to your bundle prefix: the one on your developer account. Example:

ACCOUNT=com.mycompany

