import time

import pymysql
import pymongo


def getSyncTS(cursor):
    sql = "SELECT switchStatus FROM Switch WHERE switchId = 'SyncTimestamp'"
    cursor.execute(sql)
    a = cursor.fetchall()
    return a[0][0]


def setSyncTS(cursor):
    sql = "UPDATE Switch SET switchStatus = '" + str(int(time.time())) + "' WHERE switchId = 'SyncTimestamp'"
    cursor.execute(sql)


def syncDb():
    db = pymysql.connect(host="404.svsoft.fun", port=45004, user="sv", password="sv@8004", db="SV", charset='utf8')
    cursor = db.cursor()
    # myclient = pymongo.MongoClient("mongodb://svtool:12086F465CEB74B3BD676C39DA07900C@39.100.245.149:30000/SV?mechanism=SCRAM-SHA-1")
    # myclient = pymongo.MongoClient(host="39.100.245.149", port=30000,username="svtool",password="12086F465CEB74B3BD676C39DA07900C")
    myclient = pymongo.MongoClient("mongodb://39.100.245.149:30000")
    mydb = myclient["SV"]
    mydb.authenticate('svtool', '12086F465CEB74B3BD676C39DA07900C')
    mycol = mydb["svData"]
    ts = getSyncTS(cursor)
    myquery = {"updateDt": {"$gt": str(ts)}}
    setSyncTS(cursor)
    db.commit()
    modData = mycol.find(myquery).sort("updateDt", -1)
    for svData in modData:
        print(svData["qqNum"] + ":" + svData["updateDt"])
        flag = authCodeExist(svData, cursor)
        if flag == 2:
            addSV(svData, cursor)
            db.commit()
        elif flag == 1:
            modSV(svData, cursor)
            db.commit()
        else:
            pass
    db.close()
    print("done done")


def authCodeExist(svData, cursor):
    sql = "SELECT updateDt FROM SvData WHERE authCode = '" + svData["authCode"] + "'"
    cursor.execute(sql)
    a = cursor.fetchall()
    if len(a) > 0:
        if svData["updateDt"] == a[0][0]:
            # 数据未更新不用同步
            return 0
        else:
            # 数据更新过要同步
            return 1
    else:
        # 无数据要同步
        return 2


def addSV(svData, cursor):
    sql = "INSERT INTO SvData (qqNum, authCode, device, startDt, endDt, localIp, price, updateDt, version, game) VALUES ('" + \
          svData["qqNum"] + "','" + svData["authCode"] + "','" + svData["device"] + "','" + svData["startDt"] + "','" + \
          svData["endDt"] + "','" + svData["localIp"] + "','" + str(svData["price"]) + "','" + svData[
              "updateDt"] + "','" + \
          svData["version"] + "','" + svData["game"] + "')"
    cursor.execute(sql)
    print("新增数据：" + svData["authCode"])


def modSV(svData, cursor):
    sql = "UPDATE SvData SET qqNum = '" + svData["qqNum"] + "',device = '" + svData["device"] + "',startDt = '" + \
          svData["startDt"] + "',endDt = '" + svData["endDt"] + "',localIp = '" + svData["localIp"] + "',price = " + \
          str(svData["price"]) + ",updateDt = '" + svData["updateDt"] + "',version = '" + svData[
              "version"] + "',game = '" + \
          svData["game"] + "' WHERE authCode = '" + svData["authCode"] + "'"
    cursor.execute(sql)
    print("更新数据：" + svData["authCode"])


syncDb()

