require 'rspec'
require_relative '../tweet_downloader'

describe TweetDownloader do
  describe "initialize" do
    it "sets required instance variables" do
      tweet_downloader = TweetDownloader.new("#arsenal", 3)

      expect(tweet_downloader.instance_variable_get(:@hashtag)).to eq "#arsenal"
      expect(tweet_downloader.instance_variable_get(:@count)).to eq 3
      expect(tweet_downloader.instance_variable_get(:@bearer_token)).not_to be_nil
    end
  end
end
