require 'telegram/bot'
require 'google_places'

telegram_token = ''
@google_api_key = ''

def respond_inline_message(bot, message)
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
    results = return_random_pub(location: message.location, return_all: true)
    case results
    when String
      msg_content = Telegram::Bot::Types::InputTextMessageContent.new(
        message_text: result
      )
      msg = Telegram::Bot::Types::InlineQueryResultArticle.new(
        type: 'article',
        id: '1',
        title: 'Dry area!',
        input_message_content: msg_content
      )
      results = [ msg ]
      bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    when Array
      results.map!.with_index do |bar, index|
        Telegram::Bot::Types::InlineQueryResultVenue.new(
          type: 'venue',
          id: index,
          latitude: bar.lat,
          longitude: bar.lng,
          title: bar.name,
          address: bar.vicinity
        )
      end
      bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    end
  end
end

def respond_message(bot, message)
  places = GooglePlaces::Client.new(@google_api_key)
  case message.text
  when '/pubme'
    begin
      kb = [Telegram::Bot::Types::KeyboardButton.new(text: 'Send Location', request_location: true)]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: 'Send location', reply_markup: markup)
    rescue Telegram::Bot::Exceptions::ResponseError => e
      result = "Sorry I can't request your location in a group chat. Specify a location, e.g. '/pubme brixton', or call @{myname}_bot inline from anywhere."
    end
  when /^\/pubme\s+(.*)$/
    result = return_random_pub(by_query: true, query_string: "pubs in #{$1}")
  end
  if message.location && message.reply_to_message
    result = return_random_pub(location: message.location)
  end
  case result
  when String
    bot.api.send_message(chat_id: message.chat.id, text: result)
  when GooglePlaces::Spot
    bot.api.send_message(chat_id: message.chat.id, text: result.name)
    bot.api.send_location(chat_id: message.chat.id, latitude: result.lat, longitude: result.lng)
  end
end

def return_random_pub(by_query: false, location: nil, query_string: nil, radius: 500, types: 'bar', exclude: 'restaurant', return_all: false)
  places = GooglePlaces::Client.new(@google_api_key)
  if by_query && query_string
    results = places.spots_by_query(query_string, :radius => radius, :types => types, :exclude => exclude)
  elsif location
    results = places.spots(location.latitude, location.longitude, :radius => radius, :types => types, :exclude => exclude)
  end
  if results.length == 0
    return 'No results found in your vicinity.'
  elsif return_all
    return results
  else
    return results.sample
  end
end

Telegram::Bot::Client.run(telegram_token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      respond_inline_message(bot, message)
    when Telegram::Bot::Types::Message
      respond_message(bot, message)
    end
  end
end

