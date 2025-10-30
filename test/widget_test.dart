// Bible App Widget Tests
// Tests for the main app functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sang03_nhom01_apptimbaidoctheongay/main.dart';

void main() {
  testWidgets('Bible App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BuddhismApp());

    // Verify that our app title is displayed (check for at least one)
    expect(find.text('App Tìm Bài Đọc Theo Ngày'), findsWidgets);
    
    // Verify that database initialization message is shown
    expect(find.text('Database đã được khởi tạo thành công!'), findsOneWidget);
    
    // Verify that the book icon is displayed
    expect(find.byIcon(Icons.menu_book), findsOneWidget);
  });
}
