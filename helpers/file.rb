require 'filemagic'
module DoculaFile

  def self.detect_mime_type(path)
    FileMagic.new(FileMagic::MAGIC_MIME).file(path).gsub(/\n/, '').split(';').first
  end
end