import 'dart:io';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MigrationRunner {
  static const String _databaseName = 'bible_app.db';
  static const int _databaseVersion = 1;

  // Run all migrations
  static Future<void> runMigrations() async {
    try {
      print('🚀 Starting Database Migrations...\n');
      
      // Get database path
      String path = join(await getDatabasesPath(), _databaseName);
      
      // Open database
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      // Run migrations
      await _runMigration001(db);
      await _runMigration002(db);
      await _runMigration003(db);
      
      await db.close();
      
      print('\n✅ All migrations completed successfully!');
    } catch (e) {
      print('❌ Migration failed: $e');
    }
  }

  // Create database and run initial migration
  static Future<void> _onCreate(Database db, int version) async {
    print('📝 Creating database...');
    await _runMigration001(db);
    await _runMigration002(db);
    await _runMigration003(db);
  }

  // Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion...');
    
    if (oldVersion < 1) {
      await _runMigration001(db);
    }
    if (oldVersion < 2) {
      await _runMigration002(db);
    }
    if (oldVersion < 3) {
      await _runMigration003(db);
    }
  }

  // Migration 001: Create tables
  static Future<void> _runMigration001(Database db) async {
    try {
      print('📋 Running Migration 001: Create Tables...');
      
      // Read migration file
      final migrationFile = File('migrations/001_create_tables.sql');
      if (await migrationFile.exists()) {
        final sql = await migrationFile.readAsString();
        
        // Split by semicolon and execute each statement
        final statements = sql.split(';').where((s) => s.trim().isNotEmpty);
        
        for (final statement in statements) {
          if (statement.trim().isNotEmpty) {
            await db.execute(statement.trim());
          }
        }
        
        print('✅ Migration 001 completed: Tables created');
      } else {
        print('❌ Migration file 001_create_tables.sql not found');
      }
    } catch (e) {
      print('❌ Migration 001 failed: $e');
    }
  }

  // Migration 002: Seed Bible Books
  static Future<void> _runMigration002(Database db) async {
    try {
      print('📚 Running Migration 002: Seed Bible Books...');
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM bible_books'));
      if (count != null && count > 0) {
        print('ℹ️ Bible books already seeded, skipping...');
        return;
      }
      
      // Read migration file
      final migrationFile = File('migrations/002_seed_bible_books.sql');
      if (await migrationFile.exists()) {
        final sql = await migrationFile.readAsString();
        
        // Split by semicolon and execute each statement
        final statements = sql.split(';').where((s) => s.trim().isNotEmpty);
        
        for (final statement in statements) {
          if (statement.trim().isNotEmpty) {
            await db.execute(statement.trim());
          }
        }
        
        print('✅ Migration 002 completed: Bible books seeded');
      } else {
        print('❌ Migration file 002_seed_bible_books.sql not found');
      }
    } catch (e) {
      print('❌ Migration 002 failed: $e');
    }
  }

  // Migration 003: Seed Daily Readings
  static Future<void> _runMigration003(Database db) async {
    try {
      print('📖 Running Migration 003: Seed Daily Readings...');
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM daily_readings'));
      if (count != null && count > 0) {
        print('ℹ️ Daily readings already seeded, skipping...');
        return;
      }
      
      // Read migration file
      final migrationFile = File('migrations/003_seed_daily_readings.sql');
      if (await migrationFile.exists()) {
        final sql = await migrationFile.readAsString();
        
        // Split by semicolon and execute each statement
        final statements = sql.split(';').where((s) => s.trim().isNotEmpty);
        
        for (final statement in statements) {
          if (statement.trim().isNotEmpty) {
            await db.execute(statement.trim());
          }
        }
        
        print('✅ Migration 003 completed: Daily readings seeded');
      } else {
        print('❌ Migration file 003_seed_daily_readings.sql not found');
      }
    } catch (e) {
      print('❌ Migration 003 failed: $e');
    }
  }

  // Check migration status
  static Future<void> checkMigrationStatus() async {
    try {
      print('🔍 Checking Migration Status...\n');
      
      String path = join(await getDatabasesPath(), _databaseName);
      final db = await openDatabase(path);
      
      // Check tables
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      print('📋 Tables in database:');
      for (final table in tables) {
        print('   - ${table['name']}');
      }
      
      // Check data counts
      final bibleBooksCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM bible_books'));
      final dailyReadingsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM daily_readings'));
      final usersCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
      
      print('\n📊 Data counts:');
      print('   - Bible books: $bibleBooksCount');
      print('   - Daily readings: $dailyReadingsCount');
      print('   - Users: $usersCount');
      
      await db.close();
    } catch (e) {
      print('❌ Failed to check migration status: $e');
    }
  }
}
