'use strict'; 'require rpc';'require baseclass';
var callLuciCoreInfo = rpc.declare({ object: 'luci.cpu', method: 'getCPUInfo', expect: { '': {} } });
return L.Class.extend({
    title: _('CPU \u6838\u5fc3\u4fe1\u606f'),
    load: function () { return Promise.all([L.resolveDefault(callLuciCoreInfo(), {})]); },
    render: function (data) {
        var coreinfo = Array.isArray(data[0].coreinfo) ? data[0].coreinfo : [];
        var table = E(
            'div', { 'class': 'table' },
            [
                E(
                    'div', { 'class': 'tr table-titles' },
                    [
                        E('div', { 'class': 'th' }, _('\u6838\u5fc3')),
                        E('div', { 'class': 'th' }, _('\u9891\u7387')),
                        E('div', { 'class': 'th' }, _('\u6e29\u5ea6')),
                    ]
                )
            ]
        );
        cbi_update_table(table, coreinfo.map(function (info) {
            return [info.core, info.freq, info.temp];
        }));
        return E([table]);
    }
});
