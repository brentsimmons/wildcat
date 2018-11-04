require 'date'
require_relative 'blog_month'

class BlogYear
  attr_reader :year
  attr_reader :months

  def initialize(year)
    @year = year
    @months = {}
  end

  def add_post(post)
    month_num = post.pub_date.month

    blog_month = @months[month_num]
    if blog_month.nil?
      blog_month = BlogMonth.new(month_num)
      @months[month_num] = blog_month
    end

    blog_month.add_post(post)
  end

  private

    def add_month(month_num)
      @months.push(month_num) unless @months.include?(month_num)
    end
end
