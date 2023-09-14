'use strict';
'require form';
'require view';
'require uci';
'require fs';


return view.extend({
    load: function () {
        return Promise.all([
            uci.load('aliddns')
        ]);
    },
    handleSave: function(ev) {
        return fs.exec('/etc/init.d/aliddns', [ 'start' ]);
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

        return m.render();
    }
});