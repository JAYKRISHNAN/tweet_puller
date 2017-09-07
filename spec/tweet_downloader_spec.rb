require 'rspec'
require_relative '../tweet_downloader'

describe TweetDownloader do
  let(:tweet_downloader) { TweetDownloader.new("#arsenal", 600, "key", "secret") }
  describe "initialize" do
    it "sets required instance variables" do
      expect(tweet_downloader.instance_variable_get(:@hashtag)).to eq "#arsenal"
      expect(tweet_downloader.instance_variable_get(:@count)).to eq 600
      expect(tweet_downloader.instance_variable_get(:@bearer_token)).not_to be_nil
    end
  end

  describe "#execute" do
    context "success scenario" do
      it "fetches given number of tweets and write it to a file" do
        tweet_downloader.execute

        expect(tweet_downloader.instance_variable_get(:@tweets).count).to eq 600
      end
    end
  end
end
