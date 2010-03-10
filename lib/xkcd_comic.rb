require './lib/comic'
#TODO: Add Alt-text support; perhaps post-process with an image utility to add the text as a footer border?
class XkcdComic < Comic
  BASE_URL = "http://xkcd.com"
  LATEST_URL = BASE_URL
  def image_url(comic_id)
    doc = Nokogiri::HTML(open(File.join(BASE_URL,comic_id.to_s)))
    doc.css('#middleContent.dialog/div.bd/div.c/div.s//img').first[:src]
  rescue Exception => e
    puts comic_id
    puts e.to_yaml
    puts doc.css('#middleContent.dialog/div.bd/div.c/div.s').to_html
    raise e
  end

  def get_latest_id
    doc = Nokogiri::HTML(open(LATEST_URL))
    doc.css('#middleContent.dialog/div.bd/div.c/div.s/h3').first.text.sub("Permanent link to this comic: #{BASE_URL}/",'').sub('/','').to_i
  end

  def retrieve_comic(comic_id)
    return nil if comic_id == 404 #Comic 404 Not Found :)
    img_url = image_url(comic_id)
    basename = "[%04d]#{File.basename(img_url)}" % comic_id
    target_filename = File.join(storage_path,basename)
    return nil if File.exist?(target_filename)
    `wget #{'-b -q' if wget_background} -U "ComicRetrieveR -- http://github.com/FiXato/ComicRetrieveR" -O "#{target_filename}" "#{img_url}"`
  end
end