require_relative 'tweet_downloader'

hashtag = ARGV[0]
count = ARGV[1]

TweetDownloader.new(hashtag,count).execute
