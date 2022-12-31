import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class TodoListModel extends ChangeNotifier {
  List<Task> todos = [];
  bool isLoading = true;
  final String _rpcUrl = "http://192.168.29.49:7545";
  final String _wsUrl = "ws://192.168.29.49:7545/";

  final String _privateKey =
      "fbe4a70e1fd25d8b7f650209bcc80b40acf83d3c1f76e23e440c1c697afcc925";
  int taskCount = 0;
  Web3Client? _client;
  String? _abiCode;
  Credentials? _credentials;
  EthereumAddress? _contractAddress;
  EthereumAddress? _ownAddress;
  DeployedContract? _contract;
  ContractFunction? _taskCount;
  ContractFunction? _todos;
  ContractFunction? _createTask;
  ContractEvent? _taskCreatedEvent;

  TodoListModel() {
    initiateSetup();
  }

  Future<void> initiateSetup() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("src/abis/TransactionList.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    
  }

  Future<void> getCredentials() async {
    _credentials = await _client!.credentialsFromPrivateKey(_privateKey);

    _ownAddress = await _credentials!.extractAddress();
  }

  Future<void> getDeployedContract() async {
    try {
      _contract = DeployedContract(
          ContractAbi.fromJson(_abiCode!, "TransactionList"),
          _contractAddress!);

      _taskCount = _contract!.function("transactionCount");
      _createTask = _contract!.function("createTransaction");
      _todos = _contract!.function("transactions");
      _taskCreatedEvent = _contract!.event("TransactionCreated");

      //getTodos();
      print("");
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }



  addTask(String transactionId, String senderId, String receiverId,
      String senderBankId, String receiverBankId, String amount) async {
    isLoading = true;
    notifyListeners();
    try {
      await _client!.sendTransaction(
          _credentials!,
          Transaction.callContract(
              contract: _contract!,
              function: _createTask!,
              parameters: [
                transactionId,
                senderId,
                senderBankId,
                receiverId,
                receiverBankId,
                amount
              ]));
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }
}

class Task {
  String? taskName;
  bool? isCompleted;
  Task({this.taskName, this.isCompleted});
}
