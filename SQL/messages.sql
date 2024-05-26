-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.messages;

-- メッセージテーブルを作成
CREATE TABLE IF NOT EXISTS
    public.messages (
        -- メッセージIDを主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- ユーザー固有のIDを設定
        send_by_user_id UUID NOT NULL REFERENCES public.users (id) ON DELETE CASCADE,
        -- チャットルームID
        chat_room_id UUID NOT NULL REFERENCES public.chat_rooms (id) ON DELETE CASCADE,
        -- メッセージ本文
        message VARCHAR(2000) NOT NULL,
        -- メッセージタイプ
        message_type VARCHAR NOT NULL,
        -- リプライしたユーザーID
        reply_by_user_id UUID,
        -- リプライされたユーザーID
        reply_to_user_id UUID,
        -- リプライしたメッセージID
        reply_message_id UUID,
        -- リプライメッセージタイプ
        reply_message_type VARCHAR,
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

COMMENT ON COLUMN public.messages.reply_by_user_id IS 'リプライしたユーザーID';

COMMENT ON COLUMN public.messages.reply_to_user_id IS 'リプライされたユーザーID';

COMMENT ON COLUMN public.messages.reply_message_id IS 'リプライしたメッセージID';

COMMENT ON COLUMN public.messages.reply_message_type IS 'リプライメッセージタイプ';

COMMENT ON COLUMN public.messages.reactions IS 'リアクション絵文字';

COMMENT ON COLUMN public.messages.reacted_user_ids IS 'リアクションしたユーザーID';

COMMENT ON COLUMN public.messages.is_deleted IS '消されたか';

COMMENT ON COLUMN public.messages.created_at IS 'レコード作成日時を設定 (UTCタイムゾーンで現在時刻)';

COMMENT ON COLUMN public.messages.updated_at IS 'レコード更新日時を設定 (UTCタイムゾーンで現在時刻)';

-- インデックスの追加
CREATE INDEX idx_messages_send_by_user_id ON public.messages (send_by_user_id);

CREATE INDEX idx_messages_chat_room_id ON public.messages (chat_room_id);

CREATE INDEX idx_messages_updated_at ON public.messages (updated_at);

------------------------【トリガーの追加】------------------------
-- 更新時に`update_updated_at`を呼ぶためのトリガーを定義
CREATE
OR REPLACE TRIGGER messages_updated_at_trigger BEFORE
UPDATE ON public.messages FOR EACH ROW
EXECUTE FUNCTION update_updated_at ();