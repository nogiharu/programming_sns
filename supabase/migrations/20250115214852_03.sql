
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

CREATE OR REPLACE FUNCTION "public"."after_auth"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    ------------------------【INSERTトリガー】------------------------
    IF TG_OP = 'INSERT' THEN
        -- 新しいユーザーの user_id を生成
        DECLARE
            new_mention_id TEXT := NEW.raw_user_meta_data->>'userId';
        BEGIN
            -- 新しいユーザーを public.users テーブルに挿入
            INSERT INTO public.users (id, mention_id)
            VALUES (NEW.id, new_mention_id);
        END;
    ------------------------【UPDATEトリガー】------------------------
    ELSIF TG_OP = 'UPDATE' THEN
        IF (OLD.raw_user_meta_data->>'userId') != (NEW.raw_user_meta_data->>'userId') THEN
            -- 新しいユーザーの user_id を生成
            DECLARE
                new_user_id TEXT := NEW.raw_user_meta_data->>'userId';
            BEGIN
                -- 新しいユーザーを public.users テーブルに更新
                UPDATE public.users
                SET mention_id = new_user_id
                WHERE id = NEW.id;

                NEW.email = NEW.email_change;
            END;
        END IF;
    ------------------------【DELETEトリガー】------------------------
    ELSIF TG_OP = 'DELETE' THEN
        -- ユーザーを削除としてマーク
        UPDATE public.users
        SET is_deleted = TRUE
        WHERE id = OLD.id;

        RETURN NULL;
    END IF;
    
    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."after_auth"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."after_messages"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    ------------------------【UPDATE OR INSERTトリガー】------------------------
        -- チャットルームの日付も更新
        UPDATE public.chat_rooms
        SET updated_at = TIMEZONE('utc', NOW())
        WHERE id = NEW.chat_room_id;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."after_messages"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "send_by_user_id" "uuid" NOT NULL,
    "chat_room_id" "uuid" NOT NULL,
    "message" character varying(2000) NOT NULL,
    "message_type" "text" NOT NULL,
    "reactions" "jsonb",
    "reply_to" "jsonb",
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "read_user_ids" "text"[],
    CONSTRAINT "valid_reply_to" CHECK ((("reply_to" IS NULL) OR (("reply_to" ? 'message_id'::"text") AND ("jsonb_typeof"(("reply_to" -> 'message_id'::"text")) = 'string'::"text") AND ("reply_to" ? 'user_id'::"text") AND ("jsonb_typeof"(("reply_to" -> 'user_id'::"text")) = 'string'::"text") AND ("reply_to" ? 'message_type'::"text") AND ("jsonb_typeof"(("reply_to" -> 'message_type'::"text")) = 'string'::"text") AND ("reply_to" ? 'message'::"text") AND ("jsonb_typeof"(("reply_to" -> 'message'::"text")) = 'string'::"text"))))
);

ALTER TABLE "public"."messages" OWNER TO "postgres";

COMMENT ON TABLE "public"."messages" IS 'アプリ内で送られたチャットを保持する';

COMMENT ON COLUMN "public"."messages"."id" IS 'メッセージIDを主キーとして設定 (UUIDを自動生成)';

COMMENT ON COLUMN "public"."messages"."send_by_user_id" IS 'ユーザー固有のIDを設定';

COMMENT ON COLUMN "public"."messages"."chat_room_id" IS 'チャットルームID';

COMMENT ON COLUMN "public"."messages"."message" IS 'メッセージ本文';

COMMENT ON COLUMN "public"."messages"."message_type" IS 'メッセージタイプ';

COMMENT ON COLUMN "public"."messages"."reactions" IS 'リアクション絵文字';

COMMENT ON COLUMN "public"."messages"."is_deleted" IS '消されたか';

COMMENT ON COLUMN "public"."messages"."created_at" IS 'レコード作成日時を設定 (UTCタイムゾーンで現在時刻)';

COMMENT ON COLUMN "public"."messages"."updated_at" IS 'レコード更新日時を設定 (UTCタイムゾーンで現在時刻)';

CREATE OR REPLACE FUNCTION "public"."send_user_messages"("user_id" "uuid") RETURNS SETOF "public"."messages"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT * 
    FROM (
        SELECT DISTINCT ON (chat_room_id) *
        FROM messages
        WHERE send_by_user_id = user_id
        ORDER BY chat_room_id, created_at DESC
    ) m
    ORDER BY m.created_at DESC;
END;
$$;

ALTER FUNCTION "public"."send_user_messages"("user_id" "uuid") OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."chat_categories" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" character varying(2000) NOT NULL,
    "parent_category" character varying(2000),
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);

ALTER TABLE "public"."chat_categories" OWNER TO "postgres";

COMMENT ON TABLE "public"."chat_categories" IS 'カテゴリ情報';

COMMENT ON COLUMN "public"."chat_categories"."id" IS '固有ID';

COMMENT ON COLUMN "public"."chat_categories"."name" IS 'カテゴリ名';

COMMENT ON COLUMN "public"."chat_categories"."parent_category" IS '親カテゴリ名 (例: 言語別, フレームワーク別)';

COMMENT ON COLUMN "public"."chat_categories"."is_deleted" IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN "public"."chat_categories"."created_at" IS 'レコード作成日時';

COMMENT ON COLUMN "public"."chat_categories"."updated_at" IS 'レコード更新日時';

CREATE TABLE IF NOT EXISTS "public"."chat_rooms" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_user_id" "uuid" NOT NULL,
    "member_user_ids" "text"[],
    "name" character varying(2000) NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);

ALTER TABLE "public"."chat_rooms" OWNER TO "postgres";

COMMENT ON TABLE "public"."chat_rooms" IS 'チャットルーム情報';

COMMENT ON COLUMN "public"."chat_rooms"."id" IS '固有ID';

COMMENT ON COLUMN "public"."chat_rooms"."owner_user_id" IS '作成者';

COMMENT ON COLUMN "public"."chat_rooms"."name" IS 'チャット名';

COMMENT ON COLUMN "public"."chat_rooms"."is_deleted" IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN "public"."chat_rooms"."created_at" IS 'レコード作成日時';

COMMENT ON COLUMN "public"."chat_rooms"."updated_at" IS 'レコード更新日時';

CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "notification_type" "text" NOT NULL,
    "is_read" boolean NOT NULL,
    "message" character varying(2000) NOT NULL,
    "send_by_user_name" "text" NOT NULL,
    "chat_room_id" "uuid" NOT NULL,
    "chat_room_name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);

ALTER TABLE "public"."notifications" OWNER TO "postgres";

COMMENT ON TABLE "public"."notifications" IS '通知情報';

COMMENT ON COLUMN "public"."notifications"."id" IS '通知の一意識別子 (UUID)';

COMMENT ON COLUMN "public"."notifications"."user_id" IS '通知の宛先ユーザーのID';

COMMENT ON COLUMN "public"."notifications"."notification_type" IS '通知の種類（例：メッセージ、アラートなど）';

COMMENT ON COLUMN "public"."notifications"."is_read" IS '通知が既読かどうかを示すフラグ';

COMMENT ON COLUMN "public"."notifications"."message" IS '通知に関連するメッセージの内容';

COMMENT ON COLUMN "public"."notifications"."send_by_user_name" IS '通知を送信したユーザーの名前';

COMMENT ON COLUMN "public"."notifications"."chat_room_id" IS 'チャットルームID';

COMMENT ON COLUMN "public"."notifications"."chat_room_name" IS '通知に関連するチャットルームの名前';

COMMENT ON COLUMN "public"."notifications"."created_at" IS '通知の作成日時（UTC）';

COMMENT ON COLUMN "public"."notifications"."updated_at" IS '通知の更新日時（UTC）';

CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "mention_id" "text" NOT NULL,
    "name" character varying DEFAULT '名前はまだない'::character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "profile_photo" character varying,
    "profile_details" character varying,
    "is_deleted" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."users" OWNER TO "postgres";

COMMENT ON TABLE "public"."users" IS 'ユーザー名などのユーザー情報を保持する';

COMMENT ON COLUMN "public"."users"."id" IS '固有ID';

COMMENT ON COLUMN "public"."users"."mention_id" IS 'メンションやログインに使用。変更可';

COMMENT ON COLUMN "public"."users"."name" IS '名前';

COMMENT ON COLUMN "public"."users"."created_at" IS 'レコード作成日時';

COMMENT ON COLUMN "public"."users"."updated_at" IS 'レコード更新日時';

COMMENT ON COLUMN "public"."users"."profile_photo" IS 'プロフィール写真のパスを保存するカラム';

COMMENT ON COLUMN "public"."users"."profile_details" IS '自己紹介';

COMMENT ON COLUMN "public"."users"."is_deleted" IS '削除フラグ (true: 削除済み, false: 未削除)';

ALTER TABLE ONLY "public"."chat_categories"
    ADD CONSTRAINT "chat_categories_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."chat_rooms"
    ADD CONSTRAINT "chat_rooms_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");

CREATE INDEX "idx_chat_categories_name" ON "public"."chat_categories" USING "btree" ("name");

CREATE INDEX "idx_chat_categories_parent_category" ON "public"."chat_categories" USING "btree" ("parent_category");

CREATE INDEX "idx_chat_categories_updated_at" ON "public"."chat_categories" USING "btree" ("updated_at");

CREATE INDEX "idx_chat_rooms_owner_user_id" ON "public"."chat_rooms" USING "btree" ("owner_user_id");

CREATE INDEX "idx_chat_rooms_updated_at" ON "public"."chat_rooms" USING "btree" ("updated_at");

CREATE INDEX "idx_notifications_user_id" ON "public"."notifications" USING "btree" ("user_id");

CREATE INDEX "idx_users_mention_id" ON "public"."users" USING "btree" ("mention_id");

CREATE OR REPLACE TRIGGER "after_messages_trigger" AFTER INSERT OR UPDATE ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."after_messages"();

ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."after_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."after_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."after_auth"() TO "service_role";

GRANT ALL ON FUNCTION "public"."after_messages"() TO "anon";
GRANT ALL ON FUNCTION "public"."after_messages"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."after_messages"() TO "service_role";

GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";

GRANT ALL ON FUNCTION "public"."send_user_messages"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."send_user_messages"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_user_messages"("user_id" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."chat_categories" TO "anon";
GRANT ALL ON TABLE "public"."chat_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_categories" TO "service_role";

GRANT ALL ON TABLE "public"."chat_rooms" TO "anon";
GRANT ALL ON TABLE "public"."chat_rooms" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_rooms" TO "service_role";

GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";

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

CREATE OR REPLACE TRIGGER "after_auth_trigger" AFTER INSERT OR DELETE OR UPDATE ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."after_auth"();

GRANT ALL ON TABLE "storage"."s3_multipart_uploads" TO "postgres";
GRANT ALL ON TABLE "storage"."s3_multipart_uploads_parts" TO "postgres";
