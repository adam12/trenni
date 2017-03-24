
require 'benchmark/ips'
require 'trenni/parsers'
require 'trenni/entities'

require 'nokogiri'

RSpec.describe Trenni::Parsers do
	# include_context "profile"
	
	let(:xhtml_path) {File.expand_path('corpus/large.xhtml', __dir__)}
	let(:xhtml_buffer) {Trenni::FileBuffer.new(xhtml_path)}
	let(:entities) {Trenni::Entities::HTML5}
	
	it "should be fast to parse large documents" do
		Benchmark.ips do |x|
			x.report("Large (Trenni)") do |times|
				delegate = Trenni::ParseDelegate.new
				
				while (times -= 1) >= 0
					Trenni::Parsers.parse_markup(xhtml_buffer, delegate, entities)
					
					delegate.events.clear
				end
			end
			
			x.report("Large (Nokogiri)") do |times|
				delegate = Trenni::ParseDelegate.new
				parser = Nokogiri::HTML::SAX::Parser.new(delegate)
				
				while (times -= 1) >= 0
					parser.parse(xhtml_buffer.read)
					
					delegate.events.clear
				end
			end
			
			x.compare!
		end
	end
end