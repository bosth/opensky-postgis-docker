#!/bin/bash
set -e 

echo "log_statement = 'none'" >> /var/lib/postgresql/data/postgresql.conf
echo "log_min_messages = 'info'" >> /var/lib/postgresql/data/postgresql.conf
echo "log_min_error_statement = 'info'" >> /var/lib/postgresql/data/postgresql.conf
