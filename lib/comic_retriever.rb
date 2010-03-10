require 'yaml'
require './lib/questionable_content_comic'
require './lib/lfg_comic'
require './lib/cad_comic'
require './lib/free_fall_comic'
require './lib/myextralife_comic'
require './lib/xkcd_comic'

class ComicRetriever
  CONFIG_URL = './comics.yaml'
  attr_accessor :config, :comics, :wget_background
  def config
    return @config if @config
    return @config = YAML.from_file(CONFIG_URL) if File.exist?(CONFIG_URL)
    @config = {
      :comics => {
        :QuestionableContentComic => {
          :last_saved_id => 1618,
          :storage_path => File.expand_path("~/Pictures/QuestionableContent/"),
        },
        :LfgComic => {
          :last_saved_id => 337,
          :storage_path => File.expand_path("~/Pictures/LFGComic/"),
        },
        :CadComic => {
          :last_saved_id => 20100310,
          :storage_path => File.expand_path("~/Pictures/CADComic/"),
        },
        :FreeFallComic => {
          :last_saved_id => 1854,
          :storage_path => File.expand_path("~/Pictures/FreeFall/"),
        },
        :MyextralifeComic => {
          :last_saved_id => "2010-03-09",
          :storage_path => File.expand_path("~/Pictures/MyExtraLife/"),
        },
        :XkcdComic => {
          :last_saved_id => 712,
          :storage_path => File.expand_path("~/Pictures/Xkcd/"),
        },
      },
    }
  end
  def comics
    unless @comics
      comic_configs = config[:comics]
      @comics = comic_configs.map do |comic_class,comic_config|
        Kernel.const_get(comic_class).new(comic_config,wget_background)
      end
    end
  end
  def retrieve_all
    comics.each do |comic|
      puts "[#{Time.now.strftime('%H%M%S')}] Retrieving #{comic}"
      comic.get_all_since_last
    end
  end
end