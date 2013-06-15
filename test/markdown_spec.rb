require_relative 'spec_helper'
require 'markdown'

describe DoculaMarkdown do

  before do
    @docset = DocSet.new
    @docset.stubs(:docset_url).returns '/docset/master'

    @renderer = DoculaMarkdown::DoculaHTMLRender.new(@docset)
  end

  describe 'Sanity Checks' do
    it 'passes a trival test' do
      true.must_equal true
    end

    it 'works with partial mocks' do
      @docset.full_url_from_path('_img').must_equal '/docset/master/_img'
    end
  end

  describe 'Internal Image Links' do
    it 'rewrites docset images' do
      md = '![text](some_image.png)'
      @renderer.handle_internal_image_urls(md).must_equal '![text](/docset/master/_img/some_image.png)'
    end

    it 'prevents double slashes' do
      md = '![alt](/some_image.png)'
      @renderer.handle_internal_image_urls(md).must_equal '![alt](/docset/master/_img/some_image.png)'
    end

    it 'does not rewrite external image links' do
      md = '![alt](http://example.com/img.png)'
      @renderer.handle_internal_image_urls(md).must_equal md
    end

    it 'handles titles' do
      md = '![alt](some_image.png "title")'
      @renderer.handle_internal_image_urls(md).must_equal '![alt](/docset/master/_img/some_image.png "title")'
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