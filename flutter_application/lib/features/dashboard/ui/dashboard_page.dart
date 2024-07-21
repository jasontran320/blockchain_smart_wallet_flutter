import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:flutter_application/features/deposit/deposit.dart';
import 'package:flutter_application/features/withdraw/withdraw.dart';
import 'package:flutter_application/models/transaction_model.dart';
import 'package:flutter_application/utils/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardBloc dashboardBloc = DashboardBloc();
  String _generatedText = ''; // State variable to store the generated
  int _isgenerated = 0;
  final gemini = Gemini.instance;

  @override
  void initState() {
    super.initState();
    _isgenerated = 0;
    dashboardBloc.add(DashboardInitialFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      appBar: AppBar(
        title: Text("web3 Bank"),
        backgroundColor: AppColors.accent,
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        bloc: dashboardBloc,
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case DashboardLoadingState:
              return Center(child: CircularProgressIndicator(),
              );
              case DashboardErrorState:
                return Center(child: Text("Error"),
                );
              case DashboardSuccessState:
                final successState = state as DashboardSuccessState;
                final my_balance = successState.balance.toString();
                List<String> reasons = successState.transactions.map((transaction) => "Amount: "+ transaction.amount.toString() + " ETH, Reason: " + transaction.reason).toList();
                final reason = "Total balance: " + my_balance + ": "+ reasons.join(', ');
                if (_isgenerated == 0) {
                  _isgenerated = 1;
                  gemini.text("Analyze $reason who's elements are totalbalance: followed by a list of amount and reason per transaction - in the form (Amount, Reason) - seperated by commas. In 1-3 sentences, give useful feedback on those transactions, can be financial or behavioral. Please note for any poor spending transaction reasons or outliers and potential improvements. If there is nothing in the list, respond by offering advice on how to get started in 1-3 sentences. Do not exceed 1-3 sentences in any response.")
                    .then((value) {
                      setState(() {
                        _generatedText = value?.output ?? "No text generated.";
                      });
                    })
                    .catchError((e) {
                      setState(() {
                        _generatedText = "Error: $e";
                      });
                    });
                    
                }
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Wrap(
                          children: [
                            
                      
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/eth-logo.svg",
                                      height: 50, width: 50),
                                  const SizedBox(width: 12),
                                  Text(
                                    successState.balance.toString() + ' ETH',
                                    style: TextStyle(
                                        fontSize: 50, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 30),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(_generatedText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal), overflow: TextOverflow.visible,),
                                  ),


                          InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DashboardPage())),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white),
                              child: Center(
                                child: Text(
                                  "Prompt AI Analysis",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                          )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WithdrawPage(dashboardBloc: dashboardBloc,))),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.redAccent),
                              child: Center(
                                child: Text(
                                  "- DEBIT",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DepositPage(
                                      dashboardBloc: dashboardBloc,
                                    ))),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.greenAccent),
                              child: Center(
                                child: Text(
                                  "+ CREDIT",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ))
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("Transactions",
                          style:
                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                          child: ListView.builder(
                            itemCount: successState.transactions.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset("assets/eth-logo.svg",
                                            height: 24, width: 24),
                                        const SizedBox(width: 6),
                                        Text(successState.transactions[index].amount.toString() + ' ETH',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                    Text(
                                        successState.transactions[index].address.toString(),
                                        style: TextStyle(fontSize: 12)),
                                    Text(
                                      successState.transactions[index].reason.toString(),
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                              );
                            },
                        
                      )),
                    ],
                  ),
                );
              default:
                return SizedBox();
          }
        },
      ),
    );
  }
}
