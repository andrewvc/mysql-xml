require 'mysql-xml'

#These tests are really minimal, but it's such a simple class,
#they're almost overkill.
describe MySQLXML do
  it 'should parse the sample document without raising exceptions' do
    MySQLXML::parse(File.new('test.xml'))  {}
  end
  it 'should call the block as many times as there are records' do
    parse_good_xml
  end

  def parse_good_xml(&block)
    MySQLXML::parse(File.new('test.xml')) {|record| yield record}
  end
end
