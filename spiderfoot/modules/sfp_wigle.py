#-------------------------------------------------------------------------------
# Name:         sfp_wigle
# Purpose:      Query wigle.net to identify nearby WiFi access points.
#
# Author:      Steve Micallef <steve@binarypool.com>
#
# Created:     10/09/2017
# Copyright:   (c) Steve Micallef
# Licence:     GPL
#-------------------------------------------------------------------------------

import sys
import json
import datetime
import urllib
from sflib import SpiderFoot, SpiderFootPlugin, SpiderFootEvent

class sfp_wigle(SpiderFootPlugin):
    """Wigle.net:Footprint,Investigate,Passive:Secondary Networks::Query wigle.net to identify nearby WiFi access points."""


    # Default options
    opts = { 
        "api_key_encoded": "",
        "days_limit": "365",
        "variance": "0.01"
    }

    # Option descriptions
    optdescs = {
        "api_key_encoded": "Your Base64-encoded API name/token pair, as provided on your Wigle.net account page.",
        "days_limit": "Maximum age of data to be considered valid.",
        "variance": "How tightly to bound queries against the latitude/longitude box extracted from idenified addresses. This value must be between 0.001 and 0.2."
    
    }

    # Be sure to completely clear any class variables in setup()
    # or you run the risk of data persisting between scan runs.

    results = dict()
    errorState = False

    def setup(self, sfc, userOpts=dict()):
        self.sf = sfc
        self.results = dict()
        self.errorState = False

        # Clear / reset any other class member variables here
        # or you risk them persisting between threads.

        for opt in userOpts.keys():
            self.opts[opt] = userOpts[opt]

    # What events is this module interested in for input
    def watchedEvents(self):
        return ["PHYSICAL_ADDRESS"]

    # What events this module produces
    def producedEvents(self):
        return ["WIFI_ACCESS_POINT"]

    def getcoords(self, qry):
        url = "https://api.wigle.net/api/v2/network/geocode?" + \
              urllib.urlencode({'addresscode': unicode.encode(qry, 'utf-8', errors='replace')})
        hdrs = { 
                    "Accept": "application/json",
                    "Authorization": "Basic " + self.opts['api_key_encoded']
               }

        res = self.sf.fetchUrl(url, timeout=30, 
                               useragent="SpiderFoot", headers=hdrs)
        if res['code'] == "404" or not res['content']:
            return None
        if "too many queries" in res['content']:
            self.sf.error("Wigle.net query limit reached for the day.", False)
            return None

        try:
            info = json.loads(res['content'])
            if len(info.get('results', [])) == 0:
                return None
            return info['results'][0]['boundingbox']
        except Exception as e:
            self.sf.error("Error processing JSON response from Wigle.net: " + str(e), False)
            return None

    def getnetworks(self, coords):
        url = "https://api.wigle.net/api/v2/network/search?onlymine=false&" + \
              "latrange1=" + str(coords[0]) + "&latrange2=" + str(coords[1]) + \
              "&longrange1=" + str(coords[2]) + "&longrange2=" + str(coords[3]) + \
              "&freenet=false&paynet=false&variance=" + self.opts['variance']

        if self.opts['days_limit'] != "0":
            dt = datetime.datetime.now() - datetime.timedelta(days=int(self.opts['days_limit']))
            date_calc = dt.strftime("%Y%m%d")
            url += "&lastupdt=" + date_calc

        hdrs = {
                    "Accept": "application/json",
                    "Authorization": "Basic " + self.opts['api_key_encoded']
               }

        res = self.sf.fetchUrl(url, timeout=30,
                               useragent="SpiderFoot", headers=hdrs)
        if res['code'] == "404" or not res['content']:
            return None
        if "too many queries" in res['content']:
            self.sf.error("Wigle.net query limit reached for the day.", False)
            return None

        ret = list()
        try:
            info = json.loads(res['content'])
            if len(info.get('results', [])) == 0:
                return None
            for r in info['results']:
                if None not in [r['ssid'], r['netid']]:
                    ret.append(r['ssid'] + " (Net ID: " + r['netid'] + ")")
            return ret
        except Exception as e:
            self.sf.error("Error processing JSON response from Wigle.net: " + str(e), False)
            return None


    # Handle events sent to this module
    def handleEvent(self, event):
        eventName = event.eventType
        srcModuleName = event.module
        eventData = event.data

        if self.errorState:
            return None

        if self.opts['api_key_encoded'] == "":
            self.sf.error("You enabled sfp_wigle but did not set an API key!", False)
            self.errorState = True
            return None

        self.sf.debug("Received event, " + eventName + ", from " + srcModuleName)

       # Don't look up stuff twice
        if eventData in self.results:
            self.sf.debug("Skipping " + eventData + " as already mapped.")
            return None
        else:
            self.results[eventData] = True

        coords = self.getcoords(eventData)
        if not coords:
            self.sf.error("Couldn't get coordinates for address from Wigle.net.", False)
            return None

        nets = self.getnetworks(coords)
        if not nets:
            self.sf.error("Couldn't get networks for coordinates from Wigle.net.", False)
            return None

        for n in nets:
            e = SpiderFootEvent("WIFI_ACCESS_POINT", n, self.__name__, event)
            self.notifyListeners(e)

# End of sfp_wigle class
