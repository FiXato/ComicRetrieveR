#!/usr/bin/env ruby
require 'yaml'
require 'nokogiri'
require 'open-uri'
class ComicRetriever
  CONFIG_URL = './comics.yaml'
  attr_accessor :config, :comics
  def config
    return @config if @config
    return @config = YAML.from_file(CONFIG_URL) if File.exist?(CONFIG_URL)
    @config = {
      :comics => {
        :QuestionableContent => {
          :url => "http://www.questionablecontent.net",
          :last_saved_id => 1615,
          :storage_path => File.expand_path("~/Pictures/QuestionableContent/"),
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
    `wget -P #{storage_path} #{image_url(comic_id)}`
  end

  def get_all_since_last
    (last_saved_id..latest_id).each do |comic_id|
      retrieve_comic(comic_id)
    end
  end
end

class QuestionableContent < Comic
  def image_url(comic_id)
    "#{url}/comics/#{comic_id}.png"
  end
  
  def get_latest_id
    doc = Nokogiri::HTML(open(url))
    doc.css('#strip').first['src'].sub(File.join(url,'comics/'),'').sub('.png','').to_i
  end
end

rt = ComicRetriever.new
rt.retrieve_all