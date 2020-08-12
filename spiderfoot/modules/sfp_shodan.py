# -*- coding: utf-8 -*-
# -------------------------------------------------------------------------------
# Name:         sfp_shodan
# Purpose:      Query SHODAN for identified IP addresses.
#
# Author:      Steve Micallef <steve@binarypool.com>
#
# Created:     19/03/2014
# Copyright:   (c) Steve Micallef
# Licence:     GPL
# -------------------------------------------------------------------------------

import json
from netaddr import IPNetwork
from sflib import SpiderFoot, SpiderFootPlugin, SpiderFootEvent


class sfp_shodan(SpiderFootPlugin):
    """SHODAN:Footprint,Investigate,Passive:Search Engines:apikey:Obtain information from SHODAN about identified IP addresses."""


    # Default options
    opts = {
        "api_key": "",
        'netblocklookup': True,
        'maxnetblock': 24
    }

    # Option descriptions
    optdescs = {
        "api_key": "Your SHODAN API Key.",
        'netblocklookup': "Look up all IPs on netblocks deemed to be owned by your target for possible hosts on the same target subdomain/domain?",
        'maxnetblock': "If looking up owned netblocks, the maximum netblock size to look up all IPs within (CIDR value, 24 = /24, 16 = /16, etc.)"
    }

    results = dict()
    errorState = False

    def setup(self, sfc, userOpts=dict()):
        self.sf = sfc
        self.results = dict()

        # Clear / reset any other class member variables here
        # or you risk them persisting between threads.

        for opt in userOpts.keys():
            self.opts[opt] = userOpts[opt]

    # What events is this module interested in for input
    def watchedEvents(self):
        return ["IP_ADDRESS", "NETBLOCK_OWNER"]

    # What events this module produces
    def producedEvents(self):
        return ["OPERATING_SYSTEM", "DEVICE_TYPE",
                "TCP_PORT_OPEN", "TCP_PORT_OPEN_BANNER"]

    def query(self, qry):
        res = self.sf.fetchUrl("https://api.shodan.io/shodan/host/" + qry +
                               "?key=" + self.opts['api_key'],
                               timeout=self.opts['_fetchtimeout'], useragent="SpiderFoot")
        if res['content'] is None:
            self.sf.info("No SHODAN info found for " + qry)
            return None

        try:
            info = json.loads(res['content'])
        except Exception as e:
            self.sf.error("Error processing JSON response from SHODAN.", False)
            return None

        return info

    # Handle events sent to this module
    def handleEvent(self, event):
        eventName = event.eventType
        srcModuleName = event.module
        eventData = event.data

        if self.errorState:
            return None

        self.sf.debug("Received event, " + eventName + ", from " + srcModuleName)

        if self.opts['api_key'] == "":
            self.sf.error("You enabled sfp_shodan but did not set an API key!", False)
            self.errorState = True
            return None

            # Don't look up stuff twice
        if eventData in self.results:
            self.sf.debug("Skipping " + eventData + " as already mapped.")
            return None
        else:
            self.results[eventData] = True

        if eventName == 'NETBLOCK_OWNER':
            if not self.opts['netblocklookup']:
                return None
            else:
                if IPNetwork(eventData).prefixlen < self.opts['maxnetblock']:
                    self.sf.debug("Network size bigger than permitted: " +
                                  str(IPNetwork(eventData).prefixlen) + " > " +
                                  str(self.opts['maxnetblock']))
                    return None

        qrylist = list()
        if eventName.startswith("NETBLOCK_"):
            for ipaddr in IPNetwork(eventData):
                qrylist.append(str(ipaddr))
                self.results[str(ipaddr)] = True
        else:
            qrylist.append(eventData)

        for addr in qrylist:
            rec = self.query(addr)
            if rec is None:
                continue

            if self.checkForStop():
                return None

            if rec.get('os') is not None:
                # Notify other modules of what you've found
                evt = SpiderFootEvent("OPERATING_SYSTEM", rec.get('os') +
                                      " (" + addr + ")", self.__name__, event)
                self.notifyListeners(evt)

            if rec.get('devtype') is not None:
                # Notify other modules of what you've found
                evt = SpiderFootEvent("DEVICE_TYPE", rec.get('devtype') +
                                      " (" + addr + ")", self.__name__, event)
                self.notifyListeners(evt)

            if 'data' in rec:
                self.sf.info("Found SHODAN data for " + eventData)
                for r in rec['data']:
                    port = str(r.get('port'))
                    banner = r.get('banner')

                    if port is not None:
                        # Notify other modules of what you've found
                        cp = addr + ":" + port
                        evt = SpiderFootEvent("TCP_PORT_OPEN", cp,
                                              self.__name__, event)
                        self.notifyListeners(evt)

                    if banner is not None:
                        # Notify other modules of what you've found
                        evt = SpiderFootEvent("TCP_PORT_OPEN_BANNER", banner,
                                              self.__name__, event)
                        self.notifyListeners(evt)

        return None

# End of sfp_shodan class
