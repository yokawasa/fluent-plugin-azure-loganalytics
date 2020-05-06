# -*- coding: utf-8 -*-
require 'msgpack'
require 'time'
require "azure/loganalytics/datacollectorapi/client"
require 'fluent/plugin/output'

module Fluent::Plugin
  class AzureLogAnalyticsOutput < Output
    Fluent::Plugin.register_output('azure-loganalytics', self)

    helpers :compat_parameters

    DEFAULT_BUFFER_TYPE = "memory"

    config_param :customer_id, :string,
                 :desc => "Your Operations Management Suite workspace ID"
    config_param :shared_key, :string, :secret => true,
                 :desc => "The primary or the secondary Connected Sources client authentication key"
    config_param :endpoint, :string, :default =>'ods.opinsights.azure.com',
                 :desc => "The service endpoint"
    config_param :log_type, :string,
                 :desc => "The name of the event type that is being submitted to Log Analytics. log_type only alpha characters"
    config_param :time_generated_field, :string, :default => '',
                 :desc => "The name of the time generated field. Be carefule that the value of field should strictly follow the ISO 8601 format (YYYY-MM-DDThh:mm:ssZ)"
    config_param :azure_resource_id, :string, :default => '',
                 :desc => "Resource ID of the Azure resource the data should be associated with. This populates the _ResourceId property and allows the data to be included in resource-context queries in Azure Log Analytics (Azure Monitor). If this field isn't specified, the data will not be included in resource-context queries. The format should be like /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}"
    config_param :add_time_field, :bool, :default => true,
                 :desc => "This option allows to insert a time field to record"
    config_param :time_field_name, :string, :default => "time",
                 :desc => "This is required only when add_time_field is true"
    config_param :time_format, :string, :default => "%s",
                 :desc => "Time format for a time field to be inserted. Default format is %s, that is unix epoch time. If you want it to be more human readable, set this %Y%m%d-%H:%M:%S, for example. This is valid only when add_time_field is true."
    config_param :localtime, :bool, :default => false,
                 :desc => "Time record is inserted with UTC (Coordinated Universal Time) by default. This option allows to use local time if you set localtime true. This is valid only when add_time_field is true."
    config_param :add_tag_field, :bool, :default => false,
                 :desc => "This option allows to insert a tag field to record"
    config_param :tag_field_name, :string, :default => "tag",
                 :desc => "This is required only when add_time_field is true"

    config_section :buffer do
      config_set_default :@type, DEFAULT_BUFFER_TYPE
      config_set_default :chunk_keys, ['tag']
    end

    def configure(conf)
      compat_parameters_convert(conf, :buffer)
      super
      raise Fluent::ConfigError, 'no customer_id' if @customer_id.empty?
      raise Fluent::ConfigError, 'no shared_key' if @shared_key.empty?
      raise Fluent::ConfigError, 'no log_type' if @log_type.empty?
      if not @log_type.match(/^[[:alpha:]]+$/)
        raise Fluent::ConfigError, 'log_type supports only alpha characters'
      end
      if @add_time_field and @time_field_name.empty?
        raise Fluent::ConfigError, 'time_field_name must be set if add_time_field is true'
      end
      if @add_tag_field and @tag_field_name.empty?
        raise Fluent::ConfigError, 'tag_field_name must be set if add_tag_field is true'
      end
      @timef = Fluent::TimeFormatter.new(@time_format, @localtime)
    end

    def start
      super
      # start
      @client=Azure::Loganalytics::Datacollectorapi::Client::new(@customer_id,@shared_key,@endpoint)
    end

    def shutdown
      super
      # destroy
    end

    def format(tag, time, record)
      if @add_time_field
        record[@time_field_name] = @timef.format(time)
      end
      if @add_tag_field
        record[@tag_field_name] = tag
      end
      record.to_msgpack
    end

    def formatted_to_msgpack_binary?
      true
    end

    def multi_workers_ready?
      true
    end

    def write(chunk)
      records = []
      chunk.msgpack_each { |record|
        records.push(record)
      }
      begin
        res = @client.post_data(@log_type, records, @time_generated_field, @azure_resource_id)
        if not Azure::Loganalytics::Datacollectorapi::Client.is_success(res)
          log.fatal "DataCollector API request failure: error code: " +
                  "#{res.code}, data=>" + Yajl.dump(records)
        end
      rescue Exception => ex
        log.fatal "Exception occured in posting to DataCollector API: " +
                  "'#{ex}', data=>" + Yajl.dump(records)
      end
    end
  end
end
