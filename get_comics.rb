#!/usr/bin/env ruby
require './lib/comic_retriever'

rt = ComicRetriever.new
rt.wget_background = true if ARGV.include?('--wget-background')
rt.retrieve_all