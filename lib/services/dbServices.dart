import 'dart:developer';
import 'package:income_track/chart/IncomeExpenseMonthly.dart';
import 'package:income_track/chart/TxnCategory.dart';
import 'package:sqflite/sqflite.dart';

class DBService {

  late Database database;

  Future<String> initDB()async{
    try {
      var databasesPath = await getDatabasesPath();
      String path = '$databasesPath/data.db';

      // await deleteDatabase(path);
      database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            // When creating the db, create the table
            await db.execute(
                'CREATE TABLE income (id INTEGER PRIMARY KEY AUTOINCREMENT, date date, time time, amount REAL)');
            await db.execute(
                'CREATE TABLE spend (id INTEGER PRIMARY KEY AUTOINCREMENT, date date, time time, item TEXT, category TEXT, txnMode TEXT, amount REAL)');
          });
      log('initDB() success');
      return "done";
    }
    catch(error){
      log('initDB() error: $error');
      return "error";
    }
  }

  Future<String> addSpend({dynamic entryId, required String date, required String item, required String category, required String txnMode, required String amount}) async {
    try {
      await database.transaction((txn) async {
        int id = await txn.rawInsert(
            "INSERT INTO spend (id, date, time, item, category, txnMode, amount) VALUES($entryId, '$date', time('now'), '$item', '$category', '$txnMode', $amount)");
        log('addSpend() inserted: $id');
      });
      return "done";
    }
    catch(error){
      log("addSpend() error: $error");
      return "error";
    }
  }

  Future<String> addIncome({dynamic entryId, required String date,required String amount})async{
    try {
      await database.transaction((txn) async {
        int id = await txn.rawInsert(
            "INSERT INTO income(id, date, time, amount) VALUES($entryId, '$date', time('now'), $amount)");
        log('addIncome() inserted: $id');
      });
      return "done";
    }
    catch(error){
      log("addIncome() error: $error");
      return "error";
    }
  }

  Future<dynamic> getRecentSpends() async {
    try {
      List<Map> list = await database.rawQuery(
          "Select * from spend order by id desc limit 10");
      log('getRecentSpends() queries: $list');
        return list;
    }
    catch(error){
      log("getRecentSpends() error: $error");
      return "error";
    }
  }

  Future<String> getThisMonthSpend() async {
    try {
      List<Map> temp = await database.rawQuery(
          "select coalesce(sum(amount),0.0) as amount from spend where strftime(\"%m/%Y\", date(\"now\")) = strftime(\"%m/%Y\", date)");
      String amount = temp[0]["amount"].toString();
      log('getThisMonthSpend() queries: $amount');
      return amount;
    }
    catch(error){
      log("getThisMonthSpend() error: $error");
      return "error";
    }
  }

  Future<dynamic> getMonthlyStats() async {
    try {
      List<Map> data = await database.rawQuery(
        """
        WITH month_table(month, month_name) AS (
          VALUES ("1", "Jan"), ("2", "Feb"), ("3", "Mar"), ("4", "Apr"), ("5", "May"), ("6","Jun"), ("7","Jul"), ("8","Aug"), ("9","Sep"), ("10","Oct"), ("11","Nov"), ("12","Dec")
        )
        SELECT month_name as label, coalesce(expense,0.0) as expense, coalesce(income,0.0) as income FROM month_table as t1 left  join
         (select sum(amount) as expense, strftime("%m",date) as month from spend group by strftime("%m",date))  as t2 on t1.month = t2.month  left join 
         (select sum(amount) as income, strftime("%m",date) as month from income group by strftime("%m",date)) as t3 on t3.month = t2.month;
        """
      );
      log('getMonthlyStats() queries: $data');
      List<IncomeExpenseMonthly> incomeExpenseMonthlyData = data.map(
              (incomeExpenseData) => IncomeExpenseMonthly(
                expense: incomeExpenseData["expense"],
                income: incomeExpenseData["income"],
                label: incomeExpenseData["label"]
              )
      ).toList();
      return incomeExpenseMonthlyData;
    }
    catch(error){
      log("getMonthlyStats() error: $error");
      return "error";
    }
  }

  Future<dynamic> getAllPie() async {
    try {
      List<Map> data = await database.rawQuery(
          """
          Select txnMode, sum(amount) as stats from spend group by txnMode;
          """
      );
      log('getMonthlyStats() queries: $data');
      List<TxnCategory> txnData = data.map(
              (txn) => TxnCategory(
              txnMode: txn["txnMode"],
              stats: txn["stats"]
          )
      ).toList();
      return txnData;
    }
    catch(error){
      log("getMonthlyStats() error: $error");
      return "error";
    }
  }

  Future<dynamic> getAllTxn() async {
    try {
      List<Map> data = await database.rawQuery(
        """
        Select id, date, time, amount, item, category, txnMode,"spend" as type from spend 
        union
        Select id, date, time, amount, '' as item, '' as category, '' as txnMode,"income" as type  from income
        order by time desc
        """
      );
      log('getAllTxn() queries: $data');
      return data;
    }
    catch(error){
      log("getAllTxn() error: $error");
      return "error";
    }
  }

}