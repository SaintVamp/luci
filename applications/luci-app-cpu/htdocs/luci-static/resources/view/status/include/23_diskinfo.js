'use strict'; 'require rpc';
var callLuciDiskInfo = rpc.declare({ object: 'luci', method: 'getDiskInfo', expect: { '': {} } });
return L.Class.extend({
    title: _('\u78c1\u76d8\u4f7f\u7528\u4fe1\u606f'),
    load: function () { return Promise.all([L.resolveDefault(callLuciDiskInfo(), {})]); },
    render: function (data) {
        var diskinfo = Array.isArray(data[0].diskinfo) ? data[0].diskinfo : [];
        var table = E(
            'div', { 'class': 'table' },
            [
                E(
                    'div', { 'class': 'tr table-titles' },
                    [
                        E('div', { 'class': 'th' }, _('\u5757\u8bbe\u5907\u0020')),
                        E('div', { 'class': 'th' }, _('\u6302\u8f7d\u70b9')),
                        E('div', { 'class': 'th' }, _('\u5bb9\u91cf')),
                        E('div', { 'class': 'th' }, _('\u5df2\u4f7f\u7528')),
                        E('div', { 'class': 'th' }, _('\u5269\u4f59')),
                        E('div', { 'class': 'th' }, _('\u4f7f\u7528\u7387')),
                    ]
                )
            ]
        );
        cbi_update_table(table, diskinfo.map(function (info) {
            return [info.block, info.mounte_point, info.size, info.used, info.available, info.used_percent];
        }));
        return E([table]);
    }
});
