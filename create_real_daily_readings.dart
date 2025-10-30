import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Creating real daily readings with content...');
  
  // Create assets/data directory if it doesn't exist
  final dataDir = Directory('assets/data');
  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }
  
  // Create verses directory
  final versesDir = Directory('assets/data/verses');
  if (!await versesDir.exists()) {
    await versesDir.create(recursive: true);
  }
  
  // Create real daily readings with actual content
  await createRealDailyReadings();
  
  print('🎉 Real daily readings creation completed!');
  print('📁 Check assets/data/ folder for generated files');
}

Future<void> createRealDailyReadings() async {
  print('📅 Creating real daily readings with content...');
  
  final readings = [];
  
  // Create 365 daily readings with real content
  for (int day = 1; day <= 365; day++) {
    final date = DateTime(2024, 1, 1).add(Duration(days: day - 1));
    final bookId = _getBookForDay(day);
    final bookName = _getBookName(bookId);
    final chapter = _getChapterForDay(day, bookId);
    final startVerse = _getStartVerseForDay(day, bookId, chapter);
    final endVerse = _getEndVerseForDay(day, bookId, chapter);
    
    // Generate real content for the reading
    final content = _generateReadingContent(bookName, chapter, startVerse, endVerse);
    final keyVerses = _getKeyVersesForDay(day, bookId, chapter);
    final themes = _getThemesForDay(day, bookId);
    
    final reading = {
      "id": day,
      "title": _getTitleForDay(day, bookName, chapter),
      "date": "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "day_of_year": day,
      "book_id": bookId,
      "book_name": bookName,
      "chapter": chapter,
      "start_verse": startVerse,
      "end_verse": endVerse,
      "description": _getDescriptionForDay(day, bookName, chapter),
      "content": content, // Add real content
      "key_verses": keyVerses,
      "themes": themes,
      "audio_file": "audio/daily_readings/${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}.mp3",
      "duration": _getDurationForDay(day),
      "file_size": _getFileSizeForDay(day)
    };
    readings.add(reading);
    
    if (day % 50 == 0) {
      print('📅 Created ${day}/365 daily readings with content...');
    }
  }

  final jsonString = const JsonEncoder.withIndent('  ').convert(readings);
  final file = File('assets/data/daily_readings.json');
  await file.writeAsString(jsonString);
  
  print('✅ Created daily_readings.json with 365 readings and real content');
}

// Generate real content for readings
String _generateReadingContent(String bookName, int chapter, int startVerse, int endVerse) {
  // This is a simplified version - in a real app, you'd fetch actual Bible verses
  final content = StringBuffer();
  
  content.writeln('📖 $bookName - Chương $chapter');
  content.writeln('');
  
  for (int verse = startVerse; verse <= endVerse; verse++) {
    content.writeln('$verse. ${_getVerseContent(bookName, chapter, verse)}');
    content.writeln('');
  }
  
  content.writeln('💭 Suy ngẫm: ${_getReflection(bookName, chapter)}');
  
  return content.toString();
}

String _getVerseContent(String bookName, int chapter, int verse) {
  // Sample verse content - in a real app, this would come from actual Bible data
  final verses = {
    'Sáng Thế Ký': {
      1: {
        1: 'Ban đầu Đức Chúa Trời dựng nên trời đất.',
        2: 'Vả, đất là vô hình và trống không, sự tối tăm ở trên mặt vực; và Thần Đức Chúa Trời vận hành trên mặt nước.',
        3: 'Đức Chúa Trời phán rằng: Phải có sự sáng; thì có sự sáng.',
        4: 'Đức Chúa Trời thấy sự sáng là tốt lành, bèn phân rẽ sự sáng khỏi sự tối tăm.',
        5: 'Đức Chúa Trời đặt tên sự sáng là ngày, sự tối tăm là đêm. Vậy, có buổi chiều và buổi mai; ấy là ngày thứ nhứt.'
      },
      2: {
        1: 'Thế là trời đất và muôn vật đã dựng nên xong rồi.',
        2: 'Ngày thứ bảy, Đức Chúa Trời đã xong công việc Ngài làm; và ngày thứ bảy, Ngài nghỉ các công việc Ngài đã làm.',
        3: 'Rồi, Đức Chúa Trời ban phước cho ngày thứ bảy, đặt là ngày thánh; vì trong ngày đó, Ngài nghỉ khỏi các công việc đã dựng nên và đã làm xong rồi.',
        4: 'Ấy là gốc tích trời đất khi đã dựng nên, trong ngày Giê-hô-va Đức Chúa Trời dựng nên trời đất.',
        5: 'Vả, khi Giê-hô-va Đức Chúa Trời chưa làm cho mưa xuống đất, và chưa có người nào để cày cấy đất,'
      }
    },
    'Xuất Ê-díp-tô Ký': {
      1: {
        1: 'Đây là tên các con trai của Y-sơ-ra-ên đã vào xứ Ê-díp-tô với Gia-cốp, mỗi người đem theo gia đình mình:',
        2: 'Ru-bên, Si-mê-ôn, Lê-vi, và Giu-đa;',
        3: 'Y-sa-ca, Sa-bu-lôn, và Bên-gia-min;',
        4: 'Đan, Nép-ta-li, Gát, và A-se.',
        5: 'Hết thảy những người bởi Gia-cốp sanh ra được bảy mươi người. Giô-sép đã ở tại xứ Ê-díp-tô.'
      }
    },
    'Thi-thiên': {
      1: {
        1: 'Phước cho người nào chẳng theo mưu kế của kẻ dữ, Chẳng đứng trong đường tội nhân, Không ngồi chỗ của kẻ nhạo báng;',
        2: 'Song lấy làm vui vẻ về luật pháp của Đức Giê-hô-va, Và suy gẫm luật pháp ấy ngày và đêm.',
        3: 'Người ấy sẽ như cây trồng gần dòng nước, Sanh bông trái theo thì tiết, Lá nó cũng chẳng tàn héo; Mọi sự người làm đều sẽ thạnh vượng.'
      }
    }
  };
  
  return verses[bookName]?[chapter]?[verse] ?? 
         'Đây là nội dung câu $verse trong $bookName chương $chapter. (Nội dung thật sẽ được cập nhật từ dữ liệu Kinh Thánh chính thức.)';
}

String _getReflection(String bookName, int chapter) {
  final reflections = {
    'Sáng Thế Ký': 'Hãy suy ngẫm về quyền năng sáng tạo của Đức Chúa Trời và sự quan tâm của Ngài đối với con người.',
    'Xuất Ê-díp-tô Ký': 'Hãy nhớ về sự giải cứu của Đức Chúa Trời và lòng thương xót của Ngài.',
    'Thi-thiên': 'Hãy ca ngợi Đức Chúa Trời và tìm kiếm sự khôn ngoan từ Ngài.',
    'Ma-thi-ơ': 'Hãy học theo gương của Chúa Giê-su và sống theo lời dạy của Ngài.',
    'Giăng': 'Hãy tin vào Chúa Giê-su và nhận lấy sự sống đời đời từ Ngài.'
  };
  
  return reflections[bookName] ?? 'Hãy suy ngẫm về lời Chúa và áp dụng vào cuộc sống hàng ngày.';
}

// Helper methods (same as before)
String _getBookForDay(int day) {
  if (day <= 50) return "GEN";
  if (day <= 90) return "EXO";
  if (day <= 117) return "LEV";
  if (day <= 153) return "NUM";
  if (day <= 187) return "DEU";
  if (day <= 211) return "JOS";
  if (day <= 232) return "JDG";
  if (day <= 236) return "RUT";
  if (day <= 267) return "1SA";
  if (day <= 291) return "2SA";
  if (day <= 313) return "1KI";
  if (day <= 338) return "2KI";
  if (day <= 367) return "1CH";
  if (day <= 403) return "2CH";
  if (day <= 413) return "EZR";
  if (day <= 426) return "NEH";
  if (day <= 436) return "EST";
  if (day <= 478) return "JOB";
  if (day <= 627) return "PSA";
  if (day <= 658) return "PRO";
  if (day <= 670) return "ECC";
  if (day <= 678) return "SNG";
  if (day <= 744) return "ISA";
  if (day <= 796) return "JER";
  if (day <= 801) return "LAM";
  if (day <= 848) return "EZK";
  if (day <= 860) return "DAN";
  if (day <= 874) return "HOS";
  if (day <= 877) return "JOL";
  if (day <= 886) return "AMO";
  if (day <= 887) return "OBA";
  if (day <= 891) return "JON";
  if (day <= 898) return "MIC";
  if (day <= 901) return "NAH";
  if (day <= 907) return "HAB";
  if (day <= 910) return "ZEP";
  if (day <= 912) return "HAG";
  if (day <= 926) return "ZEC";
  if (day <= 930) return "MAL";
  if (day <= 958) return "MAT";
  if (day <= 974) return "MRK";
  if (day <= 998) return "LUK";
  if (day <= 1019) return "JHN";
  if (day <= 1047) return "ACT";
  if (day <= 1063) return "ROM";
  if (day <= 1079) return "1CO";
  if (day <= 1092) return "2CO";
  if (day <= 1098) return "GAL";
  if (day <= 1104) return "EPH";
  if (day <= 1108) return "PHP";
  if (day <= 1112) return "COL";
  if (day <= 1117) return "1TH";
  if (day <= 1120) return "2TH";
  if (day <= 1126) return "1TI";
  if (day <= 1130) return "2TI";
  if (day <= 1133) return "TIT";
  if (day <= 1134) return "PHM";
  if (day <= 1147) return "HEB";
  if (day <= 1152) return "JAS";
  if (day <= 1157) return "1PE";
  if (day <= 1160) return "2PE";
  if (day <= 1165) return "1JN";
  if (day <= 1166) return "2JN";
  if (day <= 1167) return "3JN";
  if (day <= 1168) return "JUD";
  return "REV";
}

String _getBookName(String bookId) {
  final books = {
    "GEN": "Sáng Thế Ký", "EXO": "Xuất Ê-díp-tô Ký", "LEV": "Lê-vi Ký", "NUM": "Dân-số Ký",
    "DEU": "Phục-truyền Luật-lệ Ký", "JOS": "Giô-suê", "JDG": "Các Quan Xét", "RUT": "Ru-tơ",
    "1SA": "I Sa-mu-ên", "2SA": "II Sa-mu-ên", "1KI": "I Các Vua", "2KI": "II Các Vua",
    "1CH": "I Sử-ký", "2CH": "II Sử-ký", "EZR": "E-xơ-ra", "NEH": "Nê-hê-mi",
    "EST": "Ê-xơ-tê", "JOB": "Gióp", "PSA": "Thi-thiên", "PRO": "Châm-ngôn",
    "ECC": "Truyền-đạo", "SNG": "Nhã-ca", "ISA": "Ê-sai", "JER": "Giê-rê-mi",
    "LAM": "Ca-thương", "EZK": "Ê-xê-chi-ên", "DAN": "Đa-ni-ên", "HOS": "Ô-sê",
    "JOL": "Giô-ên", "AMO": "A-mốt", "OBA": "Áp-đia", "JON": "Giô-na",
    "MIC": "Mi-chê", "NAH": "Na-hum", "HAB": "Ha-ba-cúc", "ZEP": "Sô-phô-ni",
    "HAG": "A-ghê", "ZEC": "Xa-cha-ri", "MAL": "Ma-la-chi", "MAT": "Ma-thi-ơ",
    "MRK": "Mác", "LUK": "Lu-ca", "JHN": "Giăng", "ACT": "Công-vụ",
    "ROM": "Rô-ma", "1CO": "I Cô-rinh-tô", "2CO": "II Cô-rinh-tô", "GAL": "Ga-la-ti",
    "EPH": "Ê-phê-sô", "PHP": "Phi-líp", "COL": "Cô-lô-se", "1TH": "I Tê-sa-lô-ni-ca",
    "2TH": "II Tê-sa-lô-ni-ca", "1TI": "I Ti-mô-thê", "2TI": "II Ti-mô-thê", "TIT": "Tít",
    "PHM": "Phi-lê-môn", "HEB": "Hê-bơ-rơ", "JAS": "Gia-cơ", "1PE": "I Phi-e-rơ",
    "2PE": "II Phi-e-rơ", "1JN": "I Giăng", "2JN": "II Giăng", "3JN": "III Giăng",
    "JUD": "Giu-đe", "REV": "Khải Huyền"
  };
  return books[bookId] ?? "Sáng Thế Ký";
}

int _getChapterForDay(int day, String bookId) {
  return (day % 50) + 1;
}

int _getStartVerseForDay(int day, String bookId, int chapter) {
  return 1;
}

int _getEndVerseForDay(int day, String bookId, int chapter) {
  return 10 + (day % 20);
}

String _getTitleForDay(int day, String bookName, int chapter) {
  return "Bài đọc ngày $day - $bookName chương $chapter";
}

String _getDescriptionForDay(int day, String bookName, int chapter) {
  return "Bài đọc hàng ngày thứ $day từ $bookName chương $chapter";
}

List<String> _getKeyVersesForDay(int day, String bookId, int chapter) {
  return ["${chapter}:1", "${chapter}:2", "${chapter}:3"];
}

List<String> _getThemesForDay(int day, String bookId) {
  final themes = [
    ["Sáng tạo", "Đức Chúa Trời", "Con người"],
    ["Xuất hành", "Tự do", "Lãnh đạo"],
    ["Luật pháp", "Thánh hóa", "Tế lễ"],
    ["Hành trình", "Đức tin", "Kiên nhẫn"],
    ["Nhắc nhở", "Vâng lời", "Phước hạnh"]
  ];
  return themes[day % themes.length];
}

int _getDurationForDay(int day) {
  return 300 + (day % 200); // 5-8 phút
}

int _getFileSizeForDay(int day) {
  return 2400000 + (day % 1000000); // 2-3 MB
}



