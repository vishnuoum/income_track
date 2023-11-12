import 'package:flutter/material.dart';

class TxnCategory {

  final String txnMode;
  final double stats;
  Color? color = Colors.grey;

  TxnCategory({required this.txnMode, required this.stats}) {
    if(txnMode== "CC") {
      color = Colors.white;
    }
    else if(txnMode == "UPI") {
      color = Colors.grey[700];
    }
  }

}