--Create tables for scheduler app

DROP TABLE IF EXISTS event CASCADE;
DROP TABLE IF EXISTS participant CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS relationship CASCADE;

CREATE TABLE IF NOT EXISTS event (
  id            bigserial PRIMARY KEY,
  start_time    timestamp NOT NULL,    -- UTC
  end_time      timestamp NOT NULL,    -- UTC
  name          varchar(120),
  type          varchar(20),
  notes         text
);

CREATE TABLE IF NOT EXISTS person (
  id            bigserial PRIMARY KEY,
  first_name    varchar(120),
  last_name     varchar(120),
  client        boolean NOT NULL DEFAULT False,
  coach         boolean NOT NULL DEFAULT False
);

CREATE TABLE IF NOT EXISTS participant (
  event_id      integer NOT NULL REFERENCES event (id) ON DELETE CASCADE,
  person_id     integer NOT NULL REFERENCES person (id) ON DELETE CASCADE,
  CONSTRAINT participant_constraint UNIQUE (event_id,person_id)
);

CREATE TABLE IF NOT EXISTS relationship (
  coach_id      integer NOT NULL REFERENCES person (id) ON DELETE CASCADE,
  client_id     integer NOT NULL REFERENCES person (id) ON DELETE CASCADE,
  since         timestamp    -- UTC
);

DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_user
      WHERE  usename = 'scheduler_app') THEN

      CREATE USER scheduler_app WITH password 'notarealpassword!';
   END IF;
END
$body$;

GRANT all privileges ON database scheduler to scheduler_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON all tables IN schema public TO scheduler_app;
GRANT ALL PRIVILEGES ON all sequences IN schema public TO scheduler_app;

