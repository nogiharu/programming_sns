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
        message_type VARCHAR NOT NULL,
        -- リアクション絵文字
        reactions VARCHAR[],
        -- リアクションしたユーザーID
        reacted_user_ids UUID[],
        -- 消されたか
        is_deleted BOOL DEFAULT FALSE,
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

------------------------【トリガーの追加】------------------------
-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION before_messages () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【UPDATEトリガー】------------------------
    IF TG_OP = 'UPDATE' THEN
        -- updated_atを自動アップデートを処理する
        NEW.updated_at = TIMEZONE('utc'::TEXT, NOW());
    ------------------------【INSERTトリガー】------------------------
    -- ELSIF TG_OP = 'INSERT' THEN

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

------------------------【トリガーの追加】------------------------
CREATE
OR REPLACE TRIGGER before_messages_trigger BEFORE
UPDATE ON public.messages FOR EACH ROW
EXECUTE FUNCTION before_messages ();