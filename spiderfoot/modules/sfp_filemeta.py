# -*- coding: utf-8 -*-
# -------------------------------------------------------------------------------
# Name:         sfp_filemeta
# Purpose:      From Spidering and from searching search engines, extracts file
#               meta data from files matching certain file extensions.
#
# Author:      Steve Micallef <steve@binarypool.com>
#
# Created:     25/04/2014
# Copyright:   (c) Steve Micallef 2014
# Licence:     GPL
# -------------------------------------------------------------------------------

import mimetypes
import PyPDF2
import openxmllib
import exifread
import lxml
from StringIO import StringIO
from sflib import SpiderFoot, SpiderFootPlugin, SpiderFootEvent


class sfp_filemeta(SpiderFootPlugin):
    """File Metadata:Footprint:Content Analysis:invasive,slow:Extracts meta data from documents and images."""


    # Default options
    opts = {
        'fileexts': ["docx", "pptx", 'xlsx', 'pdf', 'jpg', 'jpeg', 'tiff', 'tif'],
        'timeout': 300
    }

    # Option descriptions
    optdescs = {
        'fileexts': "File extensions of files you want to analyze the meta data of (only PDF, DOCX, XLSX and PPTX are supported.)",
        'timeout': "Download timeout for files, in seconds."
    }

    results = list()

    def setup(self, sfc, userOpts=dict()):
        self.sf = sfc
        self.results = list()

        for opt in userOpts.keys():
            self.opts[opt] = userOpts[opt]

    # What events is this module interested in for input
    def watchedEvents(self):
        return ["LINKED_URL_INTERNAL", "INTERESTING_FILE"]

    # What events this module produces
    # This is to support the end user in selecting modules based on events
    # produced.
    def producedEvents(self):
        return ["RAW_FILE_META_DATA", "SOFTWARE_USED"]

    # Handle events sent to this module
    def handleEvent(self, event):
        eventName = event.eventType
        srcModuleName = event.module
        eventData = event.data

        self.sf.debug("Received event, " + eventName + ", from " + srcModuleName)

        if eventData in self.results:
            return None
        else:
            self.results.append(eventData)

        for fileExt in self.opts['fileexts']:
            if self.checkForStop():
                return None

            if "." + fileExt.lower() in eventData.lower():
                # Fetch the file, allow much more time given that these files are
                # typically large.
                ret = self.sf.fetchUrl(eventData, timeout=self.opts['timeout'],
                                       useragent=self.opts['_useragent'], dontMangle=True,
                                       sizeLimit=10000000)
                if ret['content'] is None:
                    self.sf.error("Unable to fetch file for meta analysis: " +
                                  eventData, False)
                    return None

                if len(ret['content']) < 512:
                    self.sf.error("Strange content encountered, size of " +
                                  str(len(ret['content'])), False)
                    return None

                meta = None
                data = None
                # Based on the file extension, handle it
                if fileExt.lower() == "pdf":
                    try:
                        raw = StringIO(ret['content'])
                        #data = metapdf.MetaPdfReader().read_metadata(raw)
                        pdf = PyPDF2.PdfFileReader(raw, strict=False)
                        data = pdf.getDocumentInfo()
                        meta = str(data)
                        self.sf.debug("Obtained meta data from " + eventData)
                    except BaseException as e:
                        self.sf.error("Unable to parse meta data from: " +
                                      eventData + "(" + str(e) + ")", False)
                        return None

                if fileExt.lower() in ["pptx", "docx", "xlsx"]:
                    try:
                        mtype = mimetypes.guess_type(eventData)[0]
                        doc = openxmllib.openXmlDocument(data=ret['content'], mime_type=mtype)
                        self.sf.debug("Office type: " + doc.mimeType)
                        data = doc.allProperties
                        meta = str(data)
                    except ValueError as e:
                        self.sf.error("Unable to parse meta data from: " +
                                      eventData + "(" + str(e) + ")", False)
                        return None
                    except lxml.etree.XMLSyntaxError as e:
                        self.sf.error("Unable to parse XML within: " +
                                      eventData + "(" + str(e) + ")", False)
                        return None
                    except BaseException as e:
                        self.sf.error("Unable to process file: " +
                                      eventData + "(" + str(e) + ")", False)
                        return None

                if fileExt.lower() in ["jpg", "jpeg", "tiff"]:
                    try:
                        raw = StringIO(ret['content'])
                        data = exifread.process_file(raw)
                        if data is None or len(data) == 0:
                            continue
                        meta = str(data)
                    except BaseException as e:
                        self.sf.error("Unable to parse meta data from: " +
                                      eventData + "(" + str(e) + ")", False)
                        return None

                if meta is not None and data is not None:
                    evt = SpiderFootEvent("RAW_FILE_META_DATA", meta,
                                          self.__name__, event)
                    self.notifyListeners(evt)

                    val = None
                    try:
                        if "/Producer" in data:
                            val = data['/Producer']

                        if "/Creator" in data:
                            if "/Producer" in data:
                                if data['/Creator'] != data['/Producer']:
                                    val = data['/Creator']
                            else:
                                val = data['/Creator']

                        if "Application" in data:
                            val = data['Application']

                        if "Image Software" in data:
                            val = str(data['Image Software'])
                    except BaseException as e:
                        self.sf.error("Failed to parse PDF, " + eventData + ": " + str(e), False)
                        return None

                    if val is not None:
                        # Strip non-ASCII
                        val = ''.join([i if ord(i) < 128 else ' ' for i in val])
                        evt = SpiderFootEvent("SOFTWARE_USED", val,
                                              self.__name__, event)
                        self.notifyListeners(evt)

# End of sfp_filemeta class
