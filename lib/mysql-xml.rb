#Provides an easy way to parse XML output from mysql -X.
#MySQLXML::parse takes an IO object for the XML and a block that gets called
#once for each record.
#
#Example:
#  require 'mysql-xml'
#  MySQLXML::parse(File.new('test.xml')) do |record|
#    puts record.inspect
#  end
#
#This uses REXML's stream parser, so it should be reasonably
#memory efficient.
require 'rexml/document'
require 'rexml/parsers/streamparser'

module MySQLXML
  def self.parse(io,&block)
    listener = MyXListener.new(block)
    REXML::Document.parse_stream(io,listener)
    return listener.records
  end

  class MyXListener
    attr_reader :records
     
    def initialize(block)
      #Track where we are in the tree.
      @context        = []
      @cur_record     = nil
      @cur_field_name = nil
      @block = block
    end
     
    def tag_start(name, attrs)
      @context << name
      if name == 'row'
        @cur_record = {}
      elsif name == 'field'
        @cur_field_name = attrs['name']
      end
    end
    
    def text(text)
      if @context[-1] == 'field'
        @cur_record[@cur_field_name] = text
      end
    end
    
    def tag_end(name)
      @context.pop
      if name == 'field'
        @cur_field_name = nil
      elsif name == 'row'
        @block.call(@cur_record)
        @cur_record     = nil
      end
    end 
   
    #Silence method missing exceptions since we only
    #need to handle some events 
    def method_missing(*opts); end
  end
end
