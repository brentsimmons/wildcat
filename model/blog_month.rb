require_relative 'post'

class BlogMonth

  def initialize(month_num)
    @month_num = month_num
    @posts = {}
  end

  def add_post(post)
    @posts.push(post) unless @posts.include?(post)
  end
end
