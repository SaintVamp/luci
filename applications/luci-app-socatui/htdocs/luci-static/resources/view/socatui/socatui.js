'use strict';
'require form';
'require view';
'require uci';



// callSocatGetStatus = rpc.declare({
//     object: 'luci.socatui',
//     method: 'get_status',
//     expect: {  }
// });

return view.extend({
    load: function() {
        return Promise.all([
            // callSocatGetStatus(),
            uci.load('socatui')
        ]);
    },
    render: function (data) {

        var m, s, o,dest_ipv4;

        m = new form.Map('socatui', ['Socat'],
            _('Socat is a versatile networking tool named after \'Socket CAT\', which can be regarded as an N-fold enhanced version of NetCat'));

        s = m.section(form.GridSection, 'global', 'global',_('Socat Config'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, "enable", _("Enable"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.Value, "remarks", _("Remarks"));
        o.default = _("Remarks");
        o.rmempty = false;

        o = s.option(form.ListValue, "protocol", _("Protocol"));
        o.value("port_forwards", _("Port Forwards"));

        o = s.option(form.ListValue, "family", _("Restrict to address family"));
        o.value("", _("IPv4 and IPv6"));
        o.value("4", _("IPv4 only"));
        o.value("6", _("IPv6 only"));
        o.depends("protocol", "port_forwards");

        // o = s.option(form.ListValue, "proto", _("Protocol"));
        // o.value("tcp", "TCP");
        // o.value("udp", "UDP");
        // o.depends("protocol", "port_forwards");
        //
        // o = s.option(form.Value, "listen_port", _("Listen port"));
        // o.datatype = "portrange";
        // o.rmempty = false;
        // o.depends("protocol", "port_forwards");
        //
        // o = s.option(form.Flag, "reuseaddr", _("REUSEADDR"), _("Bind to a port local"));
        // o.default = "1";
        // o.rmempty = false;
        //
        // o = s.option(form.ListValue, "dest_proto", _("Destination Protocol"));
        // o.value("tcp4", "IPv4-TCP");
        // o.value("udp4", "IPv4-UDP");
        // o.value("tcp6", "IPv6-TCP");
        // o.value("udp6", "IPv6-UDP");
        // o.depends("protocol", "port_forwards");
        //
        // dest_ipv4 = s.option(form.Value, "dest_ipv4", _("Destination address"))
        // luci.sys.net.ipv4_hints(function(ip, name){
        // dest_ipv4.value(ip, "%s (%s)" %{ ip, name });
        // });
        //






        return m.render();
    }
});