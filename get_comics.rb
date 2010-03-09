#!/usr/bin/env ruby
require 'yaml'
require 'nokogiri'
require 'open-uri'
class ComicRetriever
  CONFIG_URL = './comics.yaml'
  attr_accessor :config, :comics
  def initialize
    $running_threads = 0
  end
  def config
    return @config if @config
    return @config = YAML.from_file(CONFIG_URL) if File.exist?(CONFIG_URL)
    @config = {
      :comics => {
        :QuestionableContent => {
          :last_saved_id => 1617,
          :storage_path => File.expand_path("~/Pictures/QuestionableContent/"),
        },
        :LfgComic => {
          :last_saved_id => 337,
          :storage_path => File.expand_path("~/Pictures/LFGComic/"),
        },
      },
    }
  end
  def comics
    unless @comics
      comic_configs = config[:comics]
      @comics = comic_configs.map do |comic_class,comic_config|
        Kernel.const_get(comic_class).new(comic_config)
      end
    end
  end
  def retrieve_all
    comics.each do |comic|
      comic.get_all_since_last
    end
  end
end

class Comic
  attr_accessor :url, :last_saved_id, :latest_id, :storage_path
  def initialize(config)
    @url = config[:url]
    @last_saved_id = config[:last_saved_id]
    @storage_path = config[:storage_path]
    @latest_id = get_latest_id
  end

  def retrieve_comic(comic_id)
    if $running_threads >= 20
      sleep 20
      return retrieve_comic(comic_id)
    end
    Thread.new{
      $running_threads += 1
      `wget -P #{storage_path} #{image_url(comic_id)}`
      $running_threads -= 1
    }
  end

  def get_all_since_last
    ((last_saved_id+1)..latest_id).each do |comic_id|
      retrieve_comic(comic_id)
    end
  end
end

class QuestionableContent < Comic
  BASE_URL = "http://www.questionablecontent.net"
  LATEST_URL = BASE_URL
  def image_url(comic_id)
    File.join(BASE_URL,'comics',"#{comic_id}.png")
  end
  
  def get_latest_id
    doc = Nokogiri::HTML(open(LATEST_URL))
    doc.css('#strip').first['src'].sub(File.join(BASE_URL,'comics/'),'').sub('.png','').to_i
  end
end

class LfgComic < Comic
  BASE_URL = "http://www.lfgcomic.com"
  LATEST_URL = "http://www.lfgcomic.com/page/latest"
  def image_url(comic_id)
    File.join(BASE_URL,'comics',"lfg#{comic_id}.gif")
  end

  def get_latest_id
    doc = Nokogiri::HTML(open(LATEST_URL))
    doc.css('#comic/img').first['src'].sub('/comics/lfg','').sub('.gif','').to_i
  end
end
rt = ComicRetriever.new
rt.retrieve_all
while $running_threads > 0 do
  puts $running_threads
  sleep 1
end