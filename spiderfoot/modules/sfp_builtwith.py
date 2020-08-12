#-------------------------------------------------------------------------------
# Name:         sfp_builtwith
# Purpose:      Query builtwith.com using their API.
#
# Author:      Steve Micallef <steve@binarypool.com>
#
# Created:     10/08/2017
# Copyright:   (c) Steve Micallef
# Licence:     GPL
#-------------------------------------------------------------------------------

import sys
import json
import time
from sflib import SpiderFoot, SpiderFootPlugin, SpiderFootEvent

class sfp_builtwith(SpiderFootPlugin):
    """BuiltWith:Footprint,Investigate,Passive:Search Engines:apikey:Query BuiltWith.com's Domain API for information about your target's web technology stack, e-mail addresses and more."""


    # Default options
    opts = { 
        "api_key": "",
        "maxage": 30
    }

    # Option descriptions
    optdescs = {
        "api_key": "Your Domain API key from builtwith.com.",
        "maxage": "The maximum age of the data returned, in days, in order to be considered valid."
    }

    # Be sure to completely clear any class variables in setup()
    # or you run the risk of data persisting between scan runs.

    results = dict()

    def setup(self, sfc, userOpts=dict()):
        self.sf = sfc
        self.results = dict()

        # Clear / reset any other class member variables here
        # or you risk them persisting between threads.

        for opt in userOpts.keys():
            self.opts[opt] = userOpts[opt]

    # What events is this module interested in for input
    def watchedEvents(self):
        return [ "DOMAIN_NAME" ]

    # What events this module produces
    def producedEvents(self):
        return [ "INTERNET_NAME", "EMAILADDR", "HUMAN_NAME", 
                 "WEB_TECHNOLOGY", "PHONE_NUMBER" ]

    def query(self, t):
        ret = None

        url = "https://api.builtwith.com/v11/api.json?LOOKUP=" + t + "&KEY=" + self.opts['api_key']

        res = self.sf.fetchUrl(url, timeout=self.opts['_fetchtimeout'], 
            useragent="SpiderFoot")

        if res['code'] == "404":
            return None

        if not res['content']:
            return None

        try:
            ret = json.loads(res['content'])['Results'][0]
        except Exception as e:
            self.sf.error("Error processing JSON response from builtwith.com: " + str(e), False)
            return None

        return ret

    # Handle events sent to this module
    def handleEvent(self, event):
        eventName = event.eventType
        srcModuleName = event.module
        eventData = event.data

        self.sf.debug("Received event, " + eventName + ", from " + srcModuleName)

       # Don't look up stuff twice
        if self.results.has_key(eventData):
            self.sf.debug("Skipping " + eventData + " as already mapped.")
            return None
        else:
            self.results[eventData] = True

        data = self.query(eventData)
        if data == None:
            return None

        if "Meta" in data:
            if data['Meta'].get("Names", []):
                for nb in data['Meta']['Names']:
                    e = SpiderFootEvent("HUMAN_NAME", nb['Name'], 
                                        self.__name__, event)
                    self.notifyListeners(e)
                    if nb.get('Email', None):
                        e = SpiderFootEvent("EMAILADDR", nb['Email'], 
                                            self.__name__, event)
                        self.notifyListeners(e)

            if data['Meta'].get("Emails", []):
                for email in data['Meta']['Emails']:
                    e = SpiderFootEvent("EMAILADDR", email,
                                        self.__name__, event)
                    self.notifyListeners(e)

            if data['Meta'].get("Telephones", []):
                for phone in data['Meta']['Telephones']:
                    e = SpiderFootEvent("PHONE_NUMBER", phone,
                                        self.__name__, event)
                    self.notifyListeners(e)

        if "Paths" in data.get("Result", []):
            for p in data["Result"]['Paths']:
                if p.get("SubDomain", ""):
                    ev = SpiderFootEvent("INTERNET_NAME", 
                                        p["SubDomain"] + "." + eventData,
                                        self.__name__, event)
                    self.notifyListeners(ev)
                else:
                    ev = None

                # If we have a subdomain, let's get its tech info
                # and associate it with the subdomain event.
                for t in p.get("Technologies", []):
                    if ev:
                        src = ev
                    else:
                        src = event
                    agelimit = int(time.time() * 1000) - (86400000 * self.opts['maxage'])
                    if t.get("LastDetected", 0) < agelimit:
                        self.sf.debug("Data found too old, skipping.")
                        continue
                    e = SpiderFootEvent("WEBSERVER_TECHNOLOGY", t["Name"],
                                        self.__name__, src)
                    self.notifyListeners(e)

# End of sfp_builtwith class
