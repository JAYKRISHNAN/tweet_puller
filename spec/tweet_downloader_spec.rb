require 'rspec'
require_relative '../tweet_downloader'

describe TweetDownloader do
  describe "initialize" do
    it "sets required instance variables" do
      tweet_downloader = TweetDownloader.new("#arsenal", 3)

      expect(tweet_downloader.instance_variable_get(:@hashtag)).to eq "#arsenal"
      expect(tweet_downloader.instance_variable_get(:@count)).to eq 2
      expect(tweet_downloader.instance_variable_get(:@bearer_token)).not_to be_nil
    end
  end


  describe "#execute" do
    it "fetches given number of tweets and write it to a file" do
      TweetDownloader.new("#arsenal", 3).execute

      output_lines = []
      File.open('output.txt').each { |line| output_lines << line }

      expect(output_lines.count).to eq 2
      output_lines.each do |line|
        expect(line.downcase.include? "#arsenal").to be true
      end
    end
  end
end
