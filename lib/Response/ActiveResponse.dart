import 'package:intl/intl.dart';

class ActiveResponse {
  final List<LeadItem> data;

  ActiveResponse({required this.data});

  factory ActiveResponse.fromJson(Map<String, dynamic> json) {
    return ActiveResponse(
      data: (json['Data'] as List? ?? [])
          .map((e) => LeadItem.fromJson(e))
          .toList(),
    );
  }
}

class LeadItem {
  final int pkId;
  final String productName;
  final int fkAgentId;
  final String agentLoginId;
  final String agentName;
  final String companyUrl;
  final String? agentPhoto;
  final String iconUrl;
  final DateTime? creationDate;
  final int fkProductId;
  final String leadId;
  final String leadDescription;
  final String leadStatus;
  final int fkAssignId;
  final String assignLoginId;
  final String assignName;
  final DateTime? assignDate;
  final DateTime? lastMessageDate;
  final String remarks;
  int unReadUserCount;

  LeadItem({
    required this.pkId,
    required this.productName,
    required this.fkAgentId,
    required this.agentLoginId,
    required this.agentName,
    required this.companyUrl,
    this.agentPhoto,
    required this.iconUrl,
    required this.creationDate,
    required this.fkProductId,
    required this.leadId,
    required this.leadDescription,
    required this.leadStatus,
    required this.fkAssignId,
    required this.assignLoginId,
    required this.assignName,
    required this.assignDate,
    required this.lastMessageDate,
    required this.remarks,
    required this.unReadUserCount,
  });

  factory LeadItem.fromJson(Map<String, dynamic> json) {
    return LeadItem(
      pkId: json['PKID'] ?? 0,
      productName: json['ProductName'] ?? '',
      fkAgentId: json['FKAgentID'] ?? 0,
      agentLoginId: json['AgentLoginID'] ?? '',
      agentName: json['AgentName'] ?? '',
      companyUrl: json['CompanyURL'] ?? '',
      agentPhoto: json['AgentPhoto'],
      iconUrl: json['IconURL'] ?? '',
      creationDate: _parseDate(json['CreationDate']),
      fkProductId: json['FKProductID'] ?? 0,
      leadId: json['LeadID'] ?? '',
      leadDescription: json['LeadDescription'] ?? '',
      leadStatus: json['LeadStatus'] ?? '',
      fkAssignId: json['FKAssignID'] ?? 0,
      assignLoginId: json['AssignLoginID'] ?? '',
      assignName: json['AssignName'] ?? '',
      assignDate: _parseDate(json['AssignDate']),
      lastMessageDate: _parseDate(json['LastMessageDate']),
      remarks: json['Remarks'] ?? '',
      unReadUserCount: json['UnReadUserCount'] ?? 0,
    );
  }

  /// 🔥 Custom backend date format handler
  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateFormat("dd/MM/yyyy hh:mm a").parse(value);
    } catch (_) {
      return null;
    }
  }

  /// 🔹 UI friendly formatted date
  String get formattedAssignDate {
    if (assignDate == null) return '';
    return DateFormat("dd MMM, hh:mm a").format(assignDate!);
  }
}