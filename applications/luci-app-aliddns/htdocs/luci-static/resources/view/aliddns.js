'use strict';
'require form';
'require view';
'require uci';

return view.extend({
    load: function () {
        return Promise.all([
            uci.load('aliddns')
        ]);
    },

    render: function (data) {

        var m, s, o;

        m = new form.Map('aliddns', [_('阿里云ddns工具')]);

        s = m.section(form.TypedSection, 'alikey', _('基础设置'));
        s.addremove = false;

        o = s.option(form.Value, "AccessKeyId", _("阿里云接入key"),
            _("写接入key."));
        o.rmempty = false;

        o = s.option(form.Value, "AccessKeySecret", _("阿里云接入密码"),
            _("写接入密码."));
        o.rmempty = false;

        return m.render();
    }
});