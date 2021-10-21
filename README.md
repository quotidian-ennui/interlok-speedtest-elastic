# interlok-speedtest-elastic ![Interlok Hammer](https://img.shields.io/badge/certified-interlok%20hammer-red.svg) [![Actions Status](https://github.com/quotidian-ennui/interlok-speedtest-elastic/workflows/check/badge.svg)](https://github.com/quotidian-ennui/interlok-speedtest-elastic/actions)

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

## Bonus docker

Since filebeats has an RPM, then you can install that into your base image, and configure it, and also run interlok at the same time. This assumes that you have already configured kibana/elastic.

- Baseline on `centos:7` as the image, installing openjdk + initscripts (these are the two critical things); initscripts because you want to be able to run `/etc/init.d/filebeats`
- What we do is to use [dumb-init](https://github.com/Yelp/dumb-init/) as the entrypoint.
    - docker-entrypoint.sh executes /etc/init.d/filebeat and then /interlok-entrypoint.sh in the foreground
    - interlok-entrypoint runs interlok __as root__; you don't have to.
- Make use of the ec2-layout artifact to emit the logging still
- Copy in a filebeat.yml to configure filebeats.
- Check the [Dockerfile](./Dockerfile) for more details.


### Would I do this in production?

The way you _should do it_ is to use filebeats with autodiscover on the docker host; but sometimes you can't do that. So the answer to that is it depends, your mileage is definitely going to vary based on your own requirements. Things that immediately come to mind are (these are the same questions that I would ask if someone wanted to log to a shared volume and monitor the volume with filebeat):

- We know that performance of the docker filesystem can be somewhat variable, so logging to disk (interlok) and then reading from disk (filebeat) isn't going to be great.
    - I haven't considered the ramifications of having a rolling file on the behaviour of filebeats (you're probably going to lose logging at the rollover point).
    - I'm using rollover logging because I want to have a relatively fixed profile in terms of disk usage.
- There's obviously additional overhead on the docker container itself, so you might not be able to size it how you want.
- If you're scaling automatically, is the scaling happening because interlok is using too much CPU, or because filebeat is?



