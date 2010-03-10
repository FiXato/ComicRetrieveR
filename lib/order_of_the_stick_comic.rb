require './lib/comic'
class OrderOfTheStickComic < Comic
  BASE_URL = "http://www.giantitp.com"
  LATEST_URL = "http://www.giantitp.com/comics/oots.html"
  def image_url(comic_id)
    doc_url = File.join(BASE_URL,'comics',"oots%04d.html" % comic_id)
    doc = Nokogiri::HTML(open(doc_url))
    css_path = 'html/body/table/tr/td/table/tr/td/table/tr/td/table/tr/td/img'
    File.join(BASE_URL,doc.css(css_path).first[:src])
  end

  def get_latest_id
    doc = Nokogiri::HTML(open(LATEST_URL))
    doc.css('.ComicList').first.child.text.strip.to_i
  end
  
  def retrieve_comic(comic_id)
    img_url = image_url(comic_id)
    basename = "[%04d]#{File.basename(img_url)}" % comic_id
    target_filename = File.join(storage_path,basename)
    return nil if File.exist?(target_filename)
    `wget #{'-b -q' if wget_background} -U "ComicRetrieveR -- http://github.com/FiXato/ComicRetrieveR" -O "#{target_filename}" "#{img_url}"`
  end
end