# pubfinder_bot
A Telegram bot that locates nearby drinking establishments. The bot utilizes the telegram-bot-ruby (https://github.com/atipugin/telegram-bot-ruby) and google_places (https://github.com/qpowell/google_places) gems.

##Inline mode:

You can call the bot from anywhere using the Inline Bot functionality (https://telegram.org/blog/inline-bots), just type the bots name in any conversation, press space and it will search for pubs near your location. The first time you use this you will be asked if you want to share your location.

##Non-inline mode:

In a private chat you can request details of a random nearby pub using:

/pubme

You will be asked to send your location each time you use this.

In a group chat, or if you do not want to share your location, you can use:

/pubme [location]

e.g. '/pubme brixton'



