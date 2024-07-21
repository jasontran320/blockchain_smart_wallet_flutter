import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/models/transaction_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';


part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardInitialFetchEvent>(dashboardInitialFetchEvent);
    on<DashboardDepositEvent>(dashboardDepositEvent);
    on<DashboardWithdrawEvent>(dashboardWithdrawEvent);
  }

  List<TransactionModel> transactions = [];
  Web3Client? _web3client;
  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;
  late EthPrivateKey _creds;
  int balance = 0;


  late DeployedContract _deployedContract;

//Functions
  late ContractFunction _deposit;
  late ContractFunction _withdraw;
  late ContractFunction _getBalance;
  late ContractFunction _getAllTransactions;


  FutureOr<void> dashboardInitialFetchEvent(DashboardInitialFetchEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoadingState());
    try {final String rpcUrl = "http://127.0.0.1:7545";
    final String socketUrl = "ws://127.0.0.1:7545";
    final String privateKey = "0x6c73efdec1de85d8181d88f66cdc18ec57601e4b9116728d5d5c6051cdd7acb3"; //Change this depending on ganash key

    _web3client = Web3Client(rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(socketUrl).cast<String>();
    }
    );
    //getABI
    String abiFile = await rootBundle.loadString('build/contracts/ExpenseManagerContract.json');
    var jsonDecoded = jsonDecode(abiFile);
    _abiCode = ContractAbi.fromJson(jsonEncode(jsonDecoded['abi']), 'ExpenseManagerContract');
    _contractAddress = EthereumAddress.fromHex(jsonDecoded["networks"]["5777"]["address"]);
    _creds = EthPrivateKey.fromHex(privateKey);

    //get deployed contract
    _deployedContract = DeployedContract(_abiCode, _contractAddress);
    _deposit = _deployedContract.function("deposit");
    _withdraw = _deployedContract.function("withdraw");
    _getBalance = _deployedContract.function("getBalance");
    _getAllTransactions = _deployedContract.function("getAllTransactions");


    final transactionsData = await _web3client!.call(contract: _deployedContract, function: _getAllTransactions, params: []);
    final balanceData = await _web3client!.call(contract: _deployedContract, function: _getBalance, params: [EthereumAddress.fromHex("0x0b7dd1e30b180AB951d3F4d5bbAeED313E5536E2")]);//Change to ganash address
   
    List<TransactionModel> trans = [];
    for(int i = 0; i < transactionsData[0].length; i++) {
      TransactionModel transactionModel = TransactionModel(
      transactionsData[0][i].toString(), 
      transactionsData[1][i].toInt(), 
      transactionsData[2][i], 
      DateTime.fromMicrosecondsSinceEpoch(transactionsData[3][i].toInt()));
      trans.add(transactionModel);
    }
    transactions = trans;

    int bal = balanceData[0].toInt();
    balance = bal;
    emit(DashboardSuccessState(transactions: transactions, balance: balance));
    }
    catch (e) {
      log(e.toString());
      emit(DashboardErrorState());
    }
  }

  FutureOr<void> dashboardDepositEvent(DashboardDepositEvent event, Emitter<DashboardState> emit) async {
    try {
      final transaction = Transaction.callContract(
        contract: _deployedContract, function: _deposit, parameters: [
        BigInt.from(event.transactionModel.amount),
        event.transactionModel.reason
        ],
        value: EtherAmount.inWei(BigInt.from(event.transactionModel.amount)));

      final result = await _web3client!.sendTransaction(_creds, transaction, chainId: 1337, fetchChainIdFromNetworkId: false);
      log(result.toString());
      add(DashboardInitialFetchEvent());
    } catch (e) {
      log(e.toString());
    }
  }

  FutureOr<void> dashboardWithdrawEvent(DashboardWithdrawEvent event, Emitter<DashboardState> emit) async {
    try {
      final transaction = Transaction.callContract(
        contract: _deployedContract, function: _withdraw, parameters: [
        BigInt.from(event.transactionModel.amount),
        event.transactionModel.reason
        ],
        );

      final result = await _web3client!.sendTransaction(_creds, transaction, chainId: 1337, fetchChainIdFromNetworkId: false);
      log(result.toString());
      add(DashboardInitialFetchEvent());
    } catch (e) {
      log(e.toString());
    }
  }
}
