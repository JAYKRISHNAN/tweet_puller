require_relative 'tweet_downloader'

hashtag = ARGV[0]
count = ARGV[1]
consumer_key = ARGV[2]
consumer_secret = ARGV[3]

TweetDownloader.new(hashtag, count, consumer_key, consumer_secret).execute
