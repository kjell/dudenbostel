%w(rubygems hpricot htemplate ruby-debug).each {|lib| require lib}

$body, $nav = DATA.read.split("---")

def html_page(page, page_desc, steps)
  p = page > 1 ? page-1 : nil
  n = page < 13 ? page+1 : nil
  pages = (1..13).map {|pn| pn == page ? "<span>#{pn}</span>" : %[<a href="#{pn}.html">#{pn}</a>]}
      
  nav = HTemplate.new($nav).expand({:p => p, :n => n, :pages => pages})
  f = HTemplate.new($body).expand({:page => page, :steps => steps, :p => p, :n => n, :desc => page_desc, :nav => nav})
  File.write("#{page}.html", f)
end

def File.write(name, content, force=false)
  old_content = File.read(name) rescue ""
  File.open(name, "wb") { |f| f << content } unless content == old_content
end

page_info = (Hpricot(open("newmake.htm"))/:a).map{|s| s.inner_html.match(/Page \d+ (.*) Pictures.*/)[1]}

(1..13).zip(page_info).each do |page_num, page_desc|
  old_page = Hpricot(open("page#{page_num}.htm"))
  steps = (old_page/:tr).map do |step|
    [(step/:a).pop[:href], (step/:td).last.inner_html]
  end
  
  html_page(page_num, page_desc, steps)
  puts "transformed page #{page_num}"
end

__END__
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${self[:page]} — Dudenbostel Mandolin Build</title>
  <link rel="up" href="index.html">
  <link rel="prev" href="${self[:p]}.html"><link rel="next" href="${self[:n]}.html">
  <link rel="stylesheet" type="text/css" href="db.css"></link>
</head>
<body>
  ${self[:nav]}
  <p class="overview">${self[:desc]}</p>
  <dl>
    $ self[:steps].each do |img, cap|
      $ step = img.match(/dude(\d+b?).jpg/)[1]
      <dt id="${step}"><img src="${img}"></dt><dd>${cap}</dd>
    $ end
  </dl>
  ${self[:nav]}

  <p class="disclamier">© Lynn Dudenbostel, 2002.</p>
</body>
<html>  

---

<p class="nav">
  $ unless self[:p].nil?
    <strong><a href="${self[:p]}.html">&larr;</a></strong>
  $ else
    <strong><span>&larr;</span></strong>
  $ end
  ${self[:pages]}
  $ unless self[:n].nil?
    <strong><a href="${self[:n]}.html">&rarr;</a></strong>  
  $ else
    <strong><span>&rarr;</span></strong>
  $ end
</p>