# fluent-plugin-azure-loganalytics
[Azure Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-overview) output plugin for Fluentd. The plugin aggregates semi-structured data in real-time and writes the buffered data via HTTPS request to Azure Log Analytics.

![fluent-plugin-azure-loganalytics overview](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/raw/master/img/Azure-LogAnalytics-Fluentd.png)

## Installation
```
$ gem install fluent-plugin-azure-loganalytics
```

## Configuration

### Azure Log Analytics
To start running with Log Analytics in the Microsoft Operations Management Suite (OMS), You need to create either an OMS workspace using the OMS website or Log Analytics workspace using your Azure subscription. Workspaces created either way are functionally equivalent. Here is an instruction:

 * [Get started with Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-get-started)

Once you have the workspace, get Workspace ID and Shared Key (either Primary Key or Secondary Key), which are needed by [Log Analytics HTTP Data Collector API](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-collector-api) to post the data to Log Analytics.


### Fluentd - fluent.conf

```
<match azure-loganalytics.**>
    @type azure-loganalytics
    customer_id CUSTOMER_ID   # Customer ID aka WorkspaceID String
    shared_key KEY_STRING     # The primary or the secondary Connected Sources client authentication key
    log_type EVENT_TYPE_NAME  # The name of the event type. ex) ApacheAccessLog
    add_time_field true
    time_field_name mytime
    time_format %s
    localtime true
    add_tag_field true
    tag_field_name mytag
</match>
```

 * **customer\_id (required)** - Your Operations Management Suite workspace ID
 * **shared\_key (required)** - The primary or the secondary Connected Sources client authentication key
 * **log\_type (required)** - The name of the event type that is being submitted to Log Analytics
 * **add\_time\_field (optional)** - Default:true. This option allows to insert a time field to record
 * **time\_field\_name (optional)** - Default:time. This is required only when add_time_field is true
 * **localtime (optional)** - Default:false. Time record is inserted with UTC (Coordinated Universal Time) by default. This option allows to use local time if you set localtime true. This is valid only when add_time_field is true
 * **time\_format (optional)** -  Default:%s. Time format for a time field to be inserted. Default format is %s, that is unix epoch time. If you want it to be more human readable, set this %Y%m%d-%H:%M:%S, for example. This is valid only when add_time_field is true.
 * **add\_tag\_field (optional)** - Default:false. This option allows to insert a tag field to record
 * **tag\_field\_name (optional)** - Default:tag. This is required only when add_time_field is true


## Configuration examples

fluent-plugin-azure-loganalytics adds **time** and **tag** attributes by default if **add_time_field** and **add_tag_field** are true respectively. Below are two types of the plugin configurations - Default and All options configuration.

### (1) Default Configuration (No options)
<u>fluent.conf</u>
```
<source>
    @type tail                         # input plugin
    path /var/log/apache2/access.log   # monitoring file
    pos_file /tmp/fluentd_pos_file     # position file
    format apache                      # format
    tag azure-loganalytics.access      # tag
</source>

<match azure-loganalytics.**>
    @type azure-loganalytics
    customer_id 818f7bbc-8034-4cc3-b97d-f068dd4cd658
    shared_key ppC5500KzCcDsOKwM1yWUvZydCuC3m+ds/2xci0byeQr1G3E0Jkygn1N0Rxx/yVBUrDE2ok3vf4ksCzvBmQXHw==(dummy)
    log_type ApacheAccessLog
</match>
```

### (2) Configuration with All Options
<u>fluent.conf</u>
```
<source>
    @type tail                         # input plugin
    path /var/log/apache2/access.log   # monitoring file
    pos_file /tmp/fluentd_pos_file     # position file
    format apache                      # format
    tag azure-loganalytics.access      # tag
</source>

<match azure-loganalytics.**>
    @type azure-loganalytics
    customer_id 818f7bbc-8034-4cc3-b97d-f068dd4cd658
    shared_key ppC5500KzCcDsOKwM1yWUvZydCuC3m+ds/2xci0byeQr1G3E0Jkygn1N0Rxx/yVBUrDE2ok3vf4ksCzvBmQXHw==(dummy)
    log_type ApacheAccessLog
    add_time_field true
    time_field_name mytime
    time_format %s
    localtime true
    add_tag_field true
    tag_field_name mytag
</match>
```

## Sample inputs and expected records

An expected output record for sample input will be like this:

<u>Sample Input (apache access log)</u>
```
124.211.152.156 - - [10/Dec/2016:05:28:52 +0000] "GET /test/foo.html HTTP/1.1" 200 323 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36"
```

<u>Output Record</u>

![fluent-plugin-azure-loganalytics output image](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/raw/master/img/Azure-LogAnalytics-Output-Image.png)


## Tests
### Running test code
```
$ git clone https://github.com/yokawasa/fluent-plugin-azure-loganalytics.git
$ cd fluent-plugin-azure-loganalytics

# edit CONFIG params of test/plugin/test_azure_loganalytics.rb
$ vi test/plugin/test_azure_loganalytics.rb

# run test
$ rake test
```

### Creating package, running and testing locally
```
$ rake build
$ rake install:local

# running fluentd with your fluent.conf
$ fluentd -c fluent.conf -vv &

# send test apache requests for testing plugin ( only in the case that input source is apache access log )
$ ab -n 5 -c 2 http://localhost/test/foo.html
```

## Change log
* [Changelog](ChangeLog.md)

## Links

* http://yokawasa.github.io/fluent-plugin-azure-loganalytics
* https://rubygems.org/gems/fluent-plugin-azure-loganalytics
* https://rubygems.org/gems/azure-loganalytics-datacollector-api

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yokawasa/fluent-plugin-azure-loganalytics.

## Copyright

<table>
  <tr>
    <td>Copyright</td><td>Copyright (c) 2016- Yoichi Kawasaki</td>
  </tr>
  <tr>
    <td>License</td><td>Apache License, Version 2.0</td>
  </tr>
</table>
