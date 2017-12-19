#!/usr/bin/env python3

from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from datetime import datetime
from argparse import ArgumentParser
import logging
import sys
import protobix

class ZabbixSenderHTTPServer(HTTPServer):

    def __init__(self, *args, zabbix_server, zabbix_port, zabbix_host, **kwargs):

        self.zabbix_config = protobix.ZabbixAgentConfig()
        self.zabbix_config.server_active = zabbix_server
        self.zabbix_config.server_port = zabbix_port
        self.zabbix_config.hostname = zabbix_host

        # Pass the rest of the arguments to the HTTPServer superclass
        HTTPServer.__init__(self, *args, **kwargs)

class InfiniasRequestHandler(BaseHTTPRequestHandler):

    logger = logging.getLogger('http_server.request')

    ''' Convert strings from Infinias to a Zabbix key name '''
    def convertToZabbixKey(self,input,prefix='door'):
        return '{}.{}'.format(prefix,input.casefold())

    def log_message(self, format, *args):
        sys.stdout.write("%s - - [%s] %s\n" %
                         (self.address_string(),
                          self.log_date_time_string(),
                          format%args)
        )
        sys.stdout.flush()

    def do_GET(self):

        parsed_url = urlparse(self.path)
        if parsed_url.path != '/IAEvents':
            self.logger.warning("Requested path was not /IAEvents")
            self.send_error(400)
            return
        if not parsed_url.query:
            self.logger.warning("No query string")
            self.send_error(400)
            return

        params = parse_qs(parsed_url.query, keep_blank_values=True)
        # Convert the time fields to Python datetime objects
        for k in ['ServerEventUTCTime','DeviceEventUTCTime']:
            params[k][0] = datetime.strptime(params[k][0] + ' UTC', '%m/%d/%Y %I:%M:%S %p %Z')
        # Dump the provided query parameters for debugging
        self.logger.debug('Got query parameters from URL: ' + str(params))

        timestamp = int(params['DeviceEventUTCTime'][0].timestamp())
        hostname = self.server.zabbix_config.hostname

        zabbixContainer = protobix.DataContainer(config=self.server.zabbix_config,logger=logging.getLogger('protobix'))
        zabbixContainer.data_type = 'items'

        # Add a "descriptive" log line to be stored as a Zabbix Log type
        logLine = '{timestamp:%Y-%m-%d %H:%M:%S} {verb} {event} {adjective} {place} to {firstname} {lastname}'.format(
            timestamp=params['DeviceEventUTCTime'][0],
            verb=params['Action'][0],
            event=params['Event'][0],
            adjective=params['ZoneName'][0],
            place=params['DoorName'][0],
            firstname=params['FirstName'][0],
            lastname=params['LastName'][0]
        )
        zabbixContainer.add_item(hostname, self.convertToZabbixKey('log'), logLine, timestamp)

        # Add selected parameters to the Zabbix trap
        desiredParamKeys = ('Action', 'Event', 'DoorName', 'FirstName', 'LastName', 'ZoneName',)
        filteredParams = {k: v for k,v in params.items() if k in desiredParamKeys}
        for k,v in filteredParams.items():
            values = ' '.join([val for val in v if isinstance(val, str)])
            zabbixContainer.add_item(hostname, self.convertToZabbixKey(k), values, timestamp)

        try:
            (server_success, server_failure, processed, failed, total, time) = zabbixContainer.send()
        except ConnectionRefusedError:
            self.logger.critical('Could not connect to Zabbix server')
            server_success = False
            server_failure = 0
            processed = 0
            failed = 0
            total = 0
            time = 0

        msg_template = '{} sending data to Zabbix: {:d} processed, {:d} failed, {:d} total'
        if not server_success:
            msg = msg_template.format('Error', processed, failed, total)
            self.logger.error('Error sending data to Zabbix: %d processed, %d failed, %d total', processed, failed, total)
            # Send 502 Bad Gateway
            self.send_error(502)
        else:
            msg = msg_template.format('Success', processed, failed, total)
            self.logger.info(msg)
            # Send a 204 No Content
            self.send_response(204, message=msg)
            self.end_headers()

def main(args):
    # Decrease logging threshold by using lowest threshold (logging.DEBUG) as an increment size,
    # but don't go any lower than logging.DEBUG
    default_log_level = logging.WARNING
    log_level = max(default_log_level - (args.verbosity * logging.DEBUG), logging.DEBUG)
    logging.basicConfig(level=log_level)

    print('Listening on localhost:%s' % args.listen)
    sys.stdout.flush()

    server = ZabbixSenderHTTPServer(('', args.listen), InfiniasRequestHandler, zabbix_server=args.zabbix_server, zabbix_port=args.zabbix_port, zabbix_host=args.zabbix_host)
    server.serve_forever()


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument('-l','--listen', default=8080, metavar='LISTEN_PORT', type=int, help='TCP Port on which to listen for Infinias peripheral requests')
    parser.add_argument('-z','--zabbix-server', required=True, help='Hostname or IP address of Zabbix server. If a host is monitored by a proxy, proxy hostname or IP address should be used instead.')
    parser.add_argument('-p','--port', dest='zabbix_port', default=10051, type=int, help='Specify port number of Zabbix server trapper running on the server.')
    parser.add_argument('-s','--host', dest='zabbix_host', help='Specify host name the item belongs to (as registered in Zabbix frontend). Host IP address and DNS name will not work.')
    parser.add_argument('-v','--verbose', dest='verbosity', action='count', default=0, help='Specify up to 3 times to increase verbosity level')

    args = parser.parse_args()

    main(args)

