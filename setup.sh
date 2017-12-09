#!/usr/bin/env bash

bundle
sqlite3 lib/database < schema.sql
