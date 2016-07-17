require 'telegram/bot'
require 'google_places'

telegram_token = ''
google_api_key = ''


Telegram::Bot::Client.run(telegram_token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      if ! defined? message.location.latitude || ! defined? message.location.longitude
        msg_content = Telegram::Bot::Types::InputTextMessageContent.new(
          message_text: 'I could not get your location'
        )
        msg = Telegram::Bot::Types::InlineQueryResultArticle.new(
          type: 'article',
          id: '1',
          title: 'Location not supplied',
          input_message_content: msg_content
        )
        results = [ msg ]
        bot.api.answer_inline_query(inline_query_id: message.id, results: results)
      else
        places = GooglePlaces::Client.new(google_api_key)
        results = places.spots(message.location.latitude, message.location.longitude, :radius => 500, :types => 'bar', :rankby => 'distance')
        results.delete_if {|bar| bar.types.include? 'restaurant'}
        puts results.length
        if results.length == 0
          msg_content = Telegram::Bot::Types::InputTextMessageContent.new(
            message_text: 'No results found in your vicinity'
          )
          msg = Telegram::Bot::Types::InlineQueryResultArticle.new(
            type: 'article',
            id: '1',
            title: 'Dry area!',
            input_message_content: msg_content
          )
          results = [ msg ]
          bot.api.answer_inline_query(inline_query_id: message.id, results: results)
        else
          results = results.map.with_index do |bar, index|
          puts "hello"
            Telegram::Bot::Types::InlineQueryResultVenue.new(
              type: 'venue',
              id: index,
              latitude: bar.lat,
              longitude: bar.lng,
              title: bar.name,
              address: bar.vicinity
            )
          end
          puts message.id
          puts results
          bot.api.answer_inline_query(inline_query_id: message.id, results: results)
        end
      end
    end
  end
end

