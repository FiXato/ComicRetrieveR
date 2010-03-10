require './lib/comic'
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