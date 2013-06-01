# encoding: utf-8
module Wiki
  def print_tree(tree, indent, out="")
    tree.contents.each do |blob|
      out << '-' + ('-' * (4 * indent)) + ' ' + blob.name + "\n"

      if blob.kind_of? Grit::Tree
        print_tree(blob, indent + 1, out)
      end
    end

    out
  end
end
