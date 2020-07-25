# interlok-speedtest-elastic ![Interlok Hammer](https://img.shields.io/badge/certified-interlok%20hammer-red.svg)

This is clearly a case of when all you have is a hammer; everything looks like a nail...

* Get https://github.com/sivel/speedtest-cli, old-skool style, and put it somewhere.
* Get ElasticSearch, configure, and start it
    * Example index available.
* Get Kibana, configure, and start it
* Configure your interlok instance with JSON, ElasticSearch (CSV required as a dependency)
* Leave it running for a bit, and do your visualisations.

Maybe you'll end up with something like this:

![kibana timelion](https://github.com/quotidian-ennui/interlok-speedtest-elastic/blob/master/kibana-timelion.png)()


## Bonus Chatter

Since we're already using elasticsearch and kibana, then we can use filebeats to also log stuffs (this was more an intellectual itch in how to setup ecs-logging-java with log4j2)

* Uses https://github.com/elastic/ecs-logging-java for logging (see log4j.xml)
* Filebeat configuration is simply
```
setup.kibana.host: "http://kibana:5601"

filebeat.inputs:
- type: log
  paths: /path/to/interlok/speedtest/logs/interlok-elastic.log
  json.keys_under_root: true
  json.overwrite_keys: true

# no further processing required, logs can directly be sent to Elasticsearch
output.elasticsearch:
  hosts: ["http://elasticsearch:9200"]

```

* If you're going to use the [logging context profile](https://interlok.adaptris.net/interlok-docs/advanced-profiler-logging-context.html) then the message id probably show up as a tag so you can search for something like `messageId: ccb46b73-7fed-41db-baf8-e048a0fa8ec3`