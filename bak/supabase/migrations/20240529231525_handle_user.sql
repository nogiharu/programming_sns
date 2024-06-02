
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
    -- 新しいユーザーの user_id を生成
    -- BEFORE INSERTでpublic.usersの挿入が失敗したら、auth.usersへの挿入も失敗させたいが、
    -- auth.usersのidが採番されていないため、AFTER INSERTにしないといけない
    DECLARE
        new_user_id TEXT := SPLIT_PART(NEW.email, '@', 1);
    BEGIN
        -- 新しいユーザーを public.users テーブルに挿入
        INSERT INTO public.users (id, user_id)
        VALUES (NEW.id, new_user_id);
        RETURN NEW;
    END;
$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."handle_update_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
    BEGIN
        IF OLD.email_change != NEW.email_change THEN
            -- 新しいユーザーの user_id を生成
            DECLARE
                new_user_id TEXT := SPLIT_PART(NEW.email_change, '@', 1);
            BEGIN
                -- 新しいユーザーを public.users テーブルに更新
                UPDATE public.users
                SET user_id = new_user_id
                WHERE id = NEW.id;
                -- メール更新
                NEW.email = NEW.email_change;
            END;
        END IF;

        RETURN NEW;
    END;
$$;

ALTER FUNCTION "public"."handle_update_user"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."handle_users"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    ------------------------【UPDATEトリガー】------------------------
    IF TG_OP = 'UPDATE' THEN
        -- updated_atを自動アップデートを処理する
        NEW.updated_at = TIMEZONE('utc'::TEXT, NOW());
    ------------------------【INSERTトリガー】------------------------
    ELSIF TG_OP = 'INSERT' THEN

    END IF;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."handle_users"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "user_id" "text" NOT NULL,
    "name" character varying DEFAULT '名前はまだない'::character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "profile_photo" character varying,
    "is_deleted" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."users" OWNER TO "postgres";

COMMENT ON TABLE "public"."users" IS 'ユーザー名などのユーザー情報を保持する';

COMMENT ON COLUMN "public"."users"."id" IS '固有ID';

COMMENT ON COLUMN "public"."users"."user_id" IS 'メンションやログインに使用。変更可';

COMMENT ON COLUMN "public"."users"."name" IS '名前';

COMMENT ON COLUMN "public"."users"."created_at" IS 'レコード作成日時';

COMMENT ON COLUMN "public"."users"."updated_at" IS 'レコード更新日時';

COMMENT ON COLUMN "public"."users"."profile_photo" IS 'プロフィール写真のパスを保存するカラム';

COMMENT ON COLUMN "public"."users"."is_deleted" IS '削除フラグ (true: 削除済み, false: 未削除)';

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");

CREATE INDEX "idx_users_user_id" ON "public"."users" USING "btree" ("user_id");

CREATE OR REPLACE TRIGGER "handle_user_trigger" BEFORE INSERT OR UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_users"();

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");

ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_update_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_update_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_update_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_users"() TO "service_role";

GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;

--
-- Dumped schema changes for auth and storage
--

CREATE OR REPLACE TRIGGER "handle_new_user_trigger" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();

CREATE OR REPLACE TRIGGER "handle_update_user_trigger" BEFORE UPDATE ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_update_user"();

