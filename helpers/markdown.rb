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
      full_doc = handle_internal_doc_links(full_doc)
      full_doc = handle_internal_image_urls(full_doc)
      full_doc = handle_internal_image_links(full_doc)
      full_doc
    end

    # Replaces all markdown image links that look like ![alttext](path/to/img "optional title")
    # and prepends the path to @docset plus the '/_img/' directory to it. Does not match links that include a :,
    # which would denote an absolute url like http://somesite.com/path/to/img.png
    #
    # Given ![alttext](path/to/img "optional title") this should replace with
    #       ![alttext](/path/to/docset/_img/path/to/img "optional title")
    def handle_internal_image_urls(full_doc)
      full_doc.gsub(/!\[([^\]]*)\]\(([^ \)"]*)[\s]*("[^"]*")?\)/) { |s|
        if s.include? ':'
          s
        else
          alt_text = $1
          img_path = $2
          title = $3
          # strip out the leading slash in the url if it's there and prepend the docset path and the
          # /_img/ directory path
          img_path = @docset.full_url_from_path('/_img/' + img_path.sub(/^\//, ''))
          "![#{alt_text}](#{img_path}" + (!title.nil? && !title.empty? ? " #{title}" : '') + ')'
        end
      }
    end

    # Replaces all links that start with _img/ or /_img/ with a link that takes into account the current
    # docset's configured url.
    #
    # Given (/_img/path/to/image.png)
    #       (/path/to/docset/_img/path/to/image.png)
    def handle_internal_image_links(full_doc)
      full_doc.gsub(/\(([^\]\)]*)\)/) { |s|
        if s.include? ':'
          s
        else
          link = $1

          if link.start_with? '_img/' or link.start_with? '/_img/'
            link = link.sub(/^\//, '')
            link = @docset.full_url_from_path("/#{link}")
            "(#{link})"
          else
            s
          end
        end
      }
    end

    # Replaces double bracket internal document link expressions with regular markdown link expressions
    # Matches both [[Doc Name]] and [[Friendly Display Name | Doc Name]]
    def handle_internal_doc_links(full_doc)
      full_doc.gsub(/\[{2}([^|\]]*)\|?([^|\]]*)\]{2}/) { |s|
        docname = $1.strip
        url = @docset.full_url(docname)

        display_text = docname
        unless $2.strip.empty?
          url_parts = $2.strip.split('#')
          url = @docset.full_url(url_parts[0].strip)
          if url_parts.length == 2
            url << "##{url_parts[1]}"
          end
        end

        display_text and url ? "<a href='#{url}' class='internal'>#{display_text}</a>" : s
      }
    end
  end

  # Create a Redcarpet markdown renderer that utilizes the Pygment-capable
  # HTML renderer and additional GFM options
  @markdown_options = {
    :fenced_code_blocks => true,
    :disable_indented_code_blocks => true,
    :autolink => true,
    :space_after_headers => false,
    :tables => true
  }

  # Render the given text with Docula's markdown renderer
  def self.render(docset, md_text)
    render = DoculaHTMLRender.new(docset)
    markdown = Redcarpet::Markdown.new(render, @markdown_options)
    markdown.render(md_text)
  end

  # Render the sidebar for this docset
  def self.render_sidebar(docset)
    render(docset, docset.sidebar_md)
  end
end
