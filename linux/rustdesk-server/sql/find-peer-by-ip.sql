-- Replace IP below.
SELECT
  id,
  created_at,
  replace(json_extract(info, '$.ip'), '::ffff:', '') AS ip,
  info
FROM peer
WHERE replace(json_extract(info, '$.ip'), '::ffff:', '') = 'CLIENT_IP'
ORDER BY created_at DESC;
