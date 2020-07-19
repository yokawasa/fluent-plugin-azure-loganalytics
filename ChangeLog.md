# ChangeLog

## 0.7.0

* Change base [azure-loganalytics-datacollector-api](https://github.com/yokawasa/azure-log-analytics-data-collector) to ">= 0.5.0"
    * [azure-log-analytics-data-collector-0.5.0](https://github.com/yokawasa/azure-log-analytics-data-collector/releases/tag/v0.5.0) added check body size not to exceed data limit of 30MB in Azure Monitor Data Collection API
    * relevant issues: [issue #16](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/issues/16)

## 0.6.0

* Change base [azure-loganalytics-datacollector-api](https://github.com/yokawasa/azure-log-analytics-data-collector) to ">= 0.4.0"
    * In [azure-log-analytics-data-collector-0.4.0](https://github.com/yokawasa/azure-log-analytics-data-collector/releases/tag/v0.4.0), restclient retries request on the status code 429(Too Many Requests), 500 (Internal Server Error), 503(Service Unavailable)

## 0.5.0

* Support setting the [x-ms-AzureResourceId](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-collector-api#request-headers) Header - [issue #17](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/issues/17)

## 0.4.2

* fix CVE-2020-8130 - [issue #13](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/issues/13)

## 0.4.1

* Use `yajl` instead of default JSON encoder to fix logging exceptions - [PR#10](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/pull/10)

## 0.4.0

* Add endpoint parameter for sovereign cloud - [PR#8](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/pull/8)
* Changed dependency for azure-loganalytics-datacollector-api to `>= 0.1.5` - [PR#8](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/pull/8)

## 0.3.1

* Add requirements section - [PR#2](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/pull/2)
* Add log_type characters check as log_type only supports alpha characters - [Issue#3](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/issues/3)

## 0.3.0

* Migrate to use fluentd v0.14 API - [PR#1](https://github.com/yokawasa/fluent-plugin-azure-loganalytics/pull/1)

## 0.2.0
* Support for time-generated-field in output configuration

## 0.1.1
* Changed required minimum version of azure-loganalytics-datacollector-api to >= 0.1.2
* modified log_type param: removed default val and made it required param

## 0.1.0

* Inital Release
