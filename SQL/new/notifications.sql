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

COMMENT ON COLUMN public.notifications.notifications_type IS '通知の種類（例：メッセージ、アラートなど）';

COMMENT ON COLUMN public.notifications.is_read IS '通知が既読かどうかを示すフラグ';

COMMENT ON COLUMN public.notifications.send_by_user_name IS '通知を送信したユーザーの名前';

COMMENT ON COLUMN public.notifications.chat_room_name IS '通知に関連するチャットルームの名前';

COMMENT ON COLUMN public.notifications.chat_room_id IS 'チャットルームID';

COMMENT ON COLUMN public.notifications.created_at IS '通知の作成日時（UTC）';

COMMENT ON COLUMN public.notifications.updated_at IS '通知の更新日時（UTC）';

-- インデックスの追加
CREATE INDEX idx_notifications_user_id ON public.notifications (user_id);