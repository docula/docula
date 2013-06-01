module DoculaMarkdown

  # Specialized version of Redcarpet's HTML renderer that will utilize
  # Pygments for language-specific syntax highlighting
  class HTMLWithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, :lexer => language)
    end
  end

  # Create a Redcarpet markdown renderer that utilizes the Pygment-capable
  # HTML renderer and additional GFM options
  markdown_options = {
      :fenced_code_blocks => true,
      :disable_indented_code_blocks => true,
      :autolink => true,
      :space_after_headers => true
  }
  @markdown = Redcarpet::Markdown.new(HTMLWithPygments, markdown_options);

  # Render the given text with Docula's markdown renderer
  def self.render(md_text)
    @markdown.render(md_text)
  end

end
