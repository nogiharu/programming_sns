-- 【auth.usersのAFTER TRIGGERイベント】
CREATE
OR REPLACE FUNCTION after_auth () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【INSERTトリガー】------------------------
    IF TG_OP = 'INSERT' THEN
        -- 新しいユーザーの user_id を生成
        DECLARE
            new_user_id TEXT := SPLIT_PART(NEW.email, '@', 1);
        BEGIN
            -- 新しいユーザーを public.users テーブルに挿入
            INSERT INTO public.users (id, mention_id)
            VALUES (NEW.id, new_user_id);
        END;
    ------------------------【UPDATEトリガー】------------------------
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.email_change != NEW.email_change THEN
            -- 新しいユーザーの user_id を生成
            DECLARE
                new_user_id TEXT := SPLIT_PART(NEW.email_change, '@', 1);
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- アフタートリガー
CREATE
OR REPLACE TRIGGER after_auth_trigger
AFTER INSERT
OR
UPDATE
OR DELETE ON auth.users FOR EACH ROW
EXECUTE FUNCTION after_auth ();

------------------------【テーブルを作成】------------------------
-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.users;

CREATE TABLE IF NOT EXISTS
    public.users (
        -- ユーザーIDを主キーとして設定 (authIDと同じ)
        id UUID NOT NULL PRIMARY KEY,
        -- ユーザーID メンションやログインに使用。変更可
        mention_id TEXT NOT NULL,
        -- ユーザー名
        NAME VARCHAR NOT NULL DEFAULT '名前はまだない',
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)  
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT TIMEZONE ('utc'::TEXT, NOW()),
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)  
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT TIMEZONE ('utc'::TEXT, NOW()),
        -- プロフィール写真のパスを保存するカラム
        profile_photo VARCHAR,
        -- 消されたか
        is_deleted BOOL NOT NULL DEFAULT FALSE
    );

------------------------【テーブルのコメントを追加】------------------------
COMMENT ON TABLE public.users IS 'ユーザー名などのユーザー情報を保持する';

------------------------【カラムにコメントを追加】------------------------
COMMENT ON COLUMN public.users.id IS '固有ID';

COMMENT ON COLUMN public.users.mention_id IS 'メンションやログインに使用。変更可';

COMMENT ON COLUMN public.users.name IS '名前';

COMMENT ON COLUMN public.users.profile_photo IS 'プロフィール写真のパスを保存するカラム';

COMMENT ON COLUMN public.users.is_deleted IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN public.users.created_at IS 'レコード作成日時';

COMMENT ON COLUMN public.users.updated_at IS 'レコード更新日時';

------------------------【インデックスの追加】------------------------
CREATE INDEX idx_users_mention_id ON public.users (mention_id);

-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.chat_rooms;

-- メッセージテーブルを作成
CREATE TABLE IF NOT EXISTS
    public.chat_rooms (
        -- メッセージIDを主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- ユーザー固有のIDを設定（作成者）
        owner_user_id UUID NOT NULL,
        -- チャットメンバー
        member_user_ids TEXT[],
        -- チャット名
        NAME VARCHAR(2000) NOT NULL,
        -- 消されたか
        is_deleted BOOL DEFAULT FALSE NOT NULL,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)  
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)  
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL
    );

-- テーブルのコメントを追加
COMMENT ON TABLE public.chat_rooms IS 'チャットルーム情報';

-- カラムにコメントを追加
COMMENT ON COLUMN public.chat_rooms.id IS '固有ID';

COMMENT ON COLUMN public.chat_rooms.owner_user_id IS '作成者';

COMMENT ON COLUMN public.chat_rooms.name IS 'チャット名';

COMMENT ON COLUMN public.chat_rooms.is_deleted IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN public.chat_rooms.created_at IS 'レコード作成日時';

COMMENT ON COLUMN public.chat_rooms.updated_at IS 'レコード更新日時';

-- インデックスの追加
CREATE INDEX idx_chat_rooms_owner_user_id ON public.chat_rooms (owner_user_id);

CREATE INDEX idx_chat_rooms_updated_at ON public.chat_rooms (updated_at);

-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.messages;

-- メッセージテーブルを作成
CREATE TABLE IF NOT EXISTS
    public.messages (
        -- メッセージIDを主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- ユーザー固有のIDを設定
        send_by_user_id UUID NOT NULL,
        -- チャットルームID
        chat_room_id UUID NOT NULL,
        -- メッセージ本文
        message VARCHAR(2000) NOT NULL,
        -- メッセージタイプ
        message_type TEXT NOT NULL,
        -- リアクション絵文字（キー：ユーザID、バリュー：絵文字）
        reactions JSONB,
        -- リプライ（message_id,user_id,message_type,message）
        -- 正気化してVIEWで関連メッセージを取得したいが、supabaseはVIEWのリアルタイムをサポートしていないため、JSONBで全部突っ込む
        reply_to JSONB,
        -- 消されたか
        is_deleted BOOL DEFAULT FALSE,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- reply_to JSON フィールドの構造を確認するチェック制約を追加 
        -- reply_to が NULL の場合は制約をチェックしない
        CONSTRAINT valid_reply_to CHECK (
            reply_to IS NULL
            OR (
                reply_to ? 'message_id'
                AND JSONB_TYPEOF(reply_to -> 'message_id') = 'string'
                AND reply_to ? 'user_id'
                AND JSONB_TYPEOF(reply_to -> 'user_id') = 'string'
                AND reply_to ? 'message_type'
                AND JSONB_TYPEOF(reply_to -> 'message_type') = 'string'
                AND reply_to ? 'message'
                AND JSONB_TYPEOF(reply_to -> 'message') = 'string'
            )
        )
    );

-- テーブルのコメントを追加
COMMENT ON TABLE public.messages IS 'アプリ内で送られたチャットを保持する';

-- カラムにコメントを追加
COMMENT ON COLUMN public.messages.id IS 'メッセージIDを主キーとして設定 (UUIDを自動生成)';

COMMENT ON COLUMN public.messages.send_by_user_id IS 'ユーザー固有のIDを設定';

COMMENT ON COLUMN public.messages.chat_room_id IS 'チャットルームID';

COMMENT ON COLUMN public.messages.message IS 'メッセージ本文';

COMMENT ON COLUMN public.messages.message_type IS 'メッセージタイプ';

COMMENT ON COLUMN public.messages.reactions IS 'リアクション絵文字';

COMMENT ON COLUMN public.messages.is_deleted IS '消されたか';

COMMENT ON COLUMN public.messages.created_at IS 'レコード作成日時を設定 (UTCタイムゾーンで現在時刻)';

COMMENT ON COLUMN public.messages.updated_at IS 'レコード更新日時を設定 (UTCタイムゾーンで現在時刻)';

------------------------【AFTERトリガー】------------------------
-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION after_messages () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【UPDATE OR INSERTトリガー】------------------------
        -- チャットルームの日付も更新
        UPDATE public.chat_rooms
        SET updated_at = TIMEZONE('utc', NOW())
        WHERE id = NEW.chat_room_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- トリガー追加
CREATE
OR REPLACE TRIGGER after_messages_trigger
AFTER INSERT
OR
UPDATE ON public.messages FOR EACH ROW
EXECUTE FUNCTION after_messages ();

-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.notifications;

-- 通知テーブルを作成
-- TODO 正気化してVIEWやサブクエリで関連を取得したいが、supabaseはVIEWのリアルタイムをサポートしていない
CREATE TABLE IF NOT EXISTS
    public.notifications (
        -- メッセージIDを主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- ユーザー固有のIDを設定（宛先）
        user_id UUID NOT NULL,
        -- 通知の種類
        notification_type TEXT NOT NULL,
        -- 既読したか
        is_read BOOLEAN NOT NULL,
        -- どのメッセージか
        message VARCHAR(2000) NOT NULL,
        -- 誰が送ったか
        send_by_user_name TEXT NOT NULL,
        -- チャットルームID
        chat_room_id UUID NOT NULL,
        -- どのチャットルームか
        chat_room_name TEXT NOT NULL,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)  
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)  
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL
    );

-- テーブルのコメントを追加
COMMENT ON TABLE public.notifications IS '通知情報';

-- 各カラムのコメントを追加
COMMENT ON COLUMN public.notifications.id IS '通知の一意識別子 (UUID)';

COMMENT ON COLUMN public.notifications.user_id IS '通知の宛先ユーザーのID';

COMMENT ON COLUMN public.notifications.message IS '通知に関連するメッセージの内容';

COMMENT ON COLUMN public.notifications.notification_type IS '通知の種類（例：メッセージ、アラートなど）';

COMMENT ON COLUMN public.notifications.is_read IS '通知が既読かどうかを示すフラグ';

COMMENT ON COLUMN public.notifications.send_by_user_name IS '通知を送信したユーザーの名前';

COMMENT ON COLUMN public.notifications.chat_room_name IS '通知に関連するチャットルームの名前';

COMMENT ON COLUMN public.notifications.chat_room_id IS 'チャットルームID';

COMMENT ON COLUMN public.notifications.created_at IS '通知の作成日時（UTC）';

COMMENT ON COLUMN public.notifications.updated_at IS '通知の更新日時（UTC）';

-- インデックスの追加
CREATE INDEX idx_notifications_user_id ON public.notifications (user_id);