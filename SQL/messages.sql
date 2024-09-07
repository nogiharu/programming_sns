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

-- ビューの作成(リアルタイムと相性がよくないため、COLUMを追加してコメントにする)
-- CREATE OR REPLACE VIEW
--     public.messages_view AS
-- SELECT
--     m.*,
--     r.message AS reply_message,
--     m.send_by_user_id AS reply_by,
--     r.send_by_user_id AS reply_to,
--     r.message_type AS reply_message_type
-- FROM
--     public.messages m
--     LEFT JOIN public.messages r ON m.reply_message_id = r.id;