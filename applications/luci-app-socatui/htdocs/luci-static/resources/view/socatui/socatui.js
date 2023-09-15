'use strict';
'require form';
'require view';
'require uci';
'require dispatcher';


// callSocatGetStatus = rpc.declare({
//     object: 'luci.socatui',
//     method: 'get_status',
//     expect: {  }
// });

return view.extend({
    load: function () {
        return Promise.all([
            // callSocatGetStatus(),
            uci.load('socatui')
        ]);
    },
    render: function (data) {

        var m, s, o, dest_ipv4, dest_ipv6;

        m = new form.Map('socatui', ['Socat'],
            _('Socat is a versatile networking tool named after \'Socket CAT\', which can be regarded as an N-fold enhanced version of NetCat'));

        s = m.section(form.NamedSection, 'global', 'global', _('Socat Config'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, "enable", _("Enable"));
        o.rmempty = false;


        s = m.section(form.TypedSection, "config", _("Port Forwards"))
        s.anonymous = true
        s.addremove = true
        s.template = "cbi/tblsection"
        s.extedit = dispatcher.build_url("admin", "network", "socat", "config", "%s")
        s.filter = function (e, t) {
            if (m.get(t, "protocol") == "port_forwards") {
                return true
            }
        }

        s.create=function (e, t){
        local   uuid = string.gsub(luci.sys.exec("echo -n $(cat /proc/sys/kernel/random/uuid)"), "-", "")
        t = uuid
        TypedSection.create(e, t)
        luci.http.redirect(e.extedit : format(t))
        }

        function s.remove(e, t)
        e.map.proceed = true
        e.map
    :
        del(t)
        luci.http.redirect(d.build_url("admin", "network", "socat"))
        end


        return m.render();
    }
});