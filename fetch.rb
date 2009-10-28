require 'rubygems'
require 'open-uri'
require 'logger'
require 'sina_blog_parser'
require 'sanitize'

logger = Logger.new(STDERR)
BLOG_PATH = "cache/"

def fetch(url)
  open(url).read
end

def store(path, content)
  open(path, "w") { |f| f.write content }
end

if (ARGV.length == 1) 
  blog_name = ARGV[0]

  posts = []
  blog_url = SinaBlogParser.get_blog_url(blog_name)
  logger.debug "Loading blog #{blog_url}..."

  if uid = SinaBlogParser.uid_parser(fetch(blog_url))
    page_id = 1
    loop do
      page = fetch(SinaBlogParser.get_list_url(uid, page_id))
      
      if (ids = SinaBlogParser.list_parser(page))
        ids.each do |id|
          post_url = SinaBlogParser.get_post_url(id)

          logger.debug "Blog: #{post_url}"
          
          post_file = "#{BLOG_PATH}#{id}"

          if File.exists?(post_file)
            post = open(post_file).read
            logger.debug "Existing... Skip"
          else
            post = fetch(post_url)
            store(post_file, post)
            logger.debug "Fetched!"
          end
        
          posts << SinaBlogParser.post_parser(post)
          logger.debug "#{posts.last.title}... loaded!"
        end # each
        page_id += 1
      else
        break # no more page, stop the loop
      end
    end # loop
  end

  logger.debug "Save the result file..."
  open("result/#{blog_name}.txt", "w") do |f|
    posts.reverse.each do |post|
      f << Sanitize.clean(post.title) + "\n"
      f << post.date + "\n\n"
      f << Sanitize.clean(post.content) + "\n"
      f << "------------------------------------\n"
    end
  end

  logger.debug "All done!"

else
  puts "Usage: fetch.rb <blog_name>"
end  

__END__
