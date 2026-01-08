#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../"
set -a; source .env; set +a

HASH='$2b$10$H7.AsBWceEadamuN6ixp0OW2nnNDVGCCnBt3xbPNDMbrct43neDhe' # bcrypt('dev')

psql -X "$DATABASE_URL" -c "
UPDATE \"User\"
SET \"password\" = '$HASH'
WHERE email IN (
  'admin@classmate.app',
  'teacher1@classmate.app',
  'student1@classmate.app',
  'parent1@classmate.app'
);
"
echo "✅ fixed dev passwords (password=dev)"
