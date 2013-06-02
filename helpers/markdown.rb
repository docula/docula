module DoculaMarkdown
  class DoculaHTMLRender < Redcarpet::Render::HTML
    def initialize(docset)
      @docset = docset
      super()
    end

    # Dispatches code blocks to Pygments for language specific syntax highlighting
    # Automatically invoked by Redcarpet
    def block_code(code, language)
      Pygments.highlight(code, :lexer => language)
    end

    # Fires off all necessary Docula preprocessors
    # Automatically invoked by Redcarpet
    def preprocess(full_doc)
      handle_internal_doc_links(full_doc)
      full_doc
    end

    # Replaces double bracket internal link expressions with regular markdown link expressions
    # Matches both [[Doc Name]] and [[Doc Name | Friendly Display Name]]
    def handle_internal_doc_links(full_doc)
      full_doc.gsub!(/\[{2}([^|\]]*)\|?([^|\]]*)\]{2}/) { |s|
        docname = $1.strip
        url = @docset.full_url(docname)

        display_text = docname
        unless $2.strip.empty?
          display_text = $2.strip
        end

        display_text and url ? "[#{display_text}](#{url})" : s
      }
    end
  end

  # Create a Redcarpet markdown renderer that utilizes the Pygment-capable
  # HTML renderer and additional GFM options
  @markdown_options = {
    :fenced_code_blocks => true,
    :disable_indented_code_blocks => true,
    :autolink => true,
    :space_after_headers => true
  }

  # Render the given text with Docula's markdown renderer
  def self.render(docset, md_text)
    render = DoculaHTMLRender.new(docset)
    markdown = Redcarpet::Markdown.new(render, @markdown_options)
    markdown.render(md_text)
  end

  # Render the sidebar for this docset
  def self.render_sidebar(docset)
    render(docset, docset.build_sidebar_md)
  end
end
