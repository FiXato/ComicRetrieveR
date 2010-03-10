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
          :last_saved_id => 1618,
          :storage_path => File.expand_path("~/Pictures/QuestionableContent/"),
        },
        :LfgComic => {
          :last_saved_id => 337,
          :storage_path => File.expand_path("~/Pictures/LFGComic/"),
        },
        :CadComic => {
          :last_saved_id => 20100308,
          :storage_path => File.expand_path("~/Pictures/CADComic/"),
        },
        :FreeFallComic => {
          :last_saved_id => 418,
          :storage_path => File.expand_path("~/Pictures/FreeFall/"),
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
    url = image_url(comic_id)
    `wget -U "ComicRetrieveR -- http://github.com/FiXato/ComicRetrieveR" -P #{storage_path} #{url}` unless File.exist?(File.join(storage_path,File.basename(url)))
  end

  def get_all_ids_since_last_saved
    ((last_saved_id+1)..latest_id)
  end

  def get_all_since_last
    get_all_ids_since_last_saved.each do |comic_id|
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

class CadComic < Comic
  BASE_URL = "http://www.cad-comic.com"
  LATEST_URL = "http://www.cad-comic.com/cad/"
  ARCHIVE_URL = "http://www.cad-comic.com/cad/archive"
  def image_url(comic_id)
    File.join(BASE_URL,'comics/cad',"#{comic_id}.jpg")
  end

  def get_latest_id
    doc = Nokogiri::HTML(open(LATEST_URL))
    doc.css('#content/img').first['src'].sub('/comics/cad/','').sub('.jpg','').to_i
  end

  def get_all_ids_since_last_saved
    episodes = get_episodes_from_archive
    until episodes.include?(last_saved_id)
      year = episodes.first.to_s[0,4].to_i
      older_episodes = get_episodes_from_archive(year - 1)
      break if older_episodes == []
      episodes = older_episodes + episodes
    end
    return episodes unless episodes.include?(last_saved_id)
    episodes[(episodes.index(last_saved_id)+1)..-1]
  end

  private
  def get_episodes_from_archive(year='')
    doc = Nokogiri::HTML(open(File.join(ARCHIVE_URL,year.to_s)))
    doc.css(".post/a").map{|a|a[:href].sub('/cad/','')}
  end
end

class FreeFallComic < Comic
  BASE_URL = "http://freefall.purrsia.com/"
  LATEST_URL = BASE_URL
  def image_url(comic_id)
    File.join(BASE_URL,'ff%s00' % (comic_id/100.0).ceil,'fv%05d.gif' % comic_id)
  end

  def get_latest_id
    doc = Nokogiri::HTML(open(LATEST_URL))
    doc.css('html/body/a/img').first['src'].gsub(/\/ff\d+\/f(c|v)/,'').sub('.png','').sub('.gif','').to_i
  end
end

rt = ComicRetriever.new
rt.retrieve_all