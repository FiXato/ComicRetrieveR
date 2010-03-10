require 'nokogiri'
require 'open-uri'
class Comic
  attr_accessor :url, :last_saved_id, :latest_id, :storage_path, :wget_background
  def initialize(config,wget_background=false)
    @url = config[:url]
    @last_saved_id = config[:last_saved_id]
    @storage_path = config[:storage_path]
    @latest_id = get_latest_id
    @wget_background = wget_background
  end

  def retrieve_comic(comic_id)
    image_urls(comic_id).each do |url|
      `wget #{'-b -q' if wget_background} -U "ComicRetrieveR -- http://github.com/FiXato/ComicRetrieveR" -P #{storage_path} #{url}` unless File.exist?(File.join(storage_path,File.basename(url)))
    end
  end

  def image_urls(comic_id)
    [image_url(comic_id)]
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