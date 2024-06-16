-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.replies;

-- リプライテーブルを作成
CREATE TABLE IF NOT EXISTS
    public.replies (
        -- 主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- リプライ対象のメッセージID
        message_id UUID NOT NULL,
        -- リプライしたユーザーID
        reply_by_user_id UUID,
        -- メッセージ本文
        reply_message VARCHAR(2000),
        -- リプライメッセージタイプ
        reply_message_type VARCHAR,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()),
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW())
    );

-- テーブルのコメントを追加
COMMENT ON TABLE public.replies IS 'メッセージへのリプライ情報を保持する';

-- カラムにコメントを追加
COMMENT ON COLUMN public.replies.id IS '主キーとして設定 (UUIDを自動生成)';

COMMENT ON COLUMN public.replies.message_id IS 'リプライIDを主キーとして設定 (メッセージID)';

COMMENT ON COLUMN public.replies.reply_message IS 'リプライ本文';

COMMENT ON COLUMN public.replies.reply_by_user_id IS 'リプライしたユーザーID';

COMMENT ON COLUMN public.replies.reply_message_type IS 'リプライメッセージタイプ';

COMMENT ON COLUMN public.replies.created_at IS 'レコード作成日時を設定 (UTCタイムゾーンで現在時刻)';

COMMENT ON COLUMN public.replies.updated_at IS 'レコード更新日時を設定 (UTCタイムゾーンで現在時刻)';

------------------------【トリガーの追加】------------------------
-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION before_replies () RETURNS TRIGGER AS $$
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

CREATE
OR REPLACE TRIGGER before_replies_trigger BEFORE
UPDATE ON public.replies FOR EACH ROW
EXECUTE FUNCTION before_replies ();