#! coding: utf-8


from gevent import monkey
monkey.patch_all()

from gevent.server import DatagramServer
from redis import Redis

import time
import settings

host, port, db = settings.REDIS_ANALYTICS.split(':')
REDIS_ANALYTICS = Redis(host=host, port=int(port), db=int(db))

class StatsdServer(DatagramServer):
    """
        StatsdServer object.
    """

    @staticmethod
    def process_request(line):
        host = line.split('_')[0]
        key = int(time.time())

        REDIS_ANALYTICS.incr(key)
        REDIS_ANALYTICS.zadd(host, key, key)



        return ''

    def handle(self, data, address):
        print('%s: got %r' % (address[0], data))

        self.process_request(data)
        self.socket.sendto('', address)


if __name__ == '__main__':
    print('Receiving metrics on :8125')
    StatsdServer(':8125').serve_forever()
