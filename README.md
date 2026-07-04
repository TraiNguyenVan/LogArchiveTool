# LogArchiveTool

> Project from [roadmap.sh](https://roadmap.sh/projects/log-archive-tool)

A bash utility that compresses log directories into timestamped `.tar.gz` archives with optional email notifications via SMTP.

## Features

| Feature | Description |
|---------|-------------|
| Timestamped archives | Automatically names archives with `YYYYMMDD_HHMMSS` format |
| Archive logging | Keeps a running log of all archives created in `archive.log` |
| Email notifications | Sends archive summary via SMTP (using Python's built-in `smtplib`) |
| Authenticated SMTP | Supports TLS, username/password login for services like Gmail |
| Graceful error handling | Warns on email failure without aborting the archive operation |

## Quick Start

```bash
git clone https://github.com/TraiNguyenVan/LogArchiveTool.git
cd LogArchiveTool
chmod +x log-archive.sh
```

No dependencies required — uses only standard bash, `tar`, `date`, and Python3 (built-in `smtplib`).

## Usage

```bash
# Basic archive
./log-archive.sh /var/log

# Archive with email notification
./log-archive.sh /var/log -e admin@example.com --from noreply@example.com

# With authenticated SMTP (e.g., Gmail)
SMTP_HOST=smtp.gmail.com SMTP_PORT=587 SMTP_USER=me@gmail.com SMTP_PASS=secret \
  ./log-archive.sh /var/log -e admin@example.com --from me@gmail.com
```

### Options

| Flag | Description |
|------|-------------|
| `-e <email>` | Send archive notification to this email address |
| `--from <sender>` | Sender email address (required with `-e`) |
| `-h`, `--help` | Show usage information |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SMTP_HOST` | `localhost` | SMTP server hostname |
| `SMTP_PORT` | `25` | SMTP server port |
| `SMTP_USER` | *(empty)* | SMTP username for auth |
| `SMTP_PASS` | *(empty)* | SMTP password for auth |

## Example Output

```console
$ ./log-archive.sh /tmp/testlogs
Archive created: /home/user/LogArchiveTool/log_archives/logs_archive_20260704_123900.tar.gz (4.0K)

$ ./log-archive.sh /tmp/testlogs -e admin@example.com --from noreply@example.com
Archive created: /home/user/LogArchiveTool/log_archives/logs_archive_20260704_123907.tar.gz (4.0K)
Warning: Failed to send email: [Errno 111] Connection refused
```

## Commands Used

| Command | Purpose | Docs |
|---------|---------|------|
| `tar -czf` | Create gzip-compressed archive | [GNU Tar Manual](https://www.gnu.org/software/tar/manual/tar.html) |
| `date` | Generate timestamps for filenames and logs | [GNU Coreutils](https://www.gnu.org/software/coreutils/manual/coreutils.html) |
| `du -h` | Report archive file size | [GNU Coreutils](https://www.gnu.org/software/coreutils/manual/coreutils.html) |
| `python3 -c smtplib` | Send email via SMTP (stdlib) | [Python smtplib docs](https://docs.python.org/3/library/smtplib.html) |

## License

[MIT](LICENSE)
