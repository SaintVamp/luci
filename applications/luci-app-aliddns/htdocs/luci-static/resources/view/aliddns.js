'use strict';
'require form';
'require view';
'require uci';
'require fs';


return view.extend({
    load: function () {
        return Promise.all([
            uci.load('aliddns'),
            fs.exec('/etc/init.d/aliddns', ['start'])
        ]);
    },

    render: function (data) {

        var m, s, o;

        m = new form.Map('aliddns', [_('Aliyun DDNS Tool')]);
        s = m.section(form.TypedSection, 'alikey', _('Config'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Value, "AccessKeyId", _("AccessKeyId"),
            _("Type in aliyun accesskeyid."));
        o.rmempty = false;
        o.datatype = "wpakey";

        o = s.option(form.Value, "AccessKeySecret", _("AccessKeySecret"),
            _("Type in aliyun accesskeysecret."));
        o.rmempty = false;
        o.datatype = "wpakey";

        o = s.option(form.Value, "Subdomain", _("Subdomain"),
            _("Type in resolve subdomain."));
        o.rmempty = false;

        o = s.option(form.Value, "Domain", _("Domain"),
            _("Type in resolve domain."));
        o.rmempty = false;

        o = s.option(form.ListValue, "Iptype", _("Iptype"),
            _("Type in resolve IP type."));
        o.value("A", _("IPV4"));
        o.value("AAAA", _("IPV6"));
        o.default = "A";
        o.rmempty = false;

        o = s.option(form.Value, "TTL", _("TTL"),
            _("Type in resolve domain ttl."));
        o.rmempty = false;

        o = s.option(form.Value, "DnsServer", _("DnsServer"),
            _("Type in resolve domain dnsserver."));
        o.rmempty = false;

        return m.render();
    }
});