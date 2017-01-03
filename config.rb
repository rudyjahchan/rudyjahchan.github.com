###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = "blog/{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "post"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  #blog.per_page = 10
  #blog.page_link = "page/{num}"
end

page "/feed.xml", layout: false


###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :directory_indexes

# Methods defined in the helpers block are available in templates
helpers do
  def feed_article_body(article)
    elements = []
    elements << article.data.video if article.data.video
    elements << article.body
    elements.join ' '
  end

  def description(article)
    description = if current_page.respond_to?(:summary)
                    current_page.summary(200)
                  elsif current_page.respond_to?(:body)
                    current_page.body
                  else
                    'Thoughts on coding and being a geek by Rudy Jahchan.'
                  end
    escape_html strip_tags description
  end
end

# Build-specific configuration
configure :build do
end

activate :external_pipeline,
         name: :webpack,
         command: build? ?
         "./node_modules/webpack/bin/webpack.js --bail -p" :
         "./node_modules/webpack/bin/webpack.js --watch -d --progress --color",
         source: ".tmp/dist",
         latency: 1

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.build_before = true
  deploy.branch   = "master"
  deploy.remote   = "git@github.com:rudyjahchan/rudyjahchan.github.com.git"
end
