require './lib/comic'
class MyextralifeComic < Comic
  BASE_URL = "http://www.myextralife.com"
  LATEST_URL = BASE_URL
  ARCHIVE_URL = "http://www.myextralife.com/the-archive/comics-by-year/"
  def image_url(comic_id)
    File.join(BASE_URL,'comics/cad',"#{comic_id}.jpg")
  end

  def get_latest_id
    doc = Nokogiri::HTML(open(ARCHIVE_URL))
    doc.css(".archive-title/a").first[:href].sub(File.join(BASE_URL,'comic/'),'').sub('/','')
  end

  def get_all_ids_since_last_saved
    episodes,year = get_episodes_from_archive
    puts episodes.to_yaml
    until episodes.include?(last_saved_id)
      older_episodes,year = get_episodes_from_archive(year - 1)
      puts older_episodes.to_yaml
      break if older_episodes == []
      episodes = older_episodes + episodes
    end
    return episodes unless episodes.include?(last_saved_id)
    episodes[(episodes.index(last_saved_id)+1)..-1]
  end

  private
  def get_episodes_from_archive(year=nil)
    year ||= Time.now.year
    doc = Nokogiri::HTML(open(File.join(ARCHIVE_URL,"?archive_year=#{year}")))
    episodes = doc.css(".archive-title/a").map{|a|a[:href].sub(File.join(BASE_URL,'comic/'),'').sub('/','')}
    return episodes,year
  end
end