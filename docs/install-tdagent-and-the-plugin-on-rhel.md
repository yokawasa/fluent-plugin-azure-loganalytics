# How to install td-agent and luent-plugin-azure-loganalytics plugin on RHEL

This is a quick installation procedure of td-agent and the custom plugin (fluent-plugin-azure-loganalytics) on Red Hat Enterprise Linux (7.4) 

$ cat /etc/os-release
```
NAME="Red Hat Enterprise Linux Server"
VERSION="7.4 (Maipo)"
ID="rhel"
ID_LIKE="fedora"
VARIANT="Server"
VARIANT_ID="server"
VERSION_ID="7.4"
PRETTY_NAME="Red Hat Enterprise Linux Server 7.4 (Maipo)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:7.4:GA:server"
HOME_URL="https://www.redhat.com/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 7"
REDHAT_BUGZILLA_PRODUCT_VERSION=7.4
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="7.4"
```

## 0. prerequisites (for Redhat/Centos)
Install GCC and Development Tools on a CentOS / RHEL 7 server
```
$ suod yum group install "Development Tools"
```

## 1. Install td-agent (fluentd)

Following the fluentd official page, install like this:
https://docs.fluentd.org/v0.12/articles/install-by-rpm
```
$ curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh

$ td-agent --version
td-agent 0.12.40
```

## 2. Launching Daemon
```
$ sudo /etc/init.d/td-agent start
$ sudo /etc/init.d/td-agent status
```
## 3. Post Sample Logs via HTTP
By default, /etc/td-agent/td-agent.conf is configured to take logs from HTTP and route them to stdout (/var/log/td-agent/td-agent.log). You can post sample log records using the curl command.

```
$ curl -X POST -d 'json={"json":"message"}' http://localhost:8888/debug.test

# Checking log (/var/log/td-agent/td-agent.log) and see if the log is written
$ cat /var/log/td-agent/td-agent.log
```

## 4. Install the custom plugin
```
$ sudo /usr/sbin/td-agent-gem install fluent-plugin-azure-loganalytics
```

## 5. Testing the plugin
```
$ git clone https://github.com/yokawasa/fluent-plugin-azure-loganalytics.git
$ cd fluent-plugin-azure-loganalytics
$ /opt/td-agent/embedded/bin/rake test
```