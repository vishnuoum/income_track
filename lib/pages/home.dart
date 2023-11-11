import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Map args;
  const Home({super.key,required this.args});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Map<String,String>> data = [
    {"id" : "1", "txnMode" : "UPI", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "2", "txnMode" : "CC", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "3", "txnMode" : "UPI", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "4", "txnMode" : "CC", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "1", "txnMode" : "UPI", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "2", "txnMode" : "CC", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "3", "txnMode" : "UPI", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "4", "txnMode" : "CC", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "1", "txnMode" : "UPI", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "2", "txnMode" : "CC", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "3", "txnMode" : "UPI", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
    {"id" : "4", "txnMode" : "CC", "amount" : "3000", "date" : "2023-03-23", "summary":"Demo"},
  ];

  @override
  void initState() {
    print(data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(onPressed: (){},icon: const Icon(Icons.more_vert))
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
                  const Text("₹20000.00",style: TextStyle(fontSize: 40),),
                  const SizedBox(height: 15,),
                  TextButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text("Add Spend")),
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
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.all(20),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            if(index == 0) {
                              index--;
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Text("Your recent spends", style: TextStyle(color: Colors.grey[700],fontWeight: FontWeight.bold),),
                                )
                              );
                            }
                            return ListTile(
                              leading: Text(
                                data[index]["txnMode"]!,
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                              ),
                              title: Text(data[index]["summary"]!, style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              subtitle: Text(data[index]["date"]!, style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),),
                              trailing: Text("₹${data[index]["amount"]!}", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
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
}
