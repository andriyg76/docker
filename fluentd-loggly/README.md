dataferret/fluentd-loggly
=========================
![Latest tag](https://img.shields.io/github/tag/dataferret/docker-fluentd-loggly.svg?style=flat)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)
[![](https://badge.imagelayers.io/dataferret/fluentd-loggly:latest.svg)](https://imagelayers.io/?images=dataferret/fluentd-loggly:latest 'Get your own badge on imagelayers.io')

Fluentd logging endpoint transcription to Loggly service.  In addition to
the standard fields _container_id_ and _container_name_, it adds the following
fields to the Loggly json record.

* _node_hostname_ : docker node of this logger.
* _fluentd_tag_ : fluentd-tag environment variable of client container.


Requires Docker Engine 1.8+


Step N: Start loggly
--------------------

        docker run -d --name fluentd-loggly \
            -p 24224:24224 \
            -e TOKEN=ABCD-1234-ABCD-1234 \
            -e HOST=`hostname` \
            -e LOGGLY_TAG=docker,container \
            andriyg/fluentd-loggly

* _TOKEN_ [required] is the Loggly API token.
* _HOST_ [required] is required during creation for _node_hostname_ to be populated.
* _LOGGLY_TAG_ [optional] by default is 'docker,container' and messages in Loggly will show
up with both tags.


    Note: By default, the fluentd log-driver in Docker will assume port 24224. Secure this port.


Step N: Confirm
---------------

Test the loggly container.

        docker run --rm --log-driver=fluentd ubuntu echo "Hello Fluentd!"
