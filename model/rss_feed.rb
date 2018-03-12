class RSSFeed

  def self.rendered_feed(settings, posts)
    feed = RSSFeed.new(settings, posts)
    feed.to_text
  end

  def initialize(settings, posts)


  end

  def to_text

  end

  private

  def add_header

  end

  def add_articles

  end


end
