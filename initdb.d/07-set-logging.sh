#!/bin/bash
set -e 

echo "log_statement = 'none'" >> /var/lib/postgresql/data/postgresql.conf
echo "log_min_messages = 'notice'" >> /var/lib/postgresql/data/postgresql.conf
echo "log_min_error_statement = 'notice'" >> /var/lib/postgresql/data/postgresql.conf
