require './lib/comic'
class QuestionableContentComic < Comic
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