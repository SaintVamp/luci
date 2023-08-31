'use strict'; 'require rpc';
var callLuciETHInfo = rpc.declare({ object: 'luci.cpu', method: 'getETHInfo', expect: { '': {} } });
return L.Class.extend({
    title: _('\u63a5\u53e3\u4fe1\u606f'),
    load: function () { return Promise.all([L.resolveDefault(callLuciETHInfo(), {})]); },
    render: function (data) {
        var ethinfo = Array.isArray(data[0].ethinfo) ? data[0].ethinfo : [];
        var table = E(
            'div', { 'class': 'table' },
            [
                E(
                    'div', { 'class': 'tr table-titles' },
                    [
                        E('div', { 'class': 'th' }, _('\u63a5\u53e3')),
                        E('div', { 'class': 'th' }, _('\u8fde\u63a5\u72b6\u6001')),
                        E('div', { 'class': 'th' }, _('\u901f\u7387')),
                        E('div', { 'class': 'th' }, _('\u53cc\u5de5\u6a21\u5f0f'))
                    ]
                )
            ]
        );
        cbi_update_table(table, ethinfo.map(function (info) {
            var exp1; var exp2;
            if (info.status == "yes")
                exp1 = _('\u5df2\u8fde\u63a5');
            else if (info.status == "no")
                exp1 = _('\u5df2\u65ad\u5f00');
            if (info.duplex == "Full")
                exp2 = _('\u5168\u53cc\u5de5');
            else if (info.duplex == "Half")
                exp2 = _('\u534a\u53cc\u5de5');
            else
                exp2 = _('-'); return [info.name, exp1, info.speed, exp2];
        }));
        return E([table]);
    }
});
