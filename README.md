# fluent-plugin-azure-loganalytics
[Azure Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-overview) output plugin for Fluentd. The plugin aggregates semi-structured data in real-time and writes the buffered data via HTTPS request to Azure Log Analytics.

![fluent-plugin-azure-loganalytics overview](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/raw/master/img/Azure-LogAnalytics-Fluentd.png)

## Requirements

| fluent-plugin-azure-loganalytics | fluentd | ruby |
|------------------------|---------|------|
| >= 0.3.0 | >= v0.14.15 | >= 2.1 |
|  < 0.3.0 | >= v0.12.0 | >= 1.9 |

## Installation
### Installing gems into system Ruby
```
$ gem install fluent-plugin-azure-loganalytics
```

### Installing gems into td-agent’s Ruby
If you installed td-agent and want to add this custom plugins, use td-agent-gem to install as td-agent has own Ruby so you should install gems into td-agent’s Ruby, not system Ruby:

```
$ /usr/sbin/td-agent-gem install fluent-plugin-azure-loganalytics
```
Please see also [I installed td-agent and want to add custom plugins. How do I do it?](https://docs.fluentd.org/v0.12/articles/faq#i-installed-td-agent-and-want-to-add-custom-plugins.-how-do-i-do-it?)


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
 * **log\_type (required)** - The name of the event type that is being submitted to Log Analytics. log_type only supports alpha characters
 * **time\_generated\_field (optional)** - Default:''(empty string) The name of the time generated field. Be carefule that the value of field should strictly follow the ISO 8601 format (YYYY-MM-DDThh:mm:ssZ). See also [this](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-collector-api#create-a-request) for more details
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
### (3) Configuration with Typecast filter

You want to add typecast filter when you want to cast fields type. The filed type of code and size are cast by typecast filter.
<u>fluent.conf</u>
```
<source>
    @type tail                         # input plugin
    path /var/log/apache2/access.log   # monitoring file
    pos_file /tmp/fluentd_pos_file     # position file
    format apache                      # format
    tag azure-loganalytics.access      # tag
</source>

<filter **>
    @type typecast
    types host:string,user:string,method:string,path:string,referer:string,agent:string,code:integer,size:integer
</filter>

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
[note] you need to install [fluent-plugin-filter-typecast](https://github.com/sonots/fluent-plugin-filter_typecast) for the sample configuration above. 
```
gem install fluent-plugin-filter_typecast
```

## Sample inputs and expected records

An expected output record for sample input will be like this:

<u>Sample Input (apache access log)</u>
```
124.211.152.156 - - [10/Dec/2016:05:28:52 +0000] "GET /test/foo.html HTTP/1.1" 200 323 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36"
```

<u>Output Record</u>

The output record for sample input can be seen at Log Analytics portal like this:

![fluent-plugin-azure-loganalytics output image](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/raw/master/img/Azure-LogAnalytics-Output-Image.png)


## Tests
### Running test code (using System rake)
```
$ git clone https://github.com/yokawasa/fluent-plugin-azure-loganalytics.git
$ cd fluent-plugin-azure-loganalytics

# edit CONFIG params of test/plugin/test_azure_loganalytics.rb
$ vi test/plugin/test_azure_loganalytics.rb

# run test
$ rake test
```

### Running test code (using td-agent's rake)
```
$ git clone https://github.com/yokawasa/fluent-plugin-azure-loganalytics.git
$ cd fluent-plugin-azure-loganalytics

# edit CONFIG params of test/plugin/test_azure_loganalytics.rb
$ vi test/plugin/test_azure_loganalytics.rb

# run test 
$ /opt/td-agent/embedded/bin/rake test
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

* https://rubygems.org/gems/fluent-plugin-azure-loganalytics
* https://rubygems.org/gems/azure-loganalytics-datacollector-api
* [How to install td-agent and luent-plugin-azure-loganalytics plugin on RHEL](docs/install-tdagent-and-the-plugin-on-rhel.md)

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
