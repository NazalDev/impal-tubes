BEGIN;

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE event_status        AS ENUM ('draft', 'published', 'cancelled');
CREATE TYPE registration_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');
CREATE TYPE operation_type      AS ENUM ('INSERT', 'UPDATE', 'DELETE');


-- ============================================================
-- TABLE: public."user"
--
-- id is UUID and references auth.users(id) — Supabase's auth
-- table lives in the "auth" schema and is managed by Supabase.
-- We do NOT store password here; auth.users handles that.
-- username is pulled from raw_user_meta_data passed at signUp:
--   supabase.auth.signUp({ email, password,
--     options: { data: { username: 'john' } } })
-- ============================================================

CREATE TABLE public."user" (
  id          UUID         PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username    VARCHAR(100) NOT NULL UNIQUE,
  email       VARCHAR(255) NOT NULL UNIQUE,
  role 		  VARCHAR(255) NOT NULL DEFAULT 'Pengguna',
  avatar_url  TEXT DEFAULT 'default',
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow auth trigger insert"
  ON public."user" FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view own row"
  ON public."user" FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own row"
  ON public."user" FOR UPDATE USING (auth.uid() = id);


-- ============================================================
-- TRIGGER: auto-insert into public."user" whenever a new user
--          is created in auth.users (every successful sign-up)
-- ============================================================

CREATE OR REPLACE FUNCTION public.fn_handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER          -- must run as owner to bypass RLS
SET search_path = public
AS $$
BEGIN
  INSERT INTO public."user" (id, username, email, created_at, updated_at)
  VALUES (
    NEW.id,
    -- username from signUp metadata; falls back to email prefix
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    NEW.email,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.fn_handle_new_user();


-- ============================================================
-- TABLE: event
-- user_id is UUID to match public."user".id
-- ============================================================

CREATE TABLE event (
  id          SERIAL PRIMARY KEY,
  user_id     UUID NOT NULL,
  title       VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  location    VARCHAR(255) DEFAULT NULL,
  start_at    TIMESTAMP DEFAULT NULL,
  end_at      TIMESTAMP DEFAULT NULL,
  status      event_status DEFAULT 'draft',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT event_ibfk_1 FOREIGN KEY (user_id) REFERENCES public."user" (id)
);


-- ============================================================
-- TABLE: registration
-- ============================================================

CREATE TABLE registration (
  id            SERIAL PRIMARY KEY,
  user_id       UUID NOT NULL,
  event_id      INT NOT NULL,
  status        registration_status DEFAULT 'pending',
  notes         TEXT DEFAULT NULL,
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT registration_ibfk_1 FOREIGN KEY (user_id)  REFERENCES public."user" (id),
  CONSTRAINT registration_ibfk_2 FOREIGN KEY (event_id) REFERENCES event (id) ON DELETE CASCADE
);


-- ============================================================
-- TABLE: postdisc
-- ============================================================

CREATE TABLE postdisc (
  id          SERIAL PRIMARY KEY,
  user_id     UUID NOT NULL,
  event_id    INT DEFAULT NULL,
  title       VARCHAR(255) NOT NULL,
  body        TEXT DEFAULT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT postdisc_ibfk_1 FOREIGN KEY (user_id)  REFERENCES public."user" (id),
  CONSTRAINT postdisc_ibfk_2 FOREIGN KEY (event_id) REFERENCES event (id) ON DELETE SET NULL
);


-- ============================================================
-- TABLE: replydisc
-- ============================================================

CREATE TABLE replydisc (
  id          SERIAL PRIMARY KEY,
  post_id     INT NOT NULL,
  user_id     UUID NOT NULL,
  body        TEXT DEFAULT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT replydisc_ibfk_1 FOREIGN KEY (post_id) REFERENCES postdisc (id) ON DELETE CASCADE,
  CONSTRAINT replydisc_ibfk_2 FOREIGN KEY (user_id) REFERENCES public."user" (id)
);


-- ============================================================
-- TABLE: log
-- ============================================================

CREATE TABLE log (
  id          SERIAL PRIMARY KEY,
  user_id     UUID DEFAULT NULL,
  action      VARCHAR(100) DEFAULT NULL,
  ip_address  VARCHAR(45) DEFAULT NULL,
  logged_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT log_ibfk_1 FOREIGN KEY (user_id) REFERENCES public."user" (id) ON DELETE SET NULL
);


-- ============================================================
-- HISTORY TABLES (user_id / changed_by are now UUID)
-- ============================================================

CREATE TABLE histevent (
  hist_id     SERIAL PRIMARY KEY,
  operation   operation_type NOT NULL,
  changed_by  UUID DEFAULT NULL,
  changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id          INT DEFAULT NULL,
  user_id     UUID DEFAULT NULL,
  title       VARCHAR(255) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  location    VARCHAR(255) DEFAULT NULL,
  start_at    TIMESTAMP DEFAULT NULL,
  end_at      TIMESTAMP DEFAULT NULL,
  status      VARCHAR(20) DEFAULT NULL,
  created_at  TIMESTAMP DEFAULT NULL,
  updated_at  TIMESTAMP DEFAULT NULL
);

CREATE TABLE histpost (
  hist_id     SERIAL PRIMARY KEY,
  operation   operation_type NOT NULL,
  changed_by  UUID DEFAULT NULL,
  changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id          INT DEFAULT NULL,
  user_id     UUID DEFAULT NULL,
  event_id    INT DEFAULT NULL,
  title       VARCHAR(255) DEFAULT NULL,
  body        TEXT DEFAULT NULL,
  created_at  TIMESTAMP DEFAULT NULL,
  updated_at  TIMESTAMP DEFAULT NULL
);

CREATE TABLE histreg (
  hist_id       SERIAL PRIMARY KEY,
  operation     operation_type NOT NULL,
  changed_by    UUID DEFAULT NULL,
  changed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id            INT DEFAULT NULL,
  user_id       UUID DEFAULT NULL,
  event_id      INT DEFAULT NULL,
  status        VARCHAR(20) DEFAULT NULL,
  notes         TEXT DEFAULT NULL,
  registered_at TIMESTAMP DEFAULT NULL,
  updated_at    TIMESTAMP DEFAULT NULL
);

CREATE TABLE histreply (
  hist_id     SERIAL PRIMARY KEY,
  operation   operation_type NOT NULL,
  changed_by  UUID DEFAULT NULL,
  changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id          INT DEFAULT NULL,
  post_id     INT DEFAULT NULL,
  user_id     UUID DEFAULT NULL,
  body        TEXT DEFAULT NULL,
  created_at  TIMESTAMP DEFAULT NULL,
  updated_at  TIMESTAMP DEFAULT NULL
);

CREATE TABLE histuser (
  hist_id     SERIAL PRIMARY KEY,
  operation   operation_type NOT NULL,
  changed_by  UUID DEFAULT NULL,
  changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id          UUID DEFAULT NULL,
  username    VARCHAR(100) DEFAULT NULL,
  email       VARCHAR(255) DEFAULT NULL,
  created_at  TIMESTAMP DEFAULT NULL,
  updated_at  TIMESTAMP DEFAULT NULL
);


-- ============================================================
-- AUTO-UPDATE updated_at TRIGGER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_updated_at
  BEFORE UPDATE ON public."user"
  FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TRIGGER trg_event_updated_at
  BEFORE UPDATE ON event
  FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TRIGGER trg_registration_updated_at
  BEFORE UPDATE ON registration
  FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TRIGGER trg_postdisc_updated_at
  BEFORE UPDATE ON postdisc
  FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TRIGGER trg_replydisc_updated_at
  BEFORE UPDATE ON replydisc
  FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- ============================================================
-- TRIGGERS: user history
-- (password removed — auth.users owns that now)
-- ============================================================

CREATE OR REPLACE FUNCTION fn_histuser_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histuser (operation, changed_by, id, username, email, created_at, updated_at)
  VALUES ('INSERT', NEW.id, NEW.id, NEW.username, NEW.email, NEW.created_at, NEW.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histuser_update()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histuser (operation, changed_by, id, username, email, created_at, updated_at)
  VALUES ('UPDATE', NEW.id, OLD.id, OLD.username, OLD.email, OLD.created_at, OLD.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histuser_delete()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histuser (operation, changed_by, id, username, email, created_at, updated_at)
  VALUES ('DELETE', OLD.id, OLD.id, OLD.username, OLD.email, OLD.created_at, OLD.updated_at);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_after_insert
  AFTER INSERT ON public."user"
  FOR EACH ROW EXECUTE FUNCTION fn_histuser_insert();

CREATE TRIGGER trg_user_after_update
  AFTER UPDATE ON public."user"
  FOR EACH ROW EXECUTE FUNCTION fn_histuser_update();

CREATE TRIGGER trg_user_after_delete
  AFTER DELETE ON public."user"
  FOR EACH ROW EXECUTE FUNCTION fn_histuser_delete();


-- ============================================================
-- TRIGGERS: event history
-- ============================================================

CREATE OR REPLACE FUNCTION fn_histevent_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histevent (operation, changed_by, id, user_id, title, description, location, start_at, end_at, status, created_at, updated_at)
  VALUES ('INSERT', NEW.user_id, NEW.id, NEW.user_id, NEW.title, NEW.description, NEW.location, NEW.start_at, NEW.end_at, NEW.status::VARCHAR, NEW.created_at, NEW.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histevent_update()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histevent (operation, changed_by, id, user_id, title, description, location, start_at, end_at, status, created_at, updated_at)
  VALUES ('UPDATE', NEW.user_id, OLD.id, OLD.user_id, OLD.title, OLD.description, OLD.location, OLD.start_at, OLD.end_at, OLD.status::VARCHAR, OLD.created_at, OLD.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histevent_delete()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histevent (operation, changed_by, id, user_id, title, description, location, start_at, end_at, status, created_at, updated_at)
  VALUES ('DELETE', OLD.user_id, OLD.id, OLD.user_id, OLD.title, OLD.description, OLD.location, OLD.start_at, OLD.end_at, OLD.status::VARCHAR, OLD.created_at, OLD.updated_at);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_event_after_insert
  AFTER INSERT ON event
  FOR EACH ROW EXECUTE FUNCTION fn_histevent_insert();

CREATE TRIGGER trg_event_after_update
  AFTER UPDATE ON event
  FOR EACH ROW EXECUTE FUNCTION fn_histevent_update();

CREATE TRIGGER trg_event_after_delete
  AFTER DELETE ON event
  FOR EACH ROW EXECUTE FUNCTION fn_histevent_delete();


-- ============================================================
-- TRIGGERS: registration history
-- ============================================================

CREATE OR REPLACE FUNCTION fn_histreg_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histreg (operation, changed_by, id, user_id, event_id, status, notes, registered_at, updated_at)
  VALUES ('INSERT', NEW.user_id, NEW.id, NEW.user_id, NEW.event_id, NEW.status::VARCHAR, NEW.notes, NEW.registered_at, NEW.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histreg_update()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histreg (operation, changed_by, id, user_id, event_id, status, notes, registered_at, updated_at)
  VALUES ('UPDATE', NEW.user_id, OLD.id, OLD.user_id, OLD.event_id, OLD.status::VARCHAR, OLD.notes, OLD.registered_at, OLD.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histreg_delete()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histreg (operation, changed_by, id, user_id, event_id, status, notes, registered_at, updated_at)
  VALUES ('DELETE', OLD.user_id, OLD.id, OLD.user_id, OLD.event_id, OLD.status::VARCHAR, OLD.notes, OLD.registered_at, OLD.updated_at);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_registration_after_insert
  AFTER INSERT ON registration
  FOR EACH ROW EXECUTE FUNCTION fn_histreg_insert();

CREATE TRIGGER trg_registration_after_update
  AFTER UPDATE ON registration
  FOR EACH ROW EXECUTE FUNCTION fn_histreg_update();

CREATE TRIGGER trg_registration_after_delete
  AFTER DELETE ON registration
  FOR EACH ROW EXECUTE FUNCTION fn_histreg_delete();


-- ============================================================
-- TRIGGERS: postdisc history
-- ============================================================

CREATE OR REPLACE FUNCTION fn_histpost_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histpost (operation, changed_by, id, user_id, event_id, title, body, created_at, updated_at)
  VALUES ('INSERT', NEW.user_id, NEW.id, NEW.user_id, NEW.event_id, NEW.title, NEW.body, NEW.created_at, NEW.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histpost_update()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histpost (operation, changed_by, id, user_id, event_id, title, body, created_at, updated_at)
  VALUES ('UPDATE', NEW.user_id, OLD.id, OLD.user_id, OLD.event_id, OLD.title, OLD.body, OLD.created_at, OLD.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histpost_delete()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histpost (operation, changed_by, id, user_id, event_id, title, body, created_at, updated_at)
  VALUES ('DELETE', OLD.user_id, OLD.id, OLD.user_id, OLD.event_id, OLD.title, OLD.body, OLD.created_at, OLD.updated_at);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_postdisc_after_insert
  AFTER INSERT ON postdisc
  FOR EACH ROW EXECUTE FUNCTION fn_histpost_insert();

CREATE TRIGGER trg_postdisc_after_update
  AFTER UPDATE ON postdisc
  FOR EACH ROW EXECUTE FUNCTION fn_histpost_update();

CREATE TRIGGER trg_postdisc_after_delete
  AFTER DELETE ON postdisc
  FOR EACH ROW EXECUTE FUNCTION fn_histpost_delete();


-- ============================================================
-- TRIGGERS: replydisc history
-- ============================================================

CREATE OR REPLACE FUNCTION fn_histreply_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histreply (operation, changed_by, id, post_id, user_id, body, created_at, updated_at)
  VALUES ('INSERT', NEW.user_id, NEW.id, NEW.post_id, NEW.user_id, NEW.body, NEW.created_at, NEW.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histreply_update()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histreply (operation, changed_by, id, post_id, user_id, body, created_at, updated_at)
  VALUES ('UPDATE', NEW.user_id, OLD.id, OLD.post_id, OLD.user_id, OLD.body, OLD.created_at, OLD.updated_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_histreply_delete()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO histreply (operation, changed_by, id, post_id, user_id, body, created_at, updated_at)
  VALUES ('DELETE', OLD.user_id, OLD.id, OLD.post_id, OLD.user_id, OLD.body, OLD.created_at, OLD.updated_at);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_replydisc_after_insert
  AFTER INSERT ON replydisc
  FOR EACH ROW EXECUTE FUNCTION fn_histreply_insert();

CREATE TRIGGER trg_replydisc_after_update
  AFTER UPDATE ON replydisc
  FOR EACH ROW EXECUTE FUNCTION fn_histreply_update();

CREATE TRIGGER trg_replydisc_after_delete
  AFTER DELETE ON replydisc
  FOR EACH ROW EXECUTE FUNCTION fn_histreply_delete();


COMMIT;
