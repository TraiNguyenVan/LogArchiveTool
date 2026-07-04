# Log Archive Tool

> Project from [roadmap.sh](https://roadmap.sh/projects/log-archive-tool)

A CLI tool to archive logs by compressing them into timestamped tar.gz archives with activity logging.

## Features

| Feature | Description |
|---------|-------------|
| Log Compression | Compresses log directories into `.tar.gz` archives |
| Timestamped Archives | Auto-generates archive names with date and time |
| Activity Logging | Records all archive operations to `archive.log` |
| Input Validation | Checks for valid directory before archiving |
| Error Handling | Exits with clear messages on failure |

## Quick Start

```bash
git clone https://github.com/<your-username>/LogArchiveTool.git
cd LogArchiveTool
chmod +x log-archive.sh
./log-archive.sh /var/log
```

## Example Output

```console
$ ./log-archive.sh /var/log
Archive created: /home/user/LogArchiveTool/log_archives/logs_archive_20260704_143022.tar.gz

$ cat log_archives/archive.log
2026-07-04 14:30:22 - Archived '/var/log' to '/home/user/LogArchiveTool/log_archives/logs_archive_20260704_143022.tar.gz'
```

## Commands Used

| Command | Purpose | Docs |
|---------|---------|------|
| `tar` | Compress directory into `.tar.gz` archive | [GNU Tar Manual](https://www.gnu.org/software/tar/manual/) |
| `date` | Generate timestamp for archive naming | [GNU Coreutils](https://www.gnu.org/software/coreutils/manual/coreutils.html) |
| `mkdir` | Create log_archives directory if missing | [GNU Coreutils](https://www.gnu.org/software/coreutils/manual/coreutils.html) |

## License

[MIT](LICENSE)
