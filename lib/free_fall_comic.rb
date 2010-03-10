require './lib/comic'
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