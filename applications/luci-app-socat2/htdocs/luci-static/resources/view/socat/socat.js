'use strict';
'require view';
'require dom';
'require poll';
'require uci';
'require rpc';
'require form';
'require luci';



return view.extend({
    render: function (data) {

        var m, s, o,dest_ipv4;

        m = new form.Map('socat', ['Socat'],
            _('Socat is a versatile networking tool named after \'Socket CAT\', which can be regarded as an N-fold enhanced version of NetCat'));
        m.redirect = luci.dispatcher.build_url("admin", "network", "socat")
        s = m.section(NamedSection, 'global', 'global',_('Socat Config'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(Flag, "enable", translate("Enable"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(Value, "remarks", translate("Remarks"));
        o.default = translate("Remarks");
        o.rmempty = false;

        o = s.option(ListValue, "protocol", translate("Protocol"));
        o.value("port_forwards", translate("Port Forwards"));

        o = s.option(ListValue, "family", translate("Restrict to address family"));
        o.value("", translate("IPv4 and IPv6"));
        o.value("4", translate("IPv4 only"));
        o.value("6", translate("IPv6 only"));
        o.depends("protocol", "port_forwards");

        o = s.option(ListValue, "proto", translate("Protocol"));
        o.value("tcp", "TCP");
        o.value("udp", "UDP");
        o.depends("protocol", "port_forwards");

        o = s.option(Value, "listen_port", translate("Listen port"));
        o.datatype = "portrange";
        o.rmempty = false;
        o.depends("protocol", "port_forwards");

        o = s.option(Flag, "reuseaddr", translate("REUSEADDR"), translate("Bind to a port local"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(ListValue, "dest_proto", translate("Destination Protocol"));
        o.value("tcp4", "IPv4-TCP");
        o.value("udp4", "IPv4-UDP");
        o.value("tcp6", "IPv6-TCP");
        o.value("udp6", "IPv6-UDP");
        o.depends("protocol", "port_forwards");

        dest_ipv4 = s.option(Value, "dest_ipv4", translate("Destination address"))
        luci.sys.net.ipv4_hints(function(ip, name){
        dest_ipv4.value(ip, "%s (%s)" %{ ip, name });
        });







        return m.render().then(L.bind(function (m, nodes) {
            poll.add(L.bind(function () {
                return Promise.all([
                    callUpnpGetStatus()
                ]).then(L.bind(this.poll_status, this, nodes));
            }, this), 5);
            return nodes;
        }, this, m));
    }
});