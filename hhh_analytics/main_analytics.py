#! coding: utf-8

from flask import (Flask, jsonify, request, abort,
                   render_template, url_for, redirect)

import json

app = Flask(__name__,static_folder='public',
             template_folder='templates')

app.config['SECRET_KEY'] = 'asdfasdfsd'

from redis import Redis

import settings

host, port, db = settings.REDIS_ANALYTICS.split(':')
REDIS_ANALYTICS = Redis(host=host, port=int(port), db=int(db))


@app.route('/')
def home():

    return 'OK'


@app.route('/highchart_request')
def highchart_request():
    host = request.host.split(':')[0]
    request_times = REDIS_ANALYTICS.zrange(host, 0, REDIS_ANALYTICS.zcard(host))

    data = {}
    for request_time in request_times:
        data[request_time] = REDIS_ANALYTICS.get(request_time)

    data1 = {}
    for key in data:
        data1[int(key)] = int(data[key])


    import collections
    data1 = collections.OrderedDict(sorted(data1.items()))
    data_real = []

    for created_time in data1:
        bandwidth_time =  1000
        buf = [int(created_time) * 1000, int(data1[created_time])]
        data_real.append(buf)

    return render_template('request.html', result=data_real)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)
