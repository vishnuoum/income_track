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
  String barChartTitle = "Your spends this month";
  late DBService dbService;
  String amount = "0.0";
  dynamic response;

  List<Map> data = [];

  List<Map> allTxn = [];

  List<IncomeExpenseMonthly> barChartData = [];

  List<TxnCategory> pieChartData = [];

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

    // Load monthly data
    response = await dbService.getMonthlyStats();
    if(response != "error") {
      barChartData = response;
    }

    // Load all pie data
    response = await dbService.getAllPie();
    if(response != "error") {
      pieChartData = response;
    }

    // Load all txn
    response = await dbService.getAllTxn();
    if(response != "error") {
      allTxn = response;
    }

    setState(() {});

  }

  Widget getHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(onPressed: ()async{
            await Navigator.pushNamed(context, "/addIncome" ,arguments: {"dbObject":dbService});
            loadHome();
          },icon: const Icon(Icons.more_vert))
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60,),
            Align(
              alignment: Alignment.center,
              child: Column(
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
                      onPressed: (){
                        setState(() {
                          selector = 0;
                        });
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
                      onPressed: (){
                        setState(() {
                          selector = 1;
                        });
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
                      onPressed: (){
                        setState(() {
                          selector = 2;
                        });
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
                      onPressed: (){
                        setState(() {
                          selector = 3;
                        });
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
                margin: const EdgeInsets.all(15),
                  tooltipBehavior: TooltipBehavior(enable: true),
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
              child: SfCircularChart(
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
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 30),
        itemCount: allTxn.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: (){},
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
