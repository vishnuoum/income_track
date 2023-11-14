import 'package:flutter/material.dart';

import '../services/dbServices.dart';

class Init extends StatefulWidget {
  const Init({super.key});

  @override
  State<Init> createState() => _InitState();
}

class _InitState extends State<Init> {

  DBService dbService = DBService();
  
  @override
  void initState() {
    super.initState();
    loadDB();
  }

  void loadDB() async{
    if((await dbService.initDB())=="done"){
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, "/home",arguments: {"dbObject" : dbService});
    }
    else{
      Future.delayed(const Duration(seconds: 5),(){
        loadDB();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(height: 50,width: 50,child: CircularProgressIndicator(strokeWidth: 5,),),
      ),
    );
  }
}

