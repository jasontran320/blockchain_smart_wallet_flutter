import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:flutter_application/utils/colors.dart';
import 'package:flutter_application/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application/models/transaction_model.dart';

class WithdrawPage extends StatefulWidget {
  final DashboardBloc dashboardBloc;
  const WithdrawPage({super.key, required this.dashboardBloc});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redAccent,
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

//Fill in here



            const SizedBox(height: 80,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [InkWell(
                  onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardPage())),
                  child: Container(
                    height: 30,
                    width: 100, 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), 
                    color: AppColors.accent),
                    child: Center(
                      child: Text("HOME", style: TextStyle(color: Colors.blue, fontSize: 24,
                      fontWeight: FontWeight.bold),
                      ),
                    ),
                    ),
                ), 
                Text("Deposit Details",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
              ],
            ),
            const SizedBox(height: 20),
            // TextField(
            //   controller: addressController,
            //   decoration: InputDecoration(
            //     hintText: "Enter the Address")
            // ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: "Enter the Amount")
            ),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: "Enter the Enter the Reason")
            ),
            const SizedBox(height: 20),
            
            InkWell(
              onTap: () {
                widget.dashboardBloc.add(DashboardWithdrawEvent(transactionModel: TransactionModel(addressController.text, int.parse(amountController.text), reasonController.text, DateTime.now())));
                //sleep(Duration(seconds: 1));
                Navigator.pop(context, MaterialPageRoute(builder: (context)=>DashboardPage()));
                //Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardPage()));
              },
              child: Container(
                height: 50, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), 
                color: Colors.red),
                child: Center(
                  child: Text("- WITHDRAW", style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.bold),
                  ),
                ),
                ),
            ),


          ],
        ),
      ),
    );
  }
}