# Exercise 10: Database Backup

## Objective
Create an automated database backup script supporting multiple database types.

## Requirements
1. Support MySQL, PostgreSQL, SQLite databases
2. Create compressed backups
3. Implement backup rotation
4. Support remote database connections
5. Generate backup reports
6. Handle backup verification
7. Support incremental backups
8. Email notifications on success/failure

## Usage Examples
```bash
bash db_backup.sh --type mysql --db myapp --user admin
bash db_backup.sh --type postgres --db webapp --host remote.server
bash db_backup.sh --type sqlite --file /path/to/db.sqlite
bash db_backup.sh --config backup.conf --rotate 7
bash db_backup.sh --verify backup_20240115.sql.gz
```

## Features to Implement
- Multiple database support
- Compression and encryption
- Backup verification
- Rotation policies
- Remote backup storage
- Notification system
- Configuration files
- Logging and reporting

## Test Cases
1. Backup MySQL database
2. Backup PostgreSQL database
3. Backup SQLite file
4. Test backup verification
5. Test rotation policy