class BlogPost
  attr_accessor :title, :date, :content
  
  def initialize(title, date, content)
    @title = title
    @date = date
    @content = content
  end
end

class SinaBlogParser
  def self.get_blog_url(name)
    "http://blog.sina.com.cn/#{name}"
  end

  def self.get_list_url(uid, page_id)
    "http://blog.sina.com.cn/s/indexlist_#{uid}_#{page_id}.html"
  end

  def self.get_post_url(id)
    "http://blog.sina.com.cn/s/blog_#{id}.html"
  end

  def self.uid_parser(html)
    $1 if html =~ /\$uid\s*:\s*"(\d+)"/
  end

  def self.list_parser(page)
    fav_pattern = %r{"([0-9a-z]+)":"[0-9a-f]+"}

    if page =~ %r{var fav = \{(.*)\}}
      fav = $1
      fav.scan(fav_pattern).flatten
    end
  end

  def self.post_parser(post)
    title_pattern = %r{<div class="articleTitle">.<div style="display: inline;">.*<b id="[^"]+">(.*)</b><span class="time">\(([^)]+)\)}m
    title, date = $1, $2 if post =~ title_pattern

    content_pattern = %r{<div class="articleContent" id="articleBody">.(.*)</div>.<!--   -->}m
    content = $1 if post =~ content_pattern

    BlogPost.new(title, date, content)
  end
end
