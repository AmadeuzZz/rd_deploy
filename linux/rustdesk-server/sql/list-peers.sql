SELECT
  id,
  created_at,
  replace(json_extract(info, '$.ip'), '::ffff:', '') AS ip,
  info
FROM peer
ORDER BY created_at DESC;
