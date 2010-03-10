require './lib/comic'
require 'chronic'
class MyextralifeComic < Comic
  BASE_URL = "http://www.myextralife.com"
  LATEST_URL = BASE_URL
  ARCHIVE_URL = "http://www.myextralife.com/the-archive/comics-by-year/"
  def image_urls(comic_id)
    [
      File.join(BASE_URL,'comics',"#{comic_id}.gif"),
      File.join(BASE_URL,'comics',"#{comic_id}.jpg")
    ]
  end

  def get_latest_id
    doc = Nokogiri::HTML(open(ARCHIVE_URL))
    doc.css(".archive-date").map{|a|Chronic.parse("#{a.text} #{Time.now.year}").strftime("%Y-%m-%d")}
  end

  def get_all_ids_since_last_saved
    episodes,year = get_episodes_from_archive
    until episodes.include?(last_saved_id)
      older_episodes,year = get_episodes_from_archive(year - 1)
      break if older_episodes == []
      episodes += older_episodes
    end
    return episodes unless episodes.include?(last_saved_id)
    episodes[0...episodes.index(last_saved_id)]
  end

  private
  def get_episodes_from_archive(year=nil)
    year ||= Time.now.year
    doc = Nokogiri::HTML(open(File.join(ARCHIVE_URL,"?archive_year=#{year}")))
    episodes = doc.css(".archive-date").map{|a|Chronic.parse("#{a.text} #{year}").strftime("%Y-%m-%d")}
    return episodes,year
  end
end