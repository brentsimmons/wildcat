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
end
