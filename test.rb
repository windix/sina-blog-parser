require 'test/unit'
require 'open-uri'
require 'sina_blog_parser'

class TestSinaBlog < Test::Unit::TestCase
  def test_uid_parser
    url = "http://blog.sina.com.cn/windix"
    assert_equal("1656856361", SinaBlogParser.uid_parser(load(url)))
  end

  def test_list_parser
    # test with a list of 2 posts
    url1 = "http://blog.sina.com.cn/s/indexlist_1656856361_1.html"
    result = ["62c19f290100foky", "62c19f290100foku"]
    assert_equal(result, SinaBlogParser.list_parser(load(url1)))

    # test an empty list
    url2 = "http://blog.sina.com.cn/s/indexlist_1656856361_2.html"
    assert_equal(nil, SinaBlogParser.list_parser(load(url2)))
  end

  def test_post_parser
    url = "http://blog.sina.com.cn/s/blog_62c19f290100foky.html"
    post = SinaBlogParser.post_parser(load(url))

    assert_equal("The&nbsp;quick&nbsp;brown&nbsp;fox&nbsp;jumps&nbsp;over&nbsp;the&nbsp;lazy&nbsp;dog", post.title)
    assert_equal("2009-10-28 18:09:42", post.date)
    assert_equal("The quick brown fox jumps over the lazy dog\n ", post.content)
  end

  private
  def load(url)
    open(url).read
  end
end

