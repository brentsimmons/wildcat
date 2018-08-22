require_relative '../utilities/wildcat_utils'

class Renderer
  @@templates = {}
  @@snippets = {}

  BEGIN_SNIPPET_CHARACTERS = '[[='.freeze
  BEGIN_SNIPPET_CHARACTERS_COUNT = 3
  END_SNIPPET_CHARACTERS = ']]'.freeze
  END_SNIPPET_CHARACTERS_COUNT = 2
  BEGIN_SUBSTITUTION_CHARACTERS = '[[@'.freeze
  BEGIN_SUBSTITUTION_CHARACTERS_COUNT = 3
  END_SUBSTITUTION_CHARACTERS = ']]'.freeze
  END_SUBSTITUTION_CHARACTERS_COUNT = 2

  UNDEFINED_SUBSTITUTION = '[ERROR: UNDEFINED SUBSTITUTION]'.freeze

  def initialize(settings, template_name, context)
    @settings = settings
    @context = context

    @template_text = @@templates[template_name]
    if @template_text.nil?
      @template_text = read_template(template_name)
      @@templates[template_name] = @template_text
    end
    @html = @template_text.dup
  end

  def to_s
    process_snippets(@html)
    process_substitutions(@html)
    @html
  end

  private

    def read_template(template_name)
      path = File.join(@settings.templates_folder, template_name)
      unless FileTest.exist?(path)
        path = File.join(@settings.templates_folder, template_name + '.html')
      end
      WildcatUtils.read_text_file(path)
    end

    def read_snippet(snippet_filename)
      text = @@snippets[snippet_filename]
      return text unless text.nil?

      path = File.join(@settings.snippets_folder, snippet_filename)
      snippet_text = WildcatUtils.read_text_file(path)
      @@snippets[snippet_filename] = snippet_text

      snippet_text.dup
    end

    def process_snippets(text)
      indexes_of_characters(text, BEGIN_SNIPPET_CHARACTERS).reverse_each { |index| process_one_snippet(text, index) }
    end

    def process_one_snippet(text, ix)
      ix_end = text.index(END_SNIPPET_CHARACTERS, ix)
      return if ix_end.nil?
      snippet_filename = text[ix + BEGIN_SNIPPET_CHARACTERS_COUNT, ix_end - (ix + BEGIN_SNIPPET_CHARACTERS_COUNT)]
      snippet_text = read_snippet(snippet_filename)
      return if snippet_text.nil?
      process_snippets(snippet_text)
      text[ix, (ix_end + END_SNIPPET_CHARACTERS_COUNT) - ix] = snippet_text
    end

    def process_substitutions(text)
      indexes_of_characters(text, BEGIN_SUBSTITUTION_CHARACTERS).reverse_each { |ix| process_one_substitution(text, ix) }
      text
    end

    def process_one_substitution(text, ix)
      ix_end = text.index(END_SUBSTITUTION_CHARACTERS, ix)
      return if ix_end.nil?
      substitution = text[ix + BEGIN_SUBSTITUTION_CHARACTERS_COUNT, ix_end - (ix + BEGIN_SUBSTITUTION_CHARACTERS_COUNT)]
      result = @context[substitution]
      if result.nil?
        result = UNDEFINED_SUBSTITUTION
        WildcatUtils.print_to_console("Undefined substitution: #{substitution}")
      end
      text[ix, (ix_end + END_SUBSTITUTION_CHARACTERS_COUNT) - ix] = result
    end

    def indexes_of_characters(text, searchFor)
      ix = 0
      indexes = []

      loop do
        ix = text.index(searchFor, ix)
        break if ix.nil?
        indexes << ix if ix.zero? || text[ix - 1, 1] != '\\' # escape char is \
        ix += 1
      end
      indexes
    end
end
