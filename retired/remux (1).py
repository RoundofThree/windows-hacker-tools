#!/usr/bin/env python

'''
REMUX - A Reverse Multiplexing TCP Relay
'''

import urllib2
import socket
import thread
import select
import random
import traceback
import sys

BUFLEN = 8192
bar_open = '%s%s' % ('\033[31m', '-'*60)
bar_close = '%s%s' % ('-'*60, '\033[m')

if len(sys.argv) > 1:
    proxies = open(sys.argv[1]).read().split()
else:
    proxies = urllib2.urlopen('http://rmccurdy.com/scripts/proxy/good.txt').read().split()

lock = thread.allocate_lock()

class ConnectionHandler:
    def __init__(self, connection, address, timeout):
        self.client = connection
        self.client_buffer = ''
        self.timeout = timeout
        while True:
            try:
                proxy = random.choice(proxies)
            except IndexError:
                safe_print('Proxy list is empty.')
                return
            try:
                #safe_print('%s >>> CONNECTING...' % (proxy))
                self._connect_target(proxy)
                break
            except Exception as e:
                if not isinstance(e, socket.error):
                    # catchall for debugging
                    safe_print('%s\n%s\n%s' % (bar_open, traceback.format_exc().strip(), bar_close))
                # filter out the bad proxy that generated the exception
                try:
                    # raises ValueError if another thread
                    # has already removed the same proxy
                    proxies.remove(proxy)
                    safe_print('%s >>> REMOVED [%d]' % (proxy, len(proxies)))
                except ValueError:
                    pass
        self.c_host = ':'.join([str(x) for x in self.client.getpeername()])
        self.t_host = ':'.join([str(x) for x in self.target.getpeername()])
        safe_print('%s <<< ESTABLISHED >>> %s' % (self.c_host, self.t_host))
        try:
            self._read_write()
        except:
            # catchall for debugging
            safe_print('%s\n%s\n%s' % (bar_open, traceback.format_exc().strip(), bar_close))
        self.client.close()
        self.target.close()

    def _connect_target(self, proxy):
        i = proxy.index(':')
        host = proxy[:i]
        port = int(proxy[i+1:])
        (soc_family, _, _, _, address) = socket.getaddrinfo(host, port)[0]
        self.target = socket.socket(soc_family)
        self.target.settimeout(self.timeout)
        self.target.connect(address)

    def _read_write(self):
        time_out_max = self.timeout/3
        socs = [self.client, self.target]
        count = 0
        while 1:
            count += 1
            (recv, _, error) = select.select(socs, [], socs, 3) # debug reset here
            if error:
                break
            if recv:
                for in_ in recv:
                    data = in_.recv(BUFLEN)
                    if in_ is self.client:
                        out = self.target
                        pattern = '%s %d bytes >>> %s'
                    else:
                        # look at data here to filter proxies
                        # will break SOCKS functionality
                        #safe_print(data.split()[0])
                        out = self.client
                        pattern = '%s <<< %d bytes %s'
                    if data:
                        out.send(data)
                        count = 0
                    #safe_print(pattern % (self.c_host, len(data), self.t_host))
            if count == time_out_max:
                break

def safe_print(data):
    lock.acquire()
    print(data)
    lock.release()

def start_server(host='localhost', port=8080, IPv6=False, timeout=6, handler=ConnectionHandler):
    if IPv6==True:
        soc_type=socket.AF_INET6
    else:
        soc_type=socket.AF_INET
    soc = socket.socket(soc_type)
    soc.bind((host, port))
    print('Serving on %s:%d...'%(host, port))
    soc.listen(0)
    while 1:
        try:
            thread.start_new_thread(handler, soc.accept()+(timeout,))
        except KeyboardInterrupt:
            sys.stdout.write('\r')
            break
    # save filtered proxies for later use
    try:
        filename = raw_input('Filename to save filtered proxies [good.txt]: ')
        if not filename: filename = 'good.txt'
        fp = open(filename, 'wb')
        for proxy in proxies:
            fp.write(proxy+'\n')
        fp.close()
        print('Proxies saved to \'%s\'.' % (filename))
    except KeyboardInterrupt:
        print('\nSave aborted.')
    except Exception as e:
        print('Save failed! [%s]' % (e.__str__()))
    finally:
        print('Exiting...')

if __name__ == '__main__':
    start_server()

