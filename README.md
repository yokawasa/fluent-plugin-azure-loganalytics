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
    endpoint myendpoint
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
 * **endpoint (optional)** - Default:'ods.opinsights.azure.com'. The service endpoint. You may want to use this param in case of sovereign cloud that has a different endpoint from the public cloud
 * **time\_generated\_field (optional)** - Default:''(empty string) The name of the time generated field. Be carefule that the value of field should strictly follow the ISO 8601 format (YYYY-MM-DDThh:mm:ssZ). See also [this](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-collector-api#create-a-request) for more details
 * **azure\_resource\_id (optional)** - Default:''(empty string) The resource ID of the Azure resource the data should be associated with. This populates the [_ResourceId](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/log-standard-properties#_resourceid) property and allows the data to be included in [resource-context](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment#access-mode) queries in Azure Log Analytics (Azure Monitor). If this field isn't specified, the data will not be included in resource-context queries. The format should be like /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}. Please see [this](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-resource#resourceid) for more detail on the resource ID format.

 * **add\_time\_field (optional)** - Default:true. This option allows to insert a time field to record
 * **time\_field\_name (optional)** - Default:time. This is required only when add_time_field is true
 * **localtime (optional)** - Default:false. Time record is inserted with UTC (Coordinated Universal Time) by default. This option allows to use local time if you set localtime true. This is valid only when add_time_field is true
 * **time\_format (optional)** -  Default:%s. Time format for a time field to be inserted. Default format is %s, that is unix epoch time. If you want it to be more human readable, set this %FT%T%z, for example. This is valid only when add_time_field is true.
 * **add\_tag\_field (optional)** - Default:false. This option allows to insert a tag field to record
 * **tag\_field\_name (optional)** - Default:tag. This is required only when add_time_field is true


## Configuration examples

fluent-plugin-azure-loganalytics adds **time** and **tag** attributes by default if **add_time_field** and **add_tag_field** are true respectively. Below are two types of the plugin configurations - Default and All options configuration.

### (1) Default Configuration (No options)
<u>fluent_1.conf</u>
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
<u>fluent_2.conf</u>
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
    azure_resource_id /subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/otherResourceGroup/providers/Microsoft.Storage/storageAccounts/examplestorage
    add_time_field true
    time_field_name mytime
    time_format %FT%T%z
    localtime true
    add_tag_field true
    tag_field_name mytag
</match>
```
### (3) Configuration with Typecast filter

You want to add typecast filter when you want to cast fields type. The filed type of code and size are cast by typecast filter.
<u>fluent_typecast.conf</u>
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
    time_format %FT%T%z
    localtime true
    add_tag_field true
    tag_field_name mytag
</match>
```
[note] you need to install [fluent-plugin-filter-typecast](https://github.com/sonots/fluent-plugin-filter_typecast) for the sample configuration above. 
```
gem install fluent-plugin-filter_typecast
```
### (4) Configuration with CSV format as input and specific field type as output
You want to send to Log Analytics, logs generated with known delimiter (like comma, semi-colon) then you can use the csv format of fluentd and the keys/types properties.
This can be used with any log, here implemented with Nginx custom log.
<u>fluent_csv.conf</u>

Suppose your log is formated the way below in the  /etc/nginx/conf.d/log.conf:
```
log_format appcustomlog '"$time_iso8601";"$hostname";$bytes_sent;$request_time;$upstream_response_length;$upstream_response_time;$content_length;"$remote_addr";$status;"$host";"$request";"$http_user_agent"';
```
And this log is activated throught the /etc/nginx/conf.d/virtualhost.conf :
```
server {
	...
	access_log /var/log/nginx/access.log appcustomlog;
	...
}
```
You can use the following configuration for the source to tail the log file and format it with proper field type.
```
<source>
  @type tail
  path /var/log/nginx/access.log
  pos_file /var/log/td-agent/access.log.pos
  tag nginx.accesslog
  format csv
  delimiter ;
  keys time,hostname,bytes_sent,request_time,content_length,remote_addr,status,host,request,http_user_agent
  types time:time,hostname:string,bytes_sent:float,request_time:float,content_length:string,remote_addr:string,status:integer,host:string,request:string,http_user_agent:string
  time_key time
  time_format %FT%T%z
</source>

<match nginx.accesslog>
    @type azure-loganalytics
    customer_id 818f7bbc-8034-4cc3-b97d-f068dd4cd658
    shared_key ppC5500KzCcDsOKwM1yWUvZydCuC3m+ds/2xci0byeQr1G3E0Jkygn1N0Rxx/yVBUrDE2ok3vf4ksCzvBmQXHw==(dummy)
    log_type NginxAcessLog
    time_generated_field time
    time_format %FT%T%z
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

The output record for sample input can be seen at Log Analytics portal like this:

![fluent-plugin-azure-loganalytics output image](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/raw/master/img/Azure-LogAnalytics-Output-Image.png)

<u>Sample Input (nginx custom access log)</u>
```
"2017-12-13T11:31:59+00:00";"nginx0001";21381;0.238;20882;0.178;-;"193.192.35.178";200;"mynginx.domain.com";"GET /mysite/picture.jpeg HTTP/1.1";"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/63.0.3239.84 Safari/537.36"
```

<u>Output Record</u>

Part of the output record for sample input can be seen at Log Analytics portal like this with field of type _s (string) or _d (double):

![fluent-plugin-azure-loganalytics output image](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/raw/master/img/Azure-LogAnalytics-Output-Image-2.png)

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

## Data Limits
As described in [ Azure Monitor Data Collection API doc](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-collector-api#data-limits), there are some constraints around the data posted to the Azure Monitor Data collection API. Here are relevant constraints:

- Max payload size: `30 BM`
- Max field value size: `32 KB`
- Max characters num for each field name: `500`

Please be noticed that the plugin checks the max payload size before it post to the API (>=[0.7.0](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/releases/tag/v0.7.0)), however it doesn't check max field value size and max charactores num for each field name.

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
