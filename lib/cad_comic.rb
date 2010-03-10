require './lib/comic'
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
    doc.css(".post/a").map{|a|a[:href].sub('/cad/','').to_i}
  end
end