#!/bin/bash
# 注意：不使用set -e，因为DNS查询可能会失败但仍需要继续执行
# set -e

#================================================================================================================#
# 功能：用于更新阿里云域名IP，实现DDNS功能
#
# 在 http://www.gebi1.com/forum.php?mod=viewthread&tid=287344&page=1&_dsign=8f94f74c 提供的脚本文件基础上修改的。
# modified 12/2/2019
# 在 N1 debian Buster with Armbian Linux 5.3.0-aml-g12 手动执行/定时任务(crontab)执行测试通过
#================================================================================================================#
#
# 使用方法：
#
# 方法1. 外部参数
# 修改源码，将对应参数 修改为$1,$2,$3,$4,$5,$6
# ali_ddns.sh <AccessKeyId> <AccessKeySecret> <ali_ddns_subdomain> <ali_ddns_domain> <ali_ddns_ip_type> <ali_ddns_ttl>
# 示例（A 代表 IPv4，AAAA 代表 IPv6）:
# 执行：ali_ddns.sh "xxx" "xxx" "test" "my_domain.site" "A" 600
# 执行：ali_ddns.sh "xxx" "xxx" "test" "my_domain.site" "AAAA" 600
#
# 方法2. 内部参数
# 修改源码，将$1,$2,$3,$4,$5,$6 替换为对应参数
#
# 示例:
# AccessKeyId="xxx"
# AccessKeySecret="xxx"
# ali_ddns_subdomain="test"
# ali_ddns_domain="my_domain.site"
# ali_ddns_ip_type="A"
# ali_ddns_ttl=600
# 执行：ali_ddns.sh
#
#================================================================================================================#

#--------------------------------------------------------------
# 参数
#
# (*)阿里云 AccessKeyId
AccessKeyId=$1
# (*)阿里云 AccessKeySecret
AccessKeySecret=$2



# (*)域名：test.my_domain.com
ali_ddns_subdomain=$3 #'test'
ali_ddns_domain=$4 #'my_domain.com'

# (*)ip地址类型：'A' 或 'AAAA'，代表ipv4 和 ipv6
ali_ddns_ip_type=$5 # 'A' 或 'AAAA'，代表ipv4 和 ipv6

# TTL 默认10分钟 = 600秒
ali_ddns_ttl=$6 #"600"

dns_server=$7

#--------------------------------------------------------------
#--------------------------------------------------------------

#创建临时文件
if [ ! -e /usr/ddns/temp_ip ]; then
    touch /usr/ddns/temp_ip
fi
hostname=$(uci get system.@system[0].hostname)
if [ "$hostname" = "R404" ]; then
    url_name="10.0.4.51:8080/Serv"
elif [ "$hostname" = "R2804" ]; then
    url_name="10.0.28.22:8080/MailServ"
elif [ "$hostname" = "R207" ]; then
    url_name="10.0.2.22:8080/MailServ"
fi
machine_ip=""
ddns_ip=""
ali_ddns_record_id=""

if [ "$ali_ddns_subdomain" = "@" ]
then
  ali_ddns_name=$ali_ddns_domain
else
  ali_ddns_name=$ali_ddns_subdomain.$ali_ddns_domain
fi
now=$(date)
echo "**************************************************"
echo "$now"
echo "$ali_ddns_name"
echo "$ali_ddns_ip_type"
echo "--------------------"
function get_temp_ip() {
    a=$(cat /usr/ddns/$ali_ddns_name)
    echo "$a"
}
function set_temp_ip() {
    $(rm -rf /usr/ddns/$ali_ddns_name)
    $(echo "$machine_ip" > /usr/ddns/$ali_ddns_name)
#    curl -s "http://$url_name/ddns?domain=$ali_ddns_name&ip=$(enc "$machine_ip")"
}
function getMachine_IPv4() {
    a=$(/usr/bin/wget -qO- -t1 -T2 http://4.ipw.cn)
    echo "$a"
}
function getMachine_IPv42() {
    a=$(/usr/bin/wget -qO- -t1 -T2 https://ipv4.netarm.com/)
    echo "$a"
}
function getMachine_IPv6() {
    a=$(/usr/bin/wget -qO- -t1 -T2 http://6.ipw.cn)
    echo "$a"
}
function getMachine_IPv62() {
    a=$(/usr/bin/wget -qO- -t1 -T2 https://ipv6.netarm.com/)
    echo "$a"
}
function getJsonValuesByAwk() {
    awk -v json="$1" -v key="$2" -v defaultValue="$3" 'BEGIN{
        foundKeyCount = 0
        while (length(json) > 0) {
            # pos = index(json, "\""key"\""); ##这行更快一些，但是如果有value是字符串，且刚好与要查找的key相同，会被误认为是key而导致值获取错误
            pos = match(json, "\""key"\"[ \\t]*?:[ \\t]*");
            if (pos == 0) {if (foundKeyCount == 0) {print defaultValue;} exit 0;}

            ++foundKeyCount;
            start = 0; stop = 0; layer = 0;
            for (i = pos + length(key) + 1; i <= length(json); ++i) {
                lastChar = substr(json, i - 1, 1)
                currChar = substr(json, i, 1)

                if (start <= 0) {
                    if (lastChar == ":") {
                        start = currChar == " " ? i + 1: i;
                        if (currChar == "{" || currChar == "[") {
                            layer = 1;
                        }
                    }
                } else {
                    if (currChar == "{" || currChar == "[") {
                        ++layer;
                    }
                    if (currChar == "}" || currChar == "]") {
                        --layer;
                    }
                    if ((currChar == "," || currChar == "}" || currChar == "]") && layer <= 0) {
                        stop = currChar == "," ? i : i + 1 + layer;
                        break;
                    }
                }
            }

            if (start <= 0 || stop <= 0 || start > length(json) || stop > length(json) || start >= stop) {
                if (foundKeyCount == 0) {print defaultValue;} exit 0;
            } else {
                print substr(json, start, stop - start);
            }

            json = substr(json, stop + 1, length(json) - stop)
        }
    }'
}
function url_encode() {
    # url_encode <string>
    out=""
    while read -n1 c
    do
        case $c in
            [a-zA-Z0-9._-]) out="$out$c" ;;
            *) out="$out`printf '%%%02X' "'$c"`" ;;
        esac
    done
    echo -n "$out"
}
function enc() {
    echo -n "$1" | url_encode
}
function send_request() {
    args="AccessKeyId=$AccessKeyId&Action=$1&Format=json&$2&Version=2015-01-09"
    hash=$(echo -n "GET&%2F&$(enc "$args")" | openssl dgst -sha1 -hmac "$AccessKeySecret&" -binary | openssl base64)
    curl -s "http://alidns.aliyuncs.com/?$args&Signature=$(enc "$hash")"
}
function get_record_id() {
    grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}
function query_record_id() {
    timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")
    send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$ali_ddns_name&Timestamp=$timestamp&Type=$ali_ddns_ip_type"
}
function update_record() {
    timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")
    send_request "UpdateDomainRecord" "RR=$ali_ddns_subdomain&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$ali_ddns_ttl&Timestamp=$timestamp&Type=$ali_ddns_ip_type&Value=$(enc "$machine_ip")"
}
function delete_record() {
    timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")
    send_request "DeleteDomainRecord" "RR=$ali_ddns_subdomain&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$ali_ddns_ttl&Timestamp=$timestamp&Type=$ali_ddns_ip_type&Value=$(enc "$machine_ip")"
}
function add_record() {
    echo "add"
    timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")
    # shellcheck disable=SC2086
    send_request "AddDomainRecord&DomainName=$ali_ddns_domain" "RR=$ali_ddns_subdomain&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$ali_ddns_ttl&Timestamp=$timestamp&Type=$ali_ddns_ip_type&Value=$(enc $machine_ip)"
}
# 先查询当前的DNS记录信息
echo "查询阿里云DNS记录..."
ali_ddns_record_info=$(query_record_id)
record_id_num=$(getJsonValuesByAwk "$ali_ddns_record_info" "TotalCount" "defaultValue")
record_ids=$(getJsonValuesByAwk "$ali_ddns_record_info" "RecordId" "defaultValue" | tr -d '\n')
record_ids=${record_ids//\"\"/\" \"}
record_ids=${record_ids//\"/}
# 直接执行nslookup
nslookup_result=$(nslookup -query="$ali_ddns_ip_type" "$ali_ddns_name" "$dns_server" 2>&1)
ddns_ip_raw=$(echo "$nslookup_result" | grep "Address" | grep -v "#53" | grep -v ":53" | awk '{print $2}')
echo "ddns_ip_raw = $ddns_ip_raw"
# 确保即使DNS查询失败也能继续执行
echo "处理DNS查询结果..."
if [ -z "$ddns_ip_raw" ]; then
    echo "DNS查询未返回有效结果，设置默认值"
    ddns_ip_raw="0.0.0.0"
    echo "ddns_ip_raw设置为: $ddns_ip_raw"
fi
# 检查是否返回了多个IP地址
ddns_ip_count=$(echo "$ddns_ip_raw" | grep -v "^$" | wc -l)
if [ $ddns_ip_count -gt 1 ]; then
    echo "检测到多个DDNS IP地址 ($ddns_ip_count 个)，先删除所有记录再新增"
    # 删除所有现有记录
    record_array=($record_ids)
    for record_id in "${record_array[@]}"
    do
        if [ -n "$record_id" ]
        then
            echo "删除记录 ID: $record_id"
            delete_record "$record_id"
            sleep 2
        fi
    done
    # 清空record_id，强制走新增流程
    ali_ddns_record_id=""
    ali_ddns_ipv4_record_id=""
    ali_ddns_ipv6_record_id=""
    # 重新查询record信息（此时应该为空）
    ali_ddns_record_info=$(query_record_id)
    record_id_num=0
    ddns_ip="0.0.0.0"
    echo "ddns_ip1 = $ddns_ip"
else
    # 单个IP情况，正常处理record_id
    if [ $((record_id_num)) -gt 1 ]; then
        # 如果记录数大于1，也删除所有记录
        echo "检测到多个DDNS记录 ($record_id_num 个)，删除所有记录"
        record_array=($record_ids)
        for record_id in "${record_array[@]}"
        do
            if [ -n "$record_id" ]
            then
                echo "删除记录 ID: $record_id"
                delete_record "$record_id"
                sleep 2
            fi
        done
        # 清空record_id
        ali_ddns_record_id=""
        ali_ddns_ipv4_record_id=""
        ali_ddns_ipv6_record_id=""
        ali_ddns_record_info=$(query_record_id)
        record_id_num=0
        ddns_ip="0.0.0.0"
        echo "ddns_ip2 = $ddns_ip"
    else
        # 正常情况，获取单个record_id
        echo "处理正常情况，record_id_num = $record_id_num"
        ali_ddns_record_id=$(echo "$ali_ddns_record_info" | get_record_id)
        if [ "$ali_ddns_ip_type" = 'A' ]; then
            ali_ddns_ipv4_record_id=$ali_ddns_record_id
        else
            ali_ddns_ipv6_record_id=$ali_ddns_record_id
        fi
        ddns_ip=$(echo "$ddns_ip_raw" | head -n 1)
        echo "ddns_ip3 = $ddns_ip"
    fi
fi
if [ "$ali_ddns_ip_type" = 'A' ]
then
    echo "ddns is IPv4."
    machine_ip=$(getMachine_IPv4)
    if [ "$machine_ip" = "" ]
    then
        machine_ip=$(getMachine_IPv42)
    fi
    echo "machine_ip = $machine_ip"
    ali_ddns_record_id=$ali_ddns_ipv4_record_id
    exist_local=$(ip addr show pppoe-wan | grep "scope global pppoe-wan" | grep "$machine_ip"| wc -l)
    exist_ddns=$(echo "$ddns_ip" | grep "$machine_ip"| wc -l)
    exist_ddns_local=$(ip addr show pppoe-wan | grep "scope global pppoe-wan" | grep "$ddns_ip"| wc -l)
else
    echo "ddns is IPv6."
    machine_ip=$(getMachine_IPv6)
    if [ "$machine_ip" = "" ]
    then
        machine_ip=$(getMachine_IPv62)
    fi
    echo "machine_ip = $machine_ip"
    ali_ddns_record_id=$ali_ddns_ipv6_record_id
    echo "ali_ddns_record_id = $ali_ddns_record_id"
    exist_local=$(ip addr show br-lan | grep "scope global dynamic noprefixroute" | grep "$machine_ip"| wc -l)
    exist_ddns=$(echo "$ddns_ip" | grep "$machine_ip"| wc -l)
    exist_ddns_local=$(ip addr show br-lan | grep "scope global dynamic noprefixroute" | grep "$ddns_ip"| wc -l)
fi
echo "exist_ddns_local = $exist_ddns_local"
echo "exist_local = $exist_local"
echo "exist_ddns = $exist_ddns"
echo "开始检查退出条件..."
if [ -z "$machine_ip" ]
then
    echo "machine_ip is empty! "
    exit 0
fi
if [ $((exist_ddns)) -gt 0 ]
then
    echo "skipping ddns (exist_ddns > 0)"
    exit 1
else
    if [ $((exist_ddns_local)) -gt 0 ] && [ -n "$ddns_ip" ]
    then
        echo "skipping ddns_local"
        exit 1
    fi
fi
if [ $((exist_local)) -eq 0 ]
then
    echo "machine_ip is error (本地IP不存在)"
    exit 1
fi
txt_ip=$(get_temp_ip)
echo "txt_ip = $txt_ip"
if [ "$machine_ip" = "$txt_ip" ] && [ "$machine_ip" = "$ddns_ip" ]
then
    echo "machine_ip same with txt_ip"
    exit 1
else
    set_temp_ip
fi
echo "start update ddns..."

#add support */%2A and @/%40 record

if [ -z "$ali_ddns_record_id" ]
then
    echo "add record starting"
    ali_ddns_record_id=$(add_record | get_record_id)
    if [ -z "$ali_ddns_record_id" ]
    then
        echo "ali_ddns_record_id is empty."
    else
        if [ "$ali_ddns_ip_type" = 'A' ]
        then
            ali_ddns_ipv4_record_id=$ali_ddns_record_id
        else
            ali_ddns_ipv6_record_id=$ali_ddns_record_id
        fi
        echo "added record id is:" "$ali_ddns_record_id"
    fi
else
    echo "update record starting"
    update_record "$ali_ddns_record_id"
    echo "updated record id is:" "$ali_ddns_record_id"
fi