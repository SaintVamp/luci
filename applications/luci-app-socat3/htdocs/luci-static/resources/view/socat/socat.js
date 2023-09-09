'use strict';
'require view';
'require dom';
'require poll';
'require uci';
'require rpc';
'require form';


return view.extend({
    render: function (data) {

        var m, s, o;

        m = new form.Map('socat', ['Socat'],
            _('Socat is a versatile networking tool named after \'Socket CAT\', which can be regarded as an N-fold enhanced version of NetCat'));

        s = m.section(NamedSection, 'global', 'global',_('Socat Config'));
        s.anonymous = true;
        s.addremove = false;
        o = s.option(Flag, "enable", translate("Enable"));
        o.rmempty = false;






        s = m.section(form.NamedSection, 'config', 'upnpd', _('MiniUPnP settings'));
        s.addremove = false;
        s.tab('general', _('General Settings'));
        s.tab('advanced', _('Advanced Settings'));

        o = s.taboption('general', form.Flag, 'enabled', _('Start UPnP and NAT-PMP service'));
        o.rmempty = false;

        s.taboption('general', form.Flag, 'enable_upnp', _('Enable UPnP functionality')).default = '1'
        s.taboption('general', form.Flag, 'enable_natpmp', _('Enable NAT-PMP functionality')).default = '1'

        s.taboption('general', form.Flag, 'secure_mode', _('Enable secure mode'),
            _('Allow adding forwards only to requesting ip addresses')).default = '1'

        s.taboption('general', form.Flag, 'igdv1', _('Enable IGDv1 mode'),
            _('Advertise as IGDv1 device instead of IGDv2')).default = '0'

        s.taboption('general', form.Flag, 'log_output', _('Enable additional logging'),
            _('Puts extra debugging information into the system log'))

        s.taboption('general', form.Value, 'download', _('Downlink'),
            _('Value in KByte/s, informational only')).rmempty = true

        s.taboption('general', form.Value, 'upload', _('Uplink'),
            _('Value in KByte/s, informational only')).rmempty = true

        o = s.taboption('general', form.Value, 'port', _('Port'))
        o.datatype = 'port'
        o.default = 5000

        s.taboption('advanced', form.Flag, 'system_uptime', _('Report system instead of daemon uptime')).default = '1'

        s.taboption('advanced', form.Value, 'uuid', _('Device UUID'))
        s.taboption('advanced', form.Value, 'serial_number', _('Announced serial number'))
        s.taboption('advanced', form.Value, 'model_number', _('Announced model number'))

        o = s.taboption('advanced', form.Value, 'notify_interval', _('Notify interval'))
        o.datatype = 'uinteger'
        o.placeholder = 30

        o = s.taboption('advanced', form.Value, 'clean_ruleset_threshold', _('Clean rules threshold'))
        o.datatype = 'uinteger'
        o.placeholder = 20

        o = s.taboption('advanced', form.Value, 'clean_ruleset_interval', _('Clean rules interval'))
        o.datatype = 'uinteger'
        o.placeholder = 600

        o = s.taboption('advanced', form.Value, 'presentation_url', _('Presentation URL'))
        o.placeholder = 'http://192.168.1.1/'

        o = s.taboption('advanced', form.Value, 'upnp_lease_file', _('UPnP lease file'))
        o.placeholder = '/var/run/miniupnpd.leases'

        s.taboption('advanced', form.Flag, 'use_stun', _('Use STUN'))

        o = s.taboption('advanced', form.Value, 'stun_host', _('STUN Host'))
        o.depends('use_stun', '1');
        o.datatype = 'host'

        o = s.taboption('advanced', form.Value, 'stun_port', _('STUN Port'))
        o.depends('use_stun', '1');
        o.datatype = 'port'
        o.placeholder = '0-65535'

        s = m.section(form.GridSection, 'perm_rule', _('MiniUPnP ACLs'),
            _('ACLs specify which external ports may be redirected to which internal addresses and ports'))

        s.sortable = true
        s.anonymous = true
        s.addremove = true

        s.option(form.Value, 'comment', _('Comment'))

        o = s.option(form.Value, 'ext_ports', _('External ports'))
        o.datatype = 'portrange'
        o.placeholder = '0-65535'

        o = s.option(form.Value, 'int_addr', _('Internal addresses'))
        o.datatype = 'ip4addr'
        o.placeholder = '0.0.0.0/0'

        o = s.option(form.Value, 'int_ports', _('Internal ports'))
        o.datatype = 'portrange'
        o.placeholder = '0-65535'

        o = s.option(form.ListValue, 'action', _('Action'))
        o.value('allow')
        o.value('deny')

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