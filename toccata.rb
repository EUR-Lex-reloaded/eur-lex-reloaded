#!/usr/bin/env ruby

require 'nokogiri'
require 'pp'

src = File.read 'data.html'
doc = Nokogiri::HTML::Document.parse src
toc = Nokogiri::XML::Element.new 'ul', doc
toc[:class] = 'toc'
doc.xpath('//h2').each_with_index do |node, idx|
  # wrap header in a new '<a name="toc_n">'
  anchor = Nokogiri::XML::Element.new 'a', doc
  anchor[:name] = "toc_#{idx}"
  anchor.parent = node.parent
  node.parent = anchor

  # create a new toc entry
  toc_entry = Nokogiri::XML::Element.new 'li', doc
  toc_entry_anchor = Nokogiri::XML::Element.new 'a', doc
  toc_entry_anchor[:href] = "#toc_#{idx}"
  toc_entry_text = Nokogiri::XML::Text.new node.text, doc
  toc_entry_anchor.add_child toc_entry_text
  toc_entry.add_child toc_entry_anchor
  toc.add_child toc_entry
end

# add toc to body
doc.xpath('/html/body').first.add_child toc

puts doc
