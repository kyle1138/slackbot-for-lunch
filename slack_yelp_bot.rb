# require 'sinatra'
require 'httparty'
require 'yelp'
require 'slack-ruby-client'

messages = ['Look out for rats.' , 'I hope you choke on it.' , "What doesn't kill you makes you stronger.",
"Their health code grade is a C, but it's a strong C." , 'If their food could talk it would say "Meow"',
 'Try the cream of mushroom', "It's almost as good as Arby's" , "It's a part of a balanced breakfast",
"This food pairs well with menthol cigarettes", "It's edible", "Dolphin safe, free range, non GMO, all organic garbage",]

yelp_ckey = 'J3ogr6kBSiJfVZh3RzBr4g'
yelp_csecret = 'ywFhs2CIDB_Ccww9jqzf_SertwM'
yelp_token = 'dixHFLccFAHRxDXMeBG6TUXb-_7Woo25'
yelp_token_secret = 'bpHbo2BfB3GK6uokm2zXLxbH7U0'

yelp_client = Yelp::Client.new({ consumer_key: yelp_ckey,
                            consumer_secret: yelp_csecret ,
                            token: yelp_token,
                            token_secret: yelp_token_secret
                          })


yelp_response =  yelp_client.search('10011' , {term: 'lunch'})


  Slack.configure do |config|
    config.token = 'xoxb-12086963063-S9l3lBAkZo3cBuOlz4RrKeWC'
    fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
  end


  client = Slack::RealTime::Client.new

  client.on :hello do
    puts 'connected.'
  end

  client.on :message do |data|

    puts data

    case data['text']

      when 'bitebot' then
        client.message channel: data['channel'], text: "Hi <@#{data['user']}> , check it out."
        yelp_response =  yelp_client.search('10011' , {term: 'lunch', radius: 500})
        client.message channel: data['channel'], text: "#{yelp_response.businesses[rand(20)].url}"
      when /^bitebot find/ then

        if data['text'].split('find')[1]
          request = data['text'].split('find')[1]
          foods = request.split('locate@')[0]
          location = request.split('locate@')[1]
        end

        if location && foods
          yelp_response =  yelp_client.search(location , {term: foods, radius: 500})
        elsif foods
          yelp_response =  yelp_client.search('10011' , {term: foods, radius: 500})
        else
          yelp_response =  yelp_client.search('10011' , {term: 'lunch', radius: 500})
        end
        puts yelp_response.businesses[0].keys
        client.message channel: data['channel'], text: "Here's a suggestion <@#{data['user']}>."
        client.message channel: data['channel'], text: "#{yelp_response.businesses[rand(yelp_response.businesses.length)].url}"
        client.message channel: data['channel'], text: "#{messages[rand(6)]}"

    end

  end

  def yelpParsing(string)
    params = ['find' , 'locate@']
  end

  client.start!
