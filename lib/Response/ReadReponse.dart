class ReadResponse {
  List<Data>? data;

  ReadResponse({this.data});

  ReadResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? result;
  String? msg;

  Data({this.result, this.msg});

  Data.fromJson(Map<String, dynamic> json) {
    result = json['Result'];
    msg = json['Msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result;
    data['Msg'] = this.msg;
    return data;
  }
}
