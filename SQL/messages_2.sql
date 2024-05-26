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
        chat_room_id UUID NOT NULL REFERENCES public.chat_rooms (id) ON DELETE CASCADE,
        -- メッセージ本文
        message VARCHAR(2000) NOT NULL,
        -- メッセージタイプ
        message_type VARCHAR NOT NULL,
        -- リアクション絵文字
        reactions VARCHAR[],
        -- リアクションしたユーザーID
        reacted_user_ids UUID[],
        -- 消されたか
        is_deleted BOOL DEFAULT FALSE NOT NULL,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL
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

COMMENT ON COLUMN public.messages.reacted_user_ids IS 'リアクションしたユーザーID';

COMMENT ON COLUMN public.messages.is_deleted IS '消されたか';

COMMENT ON COLUMN public.messages.created_at IS 'レコード作成日時を設定 (UTCタイムゾーンで現在時刻)';

COMMENT ON COLUMN public.messages.updated_at IS 'レコード更新日時を設定 (UTCタイムゾーンで現在時刻)';

-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.message_replies;

-- リプライテーブルを作成
CREATE TABLE IF NOT EXISTS
    public.message_replies (
        -- リプライIDを主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- リプライ対象のメッセージID
        message_id UUID NOT NULL REFERENCES public.messages (id) ON DELETE CASCADE,
        -- メッセージ本文
        reply_message VARCHAR(2000) NOT NULL,
        -- リプライしたユーザーID
        reply_by_user_id UUID NOT NULL,
        -- リプライメッセージタイプ
        reply_message_type VARCHAR NOT NULL,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL
    );

-- テーブルのコメントを追加
COMMENT ON TABLE public.message_replies IS 'メッセージへのリプライ情報を保持する';

-- カラムにコメントを追加
COMMENT ON COLUMN public.message_replies.id IS 'リプライIDを主キーとして設定 (UUIDを自動生成)';

COMMENT ON COLUMN public.message_replies.message_id IS 'リプライ対象のメッセージID';

COMMENT ON COLUMN public.message_replies.reply_message IS 'リプライ本文';

COMMENT ON COLUMN public.message_replies.reply_by_user_id IS 'リプライしたユーザーID';

COMMENT ON COLUMN public.message_replies.reply_message_type IS 'リプライメッセージタイプ';

COMMENT ON COLUMN public.message_replies.created_at IS 'レコード作成日時を設定 (UTCタイムゾーンで現在時刻)';

COMMENT ON COLUMN public.message_replies.updated_at IS 'レコード更新日時を設定 (UTCタイムゾーンで現在時刻)';

------------------------【トリガーの追加】------------------------
-- 更新時に`update_updated_at`を呼ぶためのトリガーを定義
CREATE
OR REPLACE TRIGGER messages_updated_at_trigger BEFORE
UPDATE ON public.messages FOR EACH ROW
EXECUTE FUNCTION update_updated_at ();

-- 更新時に`update_updated_at`を呼ぶためのトリガーを定義
CREATE
OR REPLACE TRIGGER message_replies_updated_at_trigger BEFORE
UPDATE ON public.message_replies FOR EACH ROW
EXECUTE FUNCTION update_updated_at ();