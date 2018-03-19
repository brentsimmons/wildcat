require_relative 'post'

class BlogMonth

  attr_reader :month

  def initialize(month)
    @month = month
    @posts = []
  end

  def add_post(post)
    @posts.push(post)
  end

  def to_html
    html = ''
    @posts.each { |post| html+= post.to_html(true) }
    html
  end
end
