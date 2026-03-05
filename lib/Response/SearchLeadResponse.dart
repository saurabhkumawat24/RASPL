class SearchLeadResponse {
  List<SearchLeadData> data;

  SearchLeadResponse({required this.data});

  factory SearchLeadResponse.fromJson(Map<String, dynamic> json) {
    return SearchLeadResponse(
      data: json['Data'] != null
          ? List<SearchLeadData>.from(
          json['Data'].map((x) => SearchLeadData.fromJson(x)))
          : [],
    );
  }
}

class SearchLeadData {
  final int pkid;
  final String productName;
  final int fkAgentID;
  final String agentLoginID;
  final String agentName;
  final String companyURL;
  final String agentPhoto;
  final String creationDate;
  final int fkProductID;
  final String leadID;
  final String leadDescription;
  final String leadStatus;
  final int fkAssignID;
  final String assignLoginID;
  final String assignName;
  final String assignDate;
  final String remarks;
  int unReadUserCount; // 🔥 mutable for badge update

  SearchLeadData({
    required this.pkid,
    required this.productName,
    required this.fkAgentID,
    required this.agentLoginID,
    required this.agentName,
    required this.companyURL,
    required this.agentPhoto,
    required this.creationDate,
    required this.fkProductID,
    required this.leadID,
    required this.leadDescription,
    required this.leadStatus,
    required this.fkAssignID,
    required this.assignLoginID,
    required this.assignName,
    required this.assignDate,
    required this.remarks,
    required this.unReadUserCount,
  });

  factory SearchLeadData.fromJson(Map<String, dynamic> json) {
    return SearchLeadData(
      pkid: json['PKID'] ?? 0,
      productName: json['ProductName'] ?? "",
      fkAgentID: json['FKAgentID'] ?? 0,
      agentLoginID: json['AgentLoginID'] ?? "",
      agentName: json['AgentName'] ?? "",
      companyURL: json['CompanyURL'] ?? "",
      agentPhoto: json['AgentPhoto'] ?? "",
      creationDate: json['CreationDate'] ?? "",
      fkProductID: json['FKProductID'] ?? 0,
      leadID: json['LeadID'] ?? "",
      leadDescription: json['LeadDescription'] ?? "",
      leadStatus: json['LeadStatus'] ?? "",
      fkAssignID: json['FKAssignID'] ?? 0,
      assignLoginID: json['AssignLoginID'] ?? "",
      assignName: json['AssignName'] ?? "",
      assignDate: json['AssignDate'] ?? "",
      remarks: json['Remarks'] ?? "",
      unReadUserCount: json['UnReadUserCount'] ?? 0,
    );
  }
}