#!/bin/bash
set -e

#================================================================================================================#
# 功能：用于更新阿里云域名IP，实现DDNS功能
#
# 在 http://www.gebi1.com/forum.php?mod=viewthread&tid=287344&page=1&_dsign=8f94f74c 提供的脚本文件基础上修改的。
# ghui, modified 12/2/2019
# 在 N1 debian Buster with Armbian Linux 5.3.0-aml-g12 手动执行/定时任务(crontab)执行测试通过
#================================================================================================================#
#
# 使用方法：
#
# 方法1. 外部参数
# 修改源码，将对应参数 修改为$1,$2,$3,$4,$5,$6
# aliddns.sh <AccessKeyId> <AccessKeySecret> <aliddns_subdomain> <aliddns_domain> <aliddns_iptype> <aliddns_ttl>
# 示例（A 代表 IPv4，AAAA 代表 IPv6）:
# 执行：aliddns.sh "xxxx" "xxx" "test" "mydomain.site" "A" 600
# 执行：aliddns.sh "xxxx" "xxx" "test" "mydomain.site" "AAAA" 600
#
# 方法2. 内部参数
# 修改源码，将$1,$2,$3,$4,$5,$6 替换为对应参数
#
# 示例:
# AccessKeyId="xxxx"
# AccessKeySecret="xxx"
# aliddns_subdomain="test"
# aliddns_domain="mydomain.site"
# aliddns_iptype="A"
# aliddns_ttl=600
# 执行：aliddns.sh
#
#================================================================================================================#

#--------------------------------------------------------------
# 参数
#
# (*)阿里云 AccessKeyId
AccessKeyId=$1
# (*)阿里云 AccessKeySecret
AccessKeySecret=$2



# (*)域名：test.mydomain.com
aliddns_subdomain=$3 #'test'
aliddns_domain=$4 #'mydomain.com'

# (*)ip地址类型：'A' 或 'AAAA'，代表ipv4 和 ipv6
aliddns_iptype=$5 # 'A' 或 'AAAA'，代表ipv4 和 ipv6

# TTL 默认10分钟 = 600秒
aliddns_ttl=$6 #"600"

dns_server=$7

#--------------------------------------------------------------
#--------------------------------------------------------------


machine_ip=""
ddns_ip=""
aliddns_record_id=""

if [ "$aliddns_subdomain" = "@" ]
then
  aliddns_name=$aliddns_domain
else
  aliddns_name=$aliddns_subdomain.$aliddns_domain
fi
now=`date`
echo "**************************************************"
echo "$now"
echo "$aliddns_name"
echo "$aliddns_iptype"
echo "--------------------"
function getMachine_IPv4() {
    echo $(/usr/bin/wget -qO- -t1 -T2 http://4.ipw.cn)
}
function getMachine_IPv42() {
    echo $(/usr/bin/wget -qO- -t1 -T2 https://ipv4.netarm.com/)
}
function getMachine_IPv6() {
    echo $(/usr/bin/wget -qO- -t1 -T2 http://6.ipw.cn)
}
function getMachine_IPv62() {
    echo $(/usr/bin/wget -qO- -t1 -T2 https://ipv6.netarm.com/)
}
function getDDNS_IP() {
    current_ip=`nslookup -query=$aliddns_iptype $aliddns_name $dns_server| grep "Address" | grep -v "#53" | grep -v ":53" | awk '{print $2}'`
    echo $current_ip
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
function urlencode() {
    # urlencode <string>
    out=""
    while read -n1 c
    do
        case $c in
            [a-zA-Z0-9._-]) out="$out$c" ;;
            *) out="$out`printf '%%%02X' "'$c"`" ;;
        esac
    done
    echo -n $out
}
function enc() {
    echo -n "$1" | urlencode
}
function send_request() {
    local args="AccessKeyId=$AccessKeyId&Action=$1&Format=json&$2&Version=2015-01-09"
    local hash=$(echo -n "GET&%2F&$(enc "$args")" | openssl dgst -sha1 -hmac "$AccessKeySecret&" -binary | openssl base64)
    curl -s "http://alidns.aliyuncs.com/?$args&Signature=$(enc "$hash")"
}
function get_recordid() {
    grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}
function query_recordid() {
    timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
    send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$aliddns_name&Timestamp=$timestamp&Type=$aliddns_iptype"
}
function update_record() {
    timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
    send_request "UpdateDomainRecord" "RR=$aliddns_subdomain&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$aliddns_ttl&Timestamp=$timestamp&Type=$aliddns_iptype&Value=$(enc $machine_ip)"
}
function delete_record() {
    timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
    send_request "DeleteDomainRecord" "RR=$aliddns_subdomain&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$aliddns_ttl&Timestamp=$timestamp&Type=$aliddns_iptype&Value=$(enc $machine_ip)"
}
function add_record() {
    echo "add"
    timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
    send_request "AddDomainRecord&DomainName=$aliddns_domain" "RR=$aliddns_subdomain&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$aliddns_ttl&Timestamp=$timestamp&Type=$aliddns_iptype&Value=$(enc $machine_ip)"
}
if [ "$aliddns_record_id" = "" ]
then
    aliddns_record_id=`query_recordid`
#    echo "---------aliddns_record_id-------" $aliddns_record_id "\n"
    recordid_num=`getJsonValuesByAwk "$aliddns_record_id" "TotalCount" "defaultValue"`
    recordids=`getJsonValuesByAwk "$aliddns_record_id" "RecordId" "defaultValue" | tr -d '\n'`
    recordids=${recordids//\"\"/\" \"}
    recordids=${recordids//\"/}
    sleep 2
    if [ $recordid_num -gt 1 ]
    then
        str1=`echo $recordids | awk '{print $1}'`
        str2=`echo $recordids | awk '{print $2}'`
        str3=`echo $recordids | awk '{print $3}'`
        str4=`echo $recordids | awk '{print $1}'`
        str5=`echo $recordids | awk '{print $2}'`
        str6=`echo $recordids | awk '{print $3}'`
        str7=`echo $recordids | awk '{print $3}'`
        str8=`echo $recordids | awk '{print $1}'`
        str9=`echo $recordids | awk '{print $2}'`
        str10=`echo $recordids | awk '{print $3}'`
        if [ -n "$str1" ]
        then
            delete_record $str1
            sleep 5
        fi
        if [ -n "$str2" ]
        then
            delete_record $str2
            sleep 5
        fi
        if [ -n "$str3" ]
        then
            delete_record $str3
            sleep 5
        fi
        if [ -n "$str4" ]
        then
            delete_record $str4
            sleep 5
        fi
        if [ -n "$str5" ]
        then
            delete_record $str5
            sleep 5
        fi
        if [ -n "$str6" ]
        then
            delete_record $str6
            sleep 5
        fi
        if [ -n "$str7" ]
        then
            delete_record $str7
            sleep 5
        fi
        if [ -n "$str8" ]
        then
            delete_record $str8
            sleep 5
        fi
        if [ -n "$str9" ]
        then
            delete_record $str9
            sleep 5
        fi
        if [ -n "$str10" ]
        then
            delete_record $str10
            sleep 5
        fi
    else
        aliddns_record_id=`query_recordid | get_recordid`
        echo "----------------" $aliddns_record_id "\n"
        if [ "$aliddns_iptype" = 'A' ]
        then
            aliddnsipv4_record_id=$aliddns_record_id
        else
            aliddnsipv6_record_id=$aliddns_record_id
        fi
    fi
fi

ddns_ip=`echo "$(getDDNS_IP)"`
echo "ddns_ip = $ddns_ip"
if [ "$aliddns_iptype" = 'A' ]
then
    echo "ddns is IPv4."
    machine_ip=`echo "$(getMachine_IPv4)"`
    if [ "$machine_ip" = "" ]
    then
        machine_ip=`echo "$(getMachine_IPv42)"`
    fi
    echo "machine_ip = $machine_ip"
    aliddns_record_id=$aliddnsipv4_record_id
    exist_local=`ifconfig | grep "inet addr"| grep "inet addr:$machine_ip  P"| wc -l`
    exist_ddns=`echo $ddns_ip | grep $machine_ip | wc -l`
    exist_ddns_local=`ifconfig | grep "inet addr"| grep "inet addr:$ddns_ip  P"| wc -l`
else
    echo "ddns is IPv6."
    machine_ip=`echo "$(getMachine_IPv6)"`
    if [ "$machine_ip" = "" ]
    then
        machine_ip=`echo "$(getMachine_IPv62)"`
    fi
    echo "machine_ip = $machine_ip"
    aliddns_record_id=$aliddnsipv6_record_id
    exist_local=`ifconfig | grep "inet6 addr"| grep "inet6 addr: $machine_ip/"| wc -l`
    exist_ddns=`echo $ddns_ip | grep $machine_ip | wc -l`
    exist_ddns_local=`ifconfig | grep "inet6 addr"| grep "inet6 addr: $ddns_ip/"| wc -l`
fi

if [ "$machine_ip" = "" ]
then
    echo "machine_ip is empty!"
    exit 0
fi
if [ $exist_local -eq 0 ]
then
    echo "machine_ip is error"
fi
if [ $exist_ddns -gt 0 ]
then
    echo "skipping ddns \n"
    exit 1
else
    if [ $exist_ddns_local -gt 0 ]
    then
        echo "skipping ddns_local \n"
        exit 1
    fi
fi
echo "start update ddns..."

#add support */%2A and @/%40 record
if [ "$aliddns_record_id" = "" ]
then
    echo "add record starting"
    aliddns_record_id=`add_record | get_recordid`
    curl -s "http://4.0.4.51:8080/Serv/ddns?domain=$aliddns_name&ip=$(enc $machine_ip)"
    if [ "$aliddns_record_id" = "" ]
    then
        echo "aliddns_record_id is empty. \n"
    else
        if [ "$aliddns_iptype" = 'A' ]
        then
            aliddnsipv4_record_id=$aliddns_record_id
        else
            aliddnsipv6_record_id=$aliddns_record_id
        fi
        echo "added record $aliddns_record_id \n"
    fi
else
    echo "update record starting"
    update_record $aliddns_record_id
    curl -s "http://4.0.4.51:8080/Serv/ddns?domain=$aliddns_name&ip=$(enc $machine_ip)"
    echo "updated record $aliddns_record_id \n"
fi