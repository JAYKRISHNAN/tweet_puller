require 'open-uri'
require 'net/http'
require 'base64'
require 'json'
require 'pry'

class TweetDownloader

  CONSUMER_KEY =  "JCCMdJzpJ0Ug9Xf1t8yPH754R"
  CONSUMER_SECRET = "JDcqVeqQJhLhe0MXb1cQ6H7HTBRZLKwuHEz4zv11Kzrb9hSD4a"

  TWITTER_SEARCH_API_URL = "https://api.twitter.com/1.1/search/tweets.json"
  TWITTER_API_OAUTH_URL = "https://api.twitter.com/oauth2/token"
  TWITTER_SEARCH_RESULT_TYPE = "recent"

  def initialize(hashtag, count)
    @hashtag = hashtag
    @count = count
    @bearer_token = get_bearer_token
    @tweets = []
  end

  def execute
    get_tweets
    write_tweets_to_file
  end

  def get_tweets
    response = make_search_request
    json_response = JSON.parse response.body
    json_response["statuses"].each do |status|
      @tweets << status["text"]
    end
  end

  def write_tweets_to_file
    File.open("output.txt", "w+") do |f|
      @tweets.each { |tweet| f.puts(element) }
    end
  end

  private

  def get_bearer_token
    encoded_key = URI::encode(CONSUMER_KEY)
    encoded_secret = URI::encode(CONSUMER_SECRET)
    combined_secret_key = [encoded_key, encoded_secret].join(':')
    encoded_secret_key  = Base64.encode64(combined_secret_key).gsub("\n", '')
    uri = URI(TWITTER_API_OAUTH_URL)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type' ] = 'application/x-www-form-urlencoded;charset=UTF-8'
    request['Authorization'] = "Basic #{encoded_secret_key}"
    request.form_data = {
      :grant_type => 'client_credentials'
    }

    response = begin
                 Net::HTTP.start(uri.hostname,
                   uri.port,
                   :use_ssl => uri.scheme == 'https') do |http|
                   http.request(request)
                 end
               rescue Timeout::Error
                 retried = true and retry unless retried #retry upon timeout
               end

    json_response = JSON.parse(response.body)
    json_response['access_token']
  end

  def make_search_request
    uri = URI.parse(TWITTER_SEARCH_API_URL)
    uri.query = URI.encode_www_form(search_request_parameters)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.initialize_http_header(search_request_headers)
    retried = false
    binding.pry
    begin
      http.request(request)
    rescue Timeout::Error
      retried = true and retry unless retried #retry upon timeout
    end
  end

  def search_request_headers
    { "Content-Type" => "application/json",
      'Authorization'=>"Bearer #{Base64.encode64(@bearer_token)}"
    }
  end

  def search_request_parameters
    {
      q: @hashtag,
      result_type: TWITTER_SEARCH_RESULT_TYPE,
      count: @count.to_s
    }
  end
end
