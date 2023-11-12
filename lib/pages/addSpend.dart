import 'package:flutter/material.dart';
import 'package:income_track/services/dbServices.dart';
import 'package:intl/intl.dart';

class AddSpend extends StatefulWidget {
  final Map args;
  const AddSpend({super.key, required this.args});

  @override
  State<AddSpend> createState() => _AddSpendState();
}

class _AddSpendState extends State<AddSpend> {

  final formKey = GlobalKey<FormState>();
  dynamic id;
  late DBService dbService;

  DateTime selectedDate = DateTime.now();
  List<Map> eItems = [];
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  TextEditingController date = TextEditingController(text: DateFormat("yyyy-MM-dd").format(DateTime.now())),
      amount = TextEditingController(text: ""),
      item = TextEditingController(text: ""),
      category = TextEditingController(text: ""),
      txnMode = TextEditingController(text: "");

  Future<void> selectDate()async{
    selectedDate = (await showDatePicker(context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),))!;
    setState((){
      date.text = dateFormat.format(selectedDate);
    });
  }

  Future<void> alertDialog(var text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showLoading(BuildContext context){
    AlertDialog alert = const AlertDialog(
      content: SizedBox(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50,width: 50,child: CircularProgressIndicator(strokeWidth: 5),),
            SizedBox(height: 10,),
            Text("Loading",)
          ],
        ),
      ),
    );

    showDialog(context: context,builder:(BuildContext context){
      return WillPopScope(onWillPop: ()async => false,child: alert);
    });
  }

  @override
  void initState() {
    super.initState();
    dbService = widget.args["dbObject"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 25),
            children: [
              const SizedBox(height: 50,),
              const Text("Add Spend",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
              const SizedBox(height: 30,),
              Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date"),
                      const SizedBox(height: 10,),
                      TextFormField(
                        readOnly: true,
                        controller: date,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter Date"
                        ),
                        onTap: ()async{
                          await selectDate();
                        },
                      ),
                      const SizedBox(height: 15,),
                      const Text("Item"),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: item,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter Item"
                        ),
                      ),
                      const SizedBox(height: 15,),
                      const Text("Category"),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: category,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter Category"
                        ),
                      ),
                      const SizedBox(height: 15,),
                      const Text("Txn Mode"),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: txnMode,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter Txn Mode"
                        ),
                      ),
                      const SizedBox(height: 15,),
                      const Text("Amount"),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: amount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter Amount"
                        ),
                      ),
                      const SizedBox(height: 20,),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: ()async{
                            FocusScope.of(context).unfocus();
                            if(date.text.isEmpty || item.text.isEmpty || category.text.isEmpty || txnMode.text.isEmpty || amount.text.isEmpty) {
                              alertDialog("Please complete the form");
                            }
                            else {
                              showLoading(context);
                              dynamic response = await dbService.addSpend(date: date.text, item: item.text, category: category.text, txnMode: txnMode.text, amount: amount.text);
                              if(!context.mounted) return;
                              Navigator.pop(context);
                              if(response == "done") {
                                item.clear();
                                category.clear();
                                txnMode.clear();
                                amount.clear();
                                alertDialog("Added Successfully");
                              }
                              else {
                                alertDialog("Error adding spend");
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )
                          ),
                          child: const Text("Add"),
                        ),
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
