require_relative 'spec_helper'
require 'markdown'

describe DoculaMarkdown do

  before do
    @docset = DocSet.new
    @docset.stubs(:docset_url).returns '/docset/master'

    @renderer = DoculaMarkdown::DoculaHTMLRender.new(@docset)
  end

  it 'passes a trivial test' do
    true.must_equal true
  end

  it 'works with mocks' do
    @docset.full_url_from_path('_img').must_equal '/docset/master/_img'
  end

  describe 'Image Links' do
    it 'rewrites docset images' do
      md = '![text](some_image.png)'
      @renderer.handle_internal_image_urls(md).must_equal '![text](/docset/master/_img/some_image.png)'
    end

    it 'does not render double slashes' do

    end

    it 'does not require a title' do

    end

    it 'does not rewrite external image links' do
      md = '![text](http://example.com/img.png)'
      @renderer.handle_internal_image_urls(md).must_equal md
    end

    it 'rewrites internal doc URLs' do

    end
  end

  describe 'Document Links' do
    it 'rewrites internal doc URLs' do

    end

    it 'only matches braces' do

    end

    it 'does not require display test' do

    end

    it 'allows separate display text' do

    end
  end

end

