# -*- coding: utf-8 -*-
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
    @count = (count.to_i - 1) #observed that API returns given count + 1
    @bearer_token = get_bearer_token
    @tweets = []
  end

  def execute
    get_tweets
    write_tweets_to_file if @tweets
  end

  def get_tweets
    response = make_search_request
    if response.code == "200"
      json_response = JSON.parse response.body
      json_response["statuses"].each do |status|
        @tweets << status["text"]
      end
    else
      print_error_message(response.code)
    end
  end

  def write_tweets_to_file
    File.open("output.txt", "w+") do |f|
      @tweets.each { |tweet| f.puts(tweet) }
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
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@bearer_token}"
    retried = false
    begin
      http.request(request)
    rescue Timeout::Error
      retried = true and retry unless retried #retry upon timeout
    end
  end

  def search_request_parameters
    {
      q: @hashtag,
      result_type: TWITTER_SEARCH_RESULT_TYPE,
      count: @count.to_s
    }
  end

  def print_error_message response_code # from twitter api docs
    case response_code
    when "400"
      print_to_console "The request was invalid or cannot be otherwise served"
    when "401"
      print_to_console "Missing or incorrect authentication credentials."
    when "403"
      print_to_console "The request is understood, but it has been refused"
    when "404"
      print_to_console "The URI requested is invalid or the resource requested"
    when "406"
      print_to_console "Invalid format is specified in the request."
    when "410"
      print_to_console "This resource is gone"
    when "420"
      print_to_console "Application is being rate limited ."
    when "422"
      print_to_console "Unable to be processed"
    when "429"
      print_to_console "Application’s rate limit having been exhausted for the resource"
    when "500"
      print_to_console "Something is broken"
    when "503"
      print_to_console "The Twitter servers are up, but overloaded with requests. Try again later"
    when "504"
      print_to_console "The Twitter servers are up, but the request couldn’t be serviced due to some failure within our stack. Try again later."
    end
  end

  def print_to_console message
    puts message
  end
end
