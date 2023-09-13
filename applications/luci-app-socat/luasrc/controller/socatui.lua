-- Copyright 2020 Lienol <lawlienol@gmail.com>
module("luci.controller.socatui", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/socatui") then
		return
	end

	entry({"admin", "network", "socatui"}, alias("admin", "network", "socatui", "index"), _("Socat"), 100).dependent = true
	entry({"admin", "network", "socatui", "index"}, cbi("socatui/index")).leaf = true
	entry({"admin", "network", "socatui", "config"}, cbi("socatui/config")).leaf = true
	entry({"admin", "network", "socatui", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.index = luci.http.formvalue("index")
	e.status = luci.sys.call(string.format("busybox ps -w | grep -v 'grep' | grep '/var/etc/socatui/%s' >/dev/null", luci.http.formvalue("id"))) == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
