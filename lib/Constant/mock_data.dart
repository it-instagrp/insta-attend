// lib/Constant/mock_data.dart

import 'package:insta_attend/Model/organization.dart';

class MockData {
  // ===== MOCK ORGANIZATIONS =====
  static List<Organization> mockOrganizations = [
    Organization(id: 'org_001', name: 'Insta ICT Solutions Pvt. Ltd.'),
    Organization(id: 'org_002', name: 'Insta Technologies'),
    Organization(id: 'org_003', name: 'Insta Finance Pvt. Ltd.'),
    Organization(id: 'org_004', name: 'InstaCorp Global Services'),
    Organization(id: 'org_005', name: 'Insta Innovations Inc.'),
    Organization(id: 'org_006', name: 'Tech Solutions Ltd.'),
    Organization(id: 'org_007', name: 'Digital Insta Works'),
    Organization(id: 'org_008', name: 'Insta Consulting Group'),
    Organization(id: 'org_009', name: 'Insta Software Development'),
    Organization(id: 'org_010', name: 'Global Insta Services'),
  ];

  // ===== COUNTRY CODES WITH VALIDATION =====
  static final mockCountryCodes = [
    {'name': 'India', 'code': '+91', 'digits': '10'},
    {'name': 'United States', 'code': '+1', 'digits': '10'},
    {'name': 'United Kingdom', 'code': '+44', 'digits': '10'},
    {'name': 'Australia', 'code': '+61', 'digits': '9'},
    {'name': 'Canada', 'code': '+1', 'digits': '10'},
    {'name': 'Germany', 'code': '+49', 'digits': '11'},
    {'name': 'France', 'code': '+33', 'digits': '9'},
    {'name': 'Japan', 'code': '+81', 'digits': '10'},
    {'name': 'Singapore', 'code': '+65', 'digits': '8'},
    {'name': 'UAE', 'code': '+971', 'digits': '9'},
  ];

  // ===== APPROVAL STATUS CONTROL FOR DEMO =====
  static String DEMO_APPROVAL_STATUS = 'PENDING';

  // ===== MOCK REGISTRATION RESPONSE =====
  static Map<String, dynamic> getRegistrationResponse() {
    return {
      'success': true,
      'data': {
        'registration_id': 'reg_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'PENDING',
        'message': 'Registration submitted successfully',
      },
    };
  }

  // ===== MOCK APPROVAL STATUS RESPONSE =====
  static Map<String, dynamic> getApprovalStatusResponse() {
    if (DEMO_APPROVAL_STATUS == 'APPROVED') {
      return {
        'status': 'APPROVED',
        'department': 'Engineering',
        'department_id': 'dept_001',
        'designation': 'Senior Developer',
        'designation_id': 'desig_001',
        'message': 'Your registration has been approved',
      };
    } else {
      return {
        'status': 'PENDING',
        'department': null,
        'department_id': null,
        'designation': null,
        'designation_id': null,
        'message': 'Waiting for HR approval',
      };
    }
  }

  // ===== SEARCH ORGANIZATIONS =====
  static List<Organization> searchOrganizations(String query) {
    if (query.trim().isEmpty) return [];
    return mockOrganizations
        .where(
          (org) => org.name.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();
  }
}