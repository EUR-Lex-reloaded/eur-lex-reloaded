#!/usr/bin/env ruby

require 'nokogiri'
require 'uri'
require 'cgi'
require 'open-uri'

# find out where we are running...
scheme = ENV['REQUEST_SCHEME']
host = ENV['HTTP_HOST'] || ENV['SERVER_NAME']
port = (ENV['SERVER_PORT'] == '80') ? "" : ":#{ENV['SERVER_PORT']}"
path = ENV['REQUEST_URI']
SCRIPT_URL = URI.parse("#{scheme}://#{host}#{port}#{path}").freeze

# get document from request param url
cgi = CGI.new
begin
  base_url = URI.parse(cgi['url'])
  case base_url
    when URI::HTTP, URI::HTTPS
    else
      raise 'foo'
  end
rescue StandardError
  cgi.out do
    <<-EOD
      <html>
        <head>
          <title>Error: You need to supply a document URL</title>
        </head>
        <body>
          <h1>Error</h1>
          <p>You need to supply a document URL as <tt>url</tt> request param.</p>
        </body>
      </html>
    EOD
  end
  exit
end
doc = Nokogiri::HTML::Document.parse base_url.read

# add base href to head to make styles and scripts work...
base = Nokogiri::XML::Element.new 'base', doc
base[:href] = base_url
doc.xpath('/html/head').children.first.add_previous_sibling base

# add styles to display table of contents at top left
doc.xpath('/html/head').first.add_child <<EOS
<style type="text/css">
  .body-wrapper {
    position: absolute;
    left: 8em;
  }
  .toc {
    position: absolute;
    top: 0em;
    left: 0em;
    background-color: #fff;
    width: 7em;
    padding-top: 1em;
    padding-left: 1em;
    overflow: hidden;
  }
  .toc h3 {
    border-bottom: 1px solid #000;
    margin-bottom: 0.4em;
    width: 6em;
  }
  .toc ul {
    list-style-type: none;
  }
</style>
EOS

# wrap body in a div so we can apply styles
wrapper = Nokogiri::XML::Element.new 'div', doc
wrapper[:class] = 'body-wrapper'
STDERR.puts wrapper
doc.xpath('/html/body/*').each do |node|
  wrapper.add_child node
end
doc.xpath('/html/body').first.add_child wrapper

# modify all internal links first, before we add our own
doc.xpath('//a').each do |node|
  if href = node[:href]
    url = URI.parse href
    if url.relative?  # TODO check abs urls for same server?
      abs_url = base_url.merge(url)
      new_url = SCRIPT_URL.dup
      new_url.query = "url=#{URI.escape abs_url.to_s}"
      node[:href] = new_url
    end
  end
end

# now generate a table of contents and related anchors
toc_base_url = SCRIPT_URL.dup
toc_base_url.query = "url=#{URI.escape base_url.to_s}"
toc = Nokogiri::XML::Element.new 'div', doc
toc[:class] = 'toc'
toc_header = Nokogiri::XML::Element.new 'h3', doc
toc_header.add_child 'TOC'
toc.add_child toc_header
toc_ul = Nokogiri::XML::Element.new 'ul', doc
toc.add_child toc_ul
doc.xpath("//p[@class='ti-art']").each_with_index do |node, idx|
  # wrap header in a new '<a name="toc_n">'
  anchor = Nokogiri::XML::Element.new 'a', doc
  anchor[:name] = "toc_#{idx}"
  node.add_previous_sibling anchor

  # create a new toc entry. Use FQ URLs to escape from base href
  toc_entry = Nokogiri::XML::Element.new 'li', doc
  toc_entry_anchor = Nokogiri::XML::Element.new 'a', doc
  toc_entry_anchor[:href] = "#{toc_base_url}#toc_#{idx}"
  toc_entry_text = Nokogiri::XML::Text.new node.text, doc
  toc_entry_anchor.add_child toc_entry_text
  toc_entry.add_child toc_entry_anchor
  toc_ul.add_child toc_entry
end

# add toc to body
doc.xpath('/html/body').first.add_child toc

cgi.out do
  doc.to_s
end
