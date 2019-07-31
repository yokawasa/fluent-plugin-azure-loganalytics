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
