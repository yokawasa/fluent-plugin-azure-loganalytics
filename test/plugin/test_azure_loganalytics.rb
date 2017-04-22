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

  def create_driver(conf = CONFIG, tag='azure-loganalytics.test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::AzureLogAnalyticsOutput, tag).configure(conf)
  end

  def test_configure
    #### set configurations
    # d = create_driver %[
    #   path test_path
    #   compress gz
    # ]
    #### check configurations
    # assert_equal 'test_path', d.instance.path
    # assert_equal :gz, d.instance.compress
  end

  def test_format
    # d = create_driver
    # time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    # d.emit({"a"=>1}, time)
    # d.emit({"a"=>2}, time)

    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":1}\n]
    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":2}\n]

    # d.run
  end

  def test_write
    d = create_driver

    time = Time.parse("2016-12-10 13:14:15 UTC").to_i
    d.emit(
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
      }, time)

    d.emit(
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
      }, time)

    data = d.run
    puts data
    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path
  end
end

