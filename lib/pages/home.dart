import 'package:flutter/material.dart';
import 'package:income_track/chart/IncomeExpenseMonthly.dart';
import 'package:income_track/chart/TxnCategory.dart';
import 'package:income_track/services/dbServices.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  final Map args;
  const Home({super.key,required this.args});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int selector = 0;
  String barChartTitle = "Your transactions this month";
  late DBService dbService;
  String amount = "0.0";
  String balance = "0.0";
  dynamic response;
  String active = "spend";

  List<Map> data = [];

  List<Map> allTxn = [];

  List<IncomeExpenseMonthly> barChartData = [];

  List<TxnCategory> pieChartData = [];

  List<Map> analyticsByCategory = [];

  @override
  void initState() {
    dbService = widget.args["dbObject"];
    loadHome();
    super.initState();
  }

  void loadHome() async {
    // Load Recent spends
    response = await dbService.getRecentSpends();
    if(response != "error") {
      data = response;
    }

    // Load Amount
    response = await dbService.getThisMonthSpend();
    if(response != "error") {
      amount = response;
    }

    // Load Balance
    response = await dbService.getBalance();
    if(response != "error") {
      balance = response;
    }

    // Load bar chart data
    switch(selector){
      case 0:
        response = await dbService.getThisMonthStats();
        barChartTitle = "Your transactions this month";
        break;
      case 1:
        response = await dbService.getThisYearStats();
        barChartTitle = "Your transactions this year";
        break;
      case 2:
        response = await dbService.getMonthlyStats();
        barChartTitle = "Your monthly transactions";
        break;
      case 3:
        response = await dbService.getYearlyStats();
        barChartTitle = "Your early transactions";
        break;
    }
    if(response != "error") {
      barChartData = response;
    }

    // Load pie data
    switch(selector) {
      case 0:
        response = await dbService.getThisMonthPie();
        break;
      case 1:
        response = await dbService.getThisYearPie();
        break;
      case 2:
      case 3:
        response = await dbService.getAllPie();
        break;
    }
    if(response != "error") {
      pieChartData = response;
    }

    // Load analytics by category
    switch(selector) {
      case 0:
        response = await dbService.getCategoryByThisMonth();
        break;
      case 1:
        response = await dbService.getCategoryByThisYear();
        break;
      case 2:
      case 3:
        response = await dbService.getCategoryAll();
        break;
    }
    if(response != "error") {
      analyticsByCategory = response;
    }

    // Load all txn
    response = await dbService.getAllTxn();
    if(response != "error") {
      allTxn = response;
    }
    setState(() {});

  }

  Future<dynamic> deleteDialog() async {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Alert'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Proceed to delete this entry?"),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: <Widget>[
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(onPressed: ()async{},icon: const Icon(Icons.more_vert))
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60,),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: (){},
                onDoubleTap: (){
                  if(active == "spend") {
                    active = "balance";
                  }
                  else if(active == "balance") {
                    active = "spend";
                  }
                  setState((){});
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 0),
                  switchInCurve: Curves.fastOutSlowIn,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                        filterQuality: FilterQuality.high,
                        scale: animation, child: child
                    );
                  },
                  child: active=="spend"?
                  Column(
                    key: ValueKey<String>(active),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("This month spend"),
                      const SizedBox(height: 15,),
                      Text("₹$amount",style: const TextStyle(fontSize: 40),),
                      const SizedBox(height: 15,),
                      TextButton.icon(onPressed: ()async{
                        await Navigator.pushNamed(context, "/addSpend", arguments: {"dbObject":dbService});
                        loadHome();
                      }, icon: const Icon(Icons.add), label: const Text("Add Spend")),
                    ],
                  ):
                  Column(
                    key: ValueKey<String>(active),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Your Balance"),
                      const SizedBox(height: 15,),
                      Text("₹$balance",style: const TextStyle(fontSize: 40),),
                      const SizedBox(height: 15,),
                      TextButton.icon(onPressed: ()async{
                        await Navigator.pushNamed(context, "/addIncome", arguments: {"dbObject":dbService});
                        loadHome();
                      }, icon: const Icon(Icons.add), label: const Text("Add Income")),
                    ],
                  ),
                )
                ,
              ),
            ),
            const SizedBox(height: 30,),
            Expanded(
              child: Theme(
                data: ThemeData.light(),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
                  ),
                  child: data.isEmpty?Center(
                    child: Text("No Recent Spends", style: TextStyle(color: Colors.grey[700],fontWeight: FontWeight.bold),),
                  ):Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: data.length+1,
                          itemBuilder: (context, index) {
                            if(index == 0) {
                              return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 25, top: 15),
                                    child: Text("Your recent spends", style: TextStyle(color: Colors.grey[700],fontWeight: FontWeight.bold),),
                                  )
                              );
                            }
                            index--;
                            return ListTile(
                              leading: Text(
                                data[index]["txnMode"]!,
                                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                              ),
                              title: Text(data[index]["item"]!, style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              subtitle: Text(data[index]["date"]!, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold),),
                              trailing: Text("₹${data[index]["amount"]!}", style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              isThreeLine: true,
                              onTap: (){},
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),

            )
          ],
        ),
      ),
    );
  }

  Widget getAnalyticsScreen() {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0,bottom: 25, top: 18),
              child: Text("Analytics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            SizedBox(
              height: 60,
              child: ListView(
                padding: const EdgeInsets.all(10),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () async {
                        setState(() {
                          selector = 0;
                        });
                        barChartTitle = "Your transactions this month";
                        response = await dbService.getThisMonthStats();
                        if(response !="error") {
                          barChartData = response;
                        }
                        response = await dbService.getThisMonthPie();
                        if(response !="error") {
                          pieChartData = response;
                        }
                        response = await dbService.getCategoryByThisMonth();
                        if(response !="error") {
                          analyticsByCategory = response;
                        }
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        backgroundColor: selector==0?Colors.white:Colors.white12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200))
                      ),
                      child: Text("This month",style: TextStyle(color: selector==0?Colors.black:Colors.white),),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () async {
                        setState(() {
                          selector = 1;
                        });
                        barChartTitle = "Your transactions this year";
                        response = await dbService.getThisYearStats();
                        if(response !="error") {
                          barChartData = response;
                        }
                        response = await dbService.getThisYearPie();
                        if(response !="error") {
                          pieChartData = response;
                        }
                        response = await dbService.getCategoryByThisYear();
                        if(response !="error") {
                          analyticsByCategory = response;
                        }
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: selector==1?Colors.white:Colors.white12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200))
                      ),
                      child: Text("This year",style: TextStyle(color: selector==1?Colors.black:Colors.white),),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: ()async {
                        setState(() {
                          selector = 2;
                        });
                        barChartTitle = "Your monthly transactions";
                        response = await dbService.getMonthlyStats();
                        if(response !="error") {
                          barChartData = response;
                        }
                        response = await dbService.getAllPie();
                        if(response !="error") {
                          pieChartData = response;
                        }
                        response = await dbService.getCategoryAll();
                        if(response !="error") {
                          analyticsByCategory = response;
                        }
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: selector==2?Colors.white:Colors.white12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200))
                      ),
                      child: Text("Monthly", style: TextStyle(color: selector==2?Colors.black:Colors.white),),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () async {
                        setState(() {
                          selector = 3;
                        });
                        barChartTitle = "Your yearly transactions";
                        response = await dbService.getYearlyStats();
                        if(response !="error") {
                          barChartData = response;
                        }
                        response = await dbService.getAllPie();
                        if(response !="error") {
                          pieChartData = response;
                        }
                        response = await dbService.getCategoryAll();
                        if(response !="error") {
                          analyticsByCategory = response;
                        }
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: selector==3?Colors.white:Colors.white12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200))
                      ),
                      child: Text("Yearly", style: TextStyle(color: selector==3?Colors.black:Colors.white),),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(barChartTitle,style: const TextStyle(fontWeight: FontWeight.bold),),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                zoomPanBehavior: ZoomPanBehavior(
                  enableDoubleTapZooming: true,
                  enablePanning: true,
                  enablePinching: true
                ),
                margin: const EdgeInsets.all(15),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    format: 'point.x: ₹point.y',
                  ),
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                      majorGridLines: const MajorGridLines(width: 0)
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<IncomeExpenseMonthly, String>(
                        color: Colors.white,
                        name: "Expense",
                        dataSource: barChartData,
                        xValueMapper: (IncomeExpenseMonthly data, _) => data.label,
                        yValueMapper: (IncomeExpenseMonthly data, _) => data.expense
                    ),
                    ColumnSeries<IncomeExpenseMonthly, String>(
                        color: Colors.white10,
                        name: "Income",
                        dataSource: barChartData,
                        xValueMapper: (IncomeExpenseMonthly data, _) => data.label,
                        yValueMapper: (IncomeExpenseMonthly data, _) => data.income
                    )
                  ]
              ),
            ),
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Transaction modes",style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              height: 300,
              child: pieChartData.isEmpty?
              const Center(
                child: Text("No transactions", style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
              ):
              SfCircularChart(
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    format: 'point.x: ₹point.y',
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  series: <CircularSeries>[
                    // Render pie chart
                    PieSeries<TxnCategory, String>(
                      explode: true,
                        dataSource: pieChartData,
                        xValueMapper: (TxnCategory data, _) => data.txnMode,
                        yValueMapper: (TxnCategory data, _) => data.stats,
                        dataLabelMapper: (TxnCategory data, _) => data.txnMode,
                        pointColorMapper: (TxnCategory data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                          textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                        )
                    )
                  ]
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.white
              ),
              constraints: const BoxConstraints(
                minHeight: 200,
                minWidth: double.infinity
              ),
              child: analyticsByCategory.isEmpty?
              const Center(
                child: Text("No transactions", style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
              ):
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Analytics by Category",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: analyticsByCategory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        title: Text(analyticsByCategory[index]["category"]),
                        subtitle: LinearProgressIndicator(
                          value: analyticsByCategory[index]["percent"],
                          color: Colors.black,
                          backgroundColor: Colors.grey,
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          children: [
                            Text("₹${analyticsByCategory[index]["amount"]}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 5,),
                            Text("${(analyticsByCategory[index]["percent"]*100).toStringAsFixed(2)}%", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),)
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getIncomeExpenseScreen() {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        title: const Text("Income & Expenses"),
      ),
      body: allTxn.isEmpty?
      const Center(
        child: Text("No transactions to show",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey
          ),
        ),
      ):
      ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 30),
        itemCount: allTxn.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onDoubleTap: () async {
              bool flag = await deleteDialog();
              if(flag) {
                if(allTxn[index]["type"]=="income") {
                  response = await dbService.deleteIncome(id: allTxn[index]["id"]);
                }
                else {
                  response = await dbService.deleteSpend(id: allTxn[index]["id"]);
                }
                if(response == "done") {
                  loadHome();
                }
              }
            },
            child: ListTile(
              onLongPress: ()async{
                if(allTxn[index]["type"]=="income") {
                  await Navigator.pushNamed(context, "/addIncome", arguments: {"dbObject":dbService,"updateData":allTxn[index]});
                  loadHome();
                }
                else {
                  await Navigator.pushNamed(context, "/addSpend", arguments: {"dbObject":dbService,"updateData":allTxn[index]});
                  loadHome();
                }
              },
              leading: allTxn[index]["type"]=="income"?
              const RotatedBox(quarterTurns: 2,child: Icon(
                Icons.arrow_outward,
                color: Colors.green,
              ),)
              :const Icon(
                Icons.arrow_outward,
                color: Colors.red,
              ),
              isThreeLine: true,
              title: Text(allTxn[index]["type"]=="income"?"Added to Balance":allTxn[index]["item"], style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
              trailing: Text("₹${allTxn[index]["amount"]!}", style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
              subtitle: Text(allTxn[index]["date"], style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold),),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: TabBarView(
          children: [
            getIncomeExpenseScreen(),
            getHomeScreen(),
            getAnalyticsScreen()
          ],
        )
    );
  }
}
