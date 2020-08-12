# -*- coding: utf-8 -*-
# -------------------------------------------------------------------------------
# Name:         sfp_bingsharedip
# Purpose:      Searches Bing for hosts sharing the same IP.
#
# Author:      Steve Micallef <steve@binarypool.com>
#
# Created:     12/04/2014
# Copyright:   (c) Steve Micallef 2014
# Licence:     GPL
# -------------------------------------------------------------------------------

import re
import socket
from netaddr import IPNetwork
from sflib import SpiderFoot, SpiderFootPlugin, SpiderFootEvent


class sfp_bingsharedip(SpiderFootPlugin):
    """Bing (Shared IPs):Footprint,Investigate,Passive:Search Engines:errorprone:Search Bing for hosts sharing the same IP."""


    # Default options
    opts = {
        'cohostsamedomain': False,
        'pages': 20,
        'verify': True
    }

    # Option descriptions
    optdescs = {
        'cohostsamedomain': "Treat co-hosted sites on the same target domain as co-hosting?",
        'pages': "How many pages of results to iterate through.",
        'verify': "Verify co-hosts are valid by checking if they still resolve to the shared IP."
    }

    results = list()

    def setup(self, sfc, userOpts=dict()):
        self.sf = sfc
        self.results = list()
        self.__dataSource__ = "Bing"

        for opt in userOpts.keys():
            self.opts[opt] = userOpts[opt]

    # What events is this module interested in for input
    def watchedEvents(self):
        return ["IP_ADDRESS", "NETBLOCK_OWNER"]

    # What events this module produces
    # This is to support the end user in selecting modules based on events
    # produced.
    def producedEvents(self):
        return ["CO_HOSTED_SITE", "SEARCH_ENGINE_WEB_CONTENT"]

    def validateIP(self, host, ip):
        try:
            addrs = socket.gethostbyname_ex(host)
        except BaseException as e:
            self.sf.debug("Unable to resolve " + host + ": " + str(e))
            return False

        for addr in addrs:
            if type(addr) == list:
                for a in addr:
                    if str(a) == ip:
                        return True
            else:
                if str(addr) == ip:
                    return True
        return False

    # Handle events sent to this module
    def handleEvent(self, event):
        eventName = event.eventType
        srcModuleName = event.module
        eventData = event.data
        self.currentEventSrc = event

        self.sf.debug("Received event, " + eventName + ", from " + srcModuleName)

        # Don't look up stuff twice
        if eventData in self.results:
            self.sf.debug("Skipping " + eventData + " as already mapped.")
            return None

        qrylist = list()
        if eventName.startswith("NETBLOCK_"):
            for ipaddr in IPNetwork(eventData):
                if str(ipaddr) not in self.results:
                    qrylist.append(str(ipaddr))
                    self.results.append(str(ipaddr))
        else:
            qrylist.append(eventData)
            self.results.append(eventData)

        myres = list()

        for ip in qrylist:
            if self.checkForStop():
                return None

            results = self.sf.bingIterate("ip:" + ip, dict(limit=self.opts['pages'],
                                                           useragent=self.opts['_useragent'],
                                                           timeout=self.opts['_fetchtimeout']))
            if results is None:
                self.sf.info("No data returned from Bing.")
                continue

            for key in results.keys():
                res = results[key]
                pat = re.compile("<h2><a href=\"(\S+)\"", re.IGNORECASE)
                matches = re.findall(pat, res)
                for match in matches:
                    self.sf.info("Found something on same IP: " + match)
                    site = self.sf.urlFQDN(match.lower())
                    if site not in myres and site != ip:
                        if not self.opts['cohostsamedomain']:
                            if self.getTarget().matches(site, includeParents=True):
                                self.sf.debug("Skipping " + site + " because it is on the same domain.")
                                continue
                        if self.opts['verify'] and not self.validateIP(site, ip):
                            self.sf.debug("Host no longer resolves to our IP.")
                            continue
                        evt = SpiderFootEvent("CO_HOSTED_SITE", site, self.__name__, event)
                        self.notifyListeners(evt)
                        myres.append(site)

                # Submit the bing results for analysis
                evt = SpiderFootEvent("SEARCH_ENGINE_WEB_CONTENT", results[key],
                                      self.__name__, event)
                self.notifyListeners(evt)

# End of sfp_bingsharedip class
