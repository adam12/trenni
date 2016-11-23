# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

%%{
	machine markup;
	
	action identifier_begin {
		identifier_begin = p
	}

	action identifier_end {
		identifier_end = p
	}
	
	action pcdata_begin {
		pcdata = ""
	}

	action pcdata_end {
	}

	action characters_begin {
		characters_begin = p
	}

	action characters_end {
		characters_end = p
		
		pcdata << data[characters_begin...characters_end]
	}

	action entity_error {
		raise ParseError.new("could not parse entity", buffer, p)
	}

	action entity_begin {
		entity_begin = p
	}

	action entity_name {
		entity_end = p
		
		name = data[entity_begin...entity_end]
		puts "Entity: #{name.inspect} => #{entities[name]}"
		
		pcdata << entities[name]
	}

	action entity_hex {
		entity_end = p
		
		pcdata << data[entity_begin...entity_end].to_i(16)
	}

	action entity_number {
		entity_end = p
		
		pcdata << data[entity_begin...entity_end].to_i(10)
	}
	
	action doctype_begin {
		doctype_begin = p
	}

	action doctype_end {
		doctype_end = p
		
		delegate.doctype(data[doctype_begin...doctype_end])
	}

	action doctype_error {
		raise ParseError.new("could not parse doctype", buffer, p)
	}

	action comment_begin {
		comment_begin = p
	}

	action comment_end {
		comment_end = p
		
		delegate.comment(data[comment_begin...comment_end])
	}

	action comment_error {
		raise ParseError.new("could not parse comment", buffer, p)
	}
	
	action instruction_begin {
	}

	action instruction_text_begin {
		instruction_text_begin = p
	}

	action instruction_text_end {
		instruction_text_end = p
	}

	action instruction_end {
		delegate.instruction(
			data[identifier_begin...identifier_end],
			data[instruction_text_begin...instruction_text_end]
		)
	}
	
	action instruction_error {
		raise ParseError.new("could not parse instruction", buffer, p)
	}

	action tag_name {
		self_closing = false
		
		delegate.open_tag_begin(data[identifier_begin...identifier_end])
	}

	action tag_opening_begin {
	}

	action tag_self_closing {
		self_closing = true
	}
	
	action attribute_begin {
		has_value = false
		pcdata = ""
	}

	action attribute_value {
		has_value = true
	}

	action attribute_empty {
		has_value = true
	}

	action attribute {
		if has_value
			value = pcdata
		else
			value = true
		end
		
		delegate.attribute(data[identifier_begin...identifier_end], value)
	}
	
	action tag_opening_end {
		delegate.open_tag_end(self_closing)
	}

	action tag_closing_begin {
	}

	action tag_closing_end {
		delegate.close_tag(data[identifier_begin...identifier_end])
	}
	
	action tag_error {
		raise ParseError.new("could not parse tag", buffer, p)
	}

	action cdata_begin {
		cdata_begin = p
	}

	action cdata_end {
		cdata_end = p
		
		delegate.cdata(data[cdata_begin...cdata_end])
	}
	
	action cdata_error {
		raise ParseError.new("could not parse cdata", buffer, p)
	}

	action text_begin {
	}

	action text_end {
		delegate.text(pcdata)
	}
	
	include markup "trenni/markup.rl";
}%%

require_relative '../parse_error'

module Trenni
	module Fallback
		%% write data;
		
		def self.parse_markup(buffer, delegate, entities)
			data = buffer.read
			
			p = 0
			eof = data.size
			stack = []
			
			%% write init;
			%% write exec;
			
			if p != data.size
				raise ParseError.new("could not consume all input", buffer, p)
			end
			
			return nil
		end
	end
end
