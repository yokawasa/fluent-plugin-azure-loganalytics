require 'helper'

class AzureLogAnalyticsOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    customer_id <Customer ID aka WorkspaceID String>
    shared_key <Primary Key String>
    log_type ApacheAccessLog
    time_generated_field eventtime
    add_time_field true
    localtime true
    add_tag_field true
    tag_field_name tag
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::AzureLogAnalyticsOutput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal 'ApacheAccessLog', d.instance.log_type
    assert_equal true, d.instance.add_time_field
    assert_equal true, d.instance.localtime
    assert_equal true, d.instance.add_tag_field
    assert_equal 'tag', d.instance.tag_field_name
  end

  def test_format
    d = create_driver
    time = event_time("2011-01-02 13:14:15 UTC")
    d.run(default_tag: 'test') do
      d.feed(time, {"a"=>1})
      d.feed(time, {"a"=>2})
    end
    formatted = d.formatted
    unpacker = Fluent::Engine.msgpack_factory.unpacker
    formatted.each_with_index {|f, idx|
      unpacker.feed_each(f).each {|e|
        assert_equal idx+1, e["a"]
        assert_equal "test", e["tag"]
        assert_equal "#{time.to_i}", e["time"]
      }
    }
  end

  def test_write
    d = create_driver

    time = event_time("2016-12-10 13:14:15 UTC")
    d.run(default_tag: 'azure-loganalytics.test') do
      d.feed(
        time,
        {
          :Log_ID => "5cdad72f-c848-4df0-8aaa-ffe033e75d57",
          :date => "2016-12-10 09:44:32 JST",
          :processing_time => "372",
          :remote => "101.202.74.59",
          :user => "-",
          :method => "GET / HTTP/1.1",
          :status => "304",
          :size => "-",
          :referer => "-",
          :agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:27.0) Gecko/20100101 Firefox/27.0",
          :eventtime => "2016-12-10T09:44:32Z"
        })

      d.feed(
        time,
        {
          :Log_ID => "7260iswx-8034-4cc3-uirtx-f068dd4cd659",
          :date => "2016-12-10 09:45:14 JST",
          :processing_time => "105",
          :remote => "201.78.74.59",
          :user => "-",
          :method => "GET /manager/html HTTP/1.1",
          :status =>"200",
          :size => "-",
          :referer => "-",
          :agent => "Mozilla/5.0 (Windows NT 5.1; rv:5.0) Gecko/20100101 Firefox/5.0",
          :eventtime => "2016-12-10T09:45:14Z"
        })
    end
    data = d.events
    puts data
    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path
  end
end
