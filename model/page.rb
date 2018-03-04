class Page

  def self.build_all_pages(settings)
    pages = all_pages(settings)
    pages.each { |page| page.build }
  end

  def initialize(path, settings)

  end

  def build

  end

  private

  def self.all_pages(settings)
  end

end
