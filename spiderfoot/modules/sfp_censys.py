# -*- coding: utf-8 -*-
# -------------------------------------------------------------------------------
# Name:         sfp_censys
# Purpose:      Query censys.io using their API
#
# Author:      Steve Micallef
#
# Created:     01/02/2017
# Copyright:   (c) Steve Micallef 2017
# Licence:     GPL
# -------------------------------------------------------------------------------

import json
import base64
from datetime import datetime
import time
from netaddr import IPNetwork
from sflib import SpiderFoot, SpiderFootPlugin, SpiderFootEvent

class sfp_censys(SpiderFootPlugin):
    """Censys:Investigate,Passive:Search Engines:apikey:Obtain information from Censys.io"""


    # Default options
    opts = {
        "censys_api_key_uid": "",
        "censys_api_key_secret": "",
        "age_limit_days": 90
    }

    # Option descriptions
    optdescs = {
        "censys_api_key_uid": "Your Censys.io API UID",
        "censys_api_key_secret": "Your Censys.io API Secret",
        "age_limit_days": "Ignore any records older than this many days. 0 = unlimited."
    }

    # Be sure to completely clear any class variables in setup()
    # or you run the risk of data persisting between scan runs.

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
        return ["IP_ADDRESS", "INTERNET_NAME", "NETBLOCK_OWNER"]

    # What events this module produces
    def producedEvents(self):
        return ["BGP_AS_MEMBER", "TCP_PORT_OPEN", "OPERATING_SYSTEM", 
                "WEBSERVER_HTTPHEADERS", "NETBLOCK_MEMBER", "GEOINFO"]

    def query(self, qry, querytype):
        ret = None

        if querytype == "ip":
            querytype = "ipv4/{0}"
        if querytype == "host":
            querytype = "websites/{0}"
        
        censys_url = "https://censys.io/api/v1/view"
        headers = {
            'Authorization': "Basic " + base64.b64encode(self.opts['censys_api_key_uid'] + ":" + self.opts['censys_api_key_secret'])
        }
        url = censys_url + "/" + querytype.format(qry)
        res = self.sf.fetchUrl(url , timeout=self.opts['_fetchtimeout'], 
                               useragent="SpiderFoot", headers=headers)

        if res['code'] in [ "400", "429", "500", "403" ]:
            self.sf.error("Censys.io API key seems to have been rejected or you have exceeded usage limits for the month.", False)
            self.errorState = True
            return None

        if res['content'] is None:
            self.sf.info("No Censys.io info found for " + qry)
            return None

        try:
            info = json.loads(res['content'])
        except Exception as e:
            self.sf.error("Error processing JSON response from Censys.io.", False)
            return None

        #print str(info)
        return info


    # Handle events sent to this module
    def handleEvent(self, event):
        eventName = event.eventType
        srcModuleName = event.module
        eventData = event.data

        if self.errorState:
            return None

        self.sf.debug("Received event, " + eventName + ", from " + srcModuleName)

        if self.opts['censys_api_key_uid'] == "" or self.opts['censys_api_key_secret'] == "":
            self.sf.error("You enabled sfp_censys but did not set an API uid/secret!", False)
            self.errorState = True
            return None

        # Don't look up stuff twice
        if eventData in self.results:
            self.sf.debug("Skipping " + eventData + " as already mapped.")
            return None
        else:
            self.results[eventData] = True

        qrylist = list()
        if eventName.startswith("NETBLOCK_"):
            for ipaddr in IPNetwork(eventData):
                qrylist.append(str(ipaddr))
                self.results[str(ipaddr)] = True
        else:
            qrylist.append(eventData)

        for addr in qrylist:
            if self.checkForStop():
                return None

            if eventName in [ "IP_ADDRESS", "NETLBLOCK_OWNER"]:
                qtype = "ip"
            else:
                qtype = "host"

            rec = self.query(addr, qtype)
            if rec is not None:
                self.sf.debug("Found results in Censys.io")
                # 2016-12-24T07:25:35+00:00'
                created_dt = datetime.strptime(rec.get('updated_at'), '%Y-%m-%dT%H:%M:%S+00:00')
                created_ts = int(time.mktime(created_dt.timetuple()))
                age_limit_ts = int(time.time()) - (86400 * self.opts['age_limit_days'])
                if self.opts['age_limit_days'] > 0 and created_ts < age_limit_ts:
                    self.sf.debug("Record found but too old, skipping.")
                    continue
                if 'location' in rec:
                    dat = rec['location'].get('country')
                    if dat:
                        e = SpiderFootEvent("GEOINFO", dat, self.__name__, event)
                        self.notifyListeners(e)

                if 'headers' in rec:
                    dat = rec['headers']
                    e = SpiderFootEvent("WEBSERVER_HTTPHEADERS", dat, self.__name__, event)
                    self.notifyListeners(e)

                if 'autonomous_system' in rec:
                    dat = str(rec['autonomous_system']['asn'])
                    e = SpiderFootEvent("BGP_AS_MEMBER", dat, self.__name__, event)
                    self.notifyListeners(e)
                    dat = rec['autonomous_system']['routed_prefix']
                    e = SpiderFootEvent("NETBLOCK_MEMBER", dat, self.__name__, event)
                    self.notifyListeners(e)

                if 'protocols' in rec:
                    for p in rec['protocols']:
                        if 'ip' not in rec:
                            continue
                        dat = rec['ip'] + ":" + p.split("/")[0]
                        e = SpiderFootEvent("TCP_PORT_OPEN", dat, self.__name__, event)
                        self.notifyListeners(e)

                if 'metadata' in rec:
                    if 'os_description' in rec['metadata']:
                        dat = rec['metadata']['os_description']
                        e = SpiderFootEvent("OPERATING_SYSTEM", dat, self.__name__, event)
                        self.notifyListeners(e)
    
# End of sfp_censys class
