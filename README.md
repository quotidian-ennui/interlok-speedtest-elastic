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
