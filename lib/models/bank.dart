class Bank {
  String? id;
  String? name;
  List<String> registeredUsersIds = [];
  Bank({this.id, this.name, required this.registeredUsersIds});

  static Map<String, dynamic> toJson(Bank bank) {
    return {
      "id":bank.id,
      "name":bank.name,
      "resgisteredUsersIds":bank.registeredUsersIds,
    };
  }

  factory Bank.fromJson(Map<String, dynamic> bankDetails) {
    return Bank(
        id: bankDetails["id"],
        name: bankDetails["name"],
        registeredUsersIds:
              bankDetails["registeredUsersIds"] ==null ? [] :List<String>.from(bankDetails["registeredUsersIds"]), 
            ) ;
  }
}
