import 'package:flutter/material.dart';

class Init extends StatefulWidget {
  const Init({super.key});

  @override
  State<Init> createState() => _InitState();
}

class _InitState extends State<Init> {
  
  @override
  void initState() {
    super.initState();
    load();
  }
  
  void load() {
    Future.delayed(const Duration(seconds: 5), (){
      Navigator.pushReplacementNamed(context, "/home", arguments: {});
    });
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

