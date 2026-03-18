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

        // 全局配置部分
        s = m.section(form.TypedSection, 'global', _('Global Settings'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Value, "AccessKeyId", _("AccessKeyId"),
            _("Aliyun Access Key ID for all domains."));
        o.rmempty = false;
        o.datatype = "wpakey";

        o = s.option(form.Value, "AccessKeySecret", _("AccessKeySecret"),
            _("Aliyun Access Key Secret for all domains."));
        o.rmempty = false;
        o.datatype = "wpakey";

        o = s.option(form.Value, "TTL", _("TTL"),
            _("Time to Live in seconds (default: 600)."));
        o.default = "600";
        o.rmempty = false;
        o.datatype = "uinteger";

        o = s.option(form.Value, "DnsServer", _("DNS Server"),
            _("DNS server for querying (e.g., 223.5.5.5)."));
        o.default = "dns23.hichina.com";
        o.rmempty = false;

        o = s.option(form.Value, "UrlName", _("URL Name"),
            _("Callback URL for notifications."));
        o.default = ":45678/sv/mail";
        o.rmempty = false;

        // 域名配置部分
        s = m.section(form.TypedSection, 'domain', _('Domain Configurations'));
        s.anonymous = false;
        s.addremove = true;
        s.template = 'cbi/tblsection';
        s.rmempty = false;

        o = s.option(form.Value, "Subdomain", _("Subdomain"),
            _("Subdomain to update (e.g., www, @, test)."));
        o.value("404", _("404"));
        o.value("207", _("207"));
        o.value("2804", _("2804"));
        o.value("404_6", _("404_6"));
        o.value("207_6", _("207_6"));
        o.value("2804_6", _("2804_6"));
        o.default = "404";
        o.rmempty = false;
        o.modalonly = true;

        o = s.option(form.Value, "Domain", _("Domain"),
            _("Main domain (e.g., example.com)."));
        o.value("svsoft.fun", _("svsoft"));
        o.value("efdata.fun", _("efdata"));
        o.default = "svsoft.fun";
        o.rmempty = false;
        o.modalonly = true;

        o = s.option(form.ListValue, "Iptype", _("IP Type"),
            _("IP address type."));
        o.value("A", _("IPv4"));
        o.value("AAAA", _("IPv6"));
        o.default = "A";
        o.rmempty = false;
        o.modalonly = true;

        return m.render();
    }
});
